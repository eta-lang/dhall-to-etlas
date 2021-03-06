{-# language FlexibleInstances #-}
{-# language GeneralizedNewtypeDeriving #-}
{-# language LambdaCase #-}
{-# language MultiWayIf #-}
{-# language NamedFieldPuns #-}
{-# language OverloadedStrings #-}
{-# language ScopedTypeVariables #-}
{-# language ViewPatterns #-}

module CabalToDhall
  ( cabalToDhall
  , parseGenericPackageDescriptionThrows
  , KnownDefault (..)
  , PreludeReference (..)
  , TypeReference
  , resolvePreludeVar
  , resolveType
  , getDefault
  ) where

import Data.Functor.Contravariant ( (>$<), Contravariant( contramap ) )
import Data.Semigroup ( Semigroup, (<>) )
import Data.Void ( absurd )
import Numeric.Natural ( Natural )

import qualified Data.ByteString as ByteString
import qualified Data.Char as Char
import qualified Data.Sequence as Seq
import qualified Data.Text as StrictText
import qualified Data.Text.Encoding as StrictText
import qualified Dhall
import qualified Dhall.Core
import qualified Dhall.Core as Expr ( Expr(..), makeBinding )
import qualified Dhall.Map as Map
import qualified Dhall.Parser
import qualified Dhall.TypeCheck
import qualified Distribution.Compiler as Cabal
import qualified Distribution.License as Cabal
import qualified Distribution.ModuleName as Cabal
import qualified Distribution.PackageDescription.Parse as Cabal
-- import qualified Distribution.Pretty as Cabal
-- import qualified Distribution.SPDX as SPDX
import qualified Distribution.System as Cabal
import qualified Distribution.Text as Cabal
import qualified Distribution.Types.Benchmark as Cabal
import qualified Distribution.Types.BenchmarkInterface as Cabal
import qualified Distribution.Types.BuildInfo as Cabal
import qualified Distribution.Types.BuildType as Cabal
import qualified Distribution.Types.CondTree as Cabal
import qualified Distribution.Types.Condition as Cabal
import qualified Distribution.Types.Dependency as Cabal
import qualified Distribution.Types.ExeDependency as Cabal
import qualified Distribution.Types.Executable as Cabal
import qualified Distribution.Types.ForeignLib as Cabal
import qualified Distribution.Types.ForeignLibOption as Cabal
import qualified Distribution.Types.ForeignLibType as Cabal
import qualified Distribution.Types.GenericPackageDescription as Cabal
import qualified Distribution.Types.IncludeRenaming as Cabal
import qualified Distribution.Types.LegacyExeDependency as Cabal
import qualified Distribution.Types.Library as Cabal
-- import qualified Distribution.Types.LibraryName as Cabal
-- import qualified Distribution.Types.LibraryVisibility as Cabal
import qualified Distribution.Types.Mixin as Cabal
import qualified Distribution.Types.ModuleReexport as Cabal
import qualified Distribution.Types.ModuleRenaming as Cabal
import qualified Distribution.Types.PackageDescription as Cabal
import qualified Distribution.Types.PackageId as Cabal
import qualified Distribution.Types.PackageName as Cabal
import qualified Distribution.Types.PkgconfigDependency as Cabal
import qualified Distribution.Types.PkgconfigName as Cabal
-- import qualified Distribution.Types.PkgconfigVersion as Cabal
-- import qualified Distribution.Types.PkgconfigVersionRange as Cabal
import qualified Distribution.Types.SetupBuildInfo as Cabal
import qualified Distribution.Types.SourceRepo as Cabal
import qualified Distribution.Types.TestSuite as Cabal
import qualified Distribution.Types.TestSuiteInterface as Cabal
import qualified Distribution.Types.UnqualComponentName as Cabal
import qualified Distribution.Version as Cabal
import qualified Language.Haskell.Extension as Cabal

import DhallLocation ( DhallLocation(..) )
import DhallToCabal ( sortExpr )
import DhallToCabal.ConfigTree ( ConfigTree(..) )


dhallString :: String -> Expr.Expr s a
dhallString = Expr.TextLit . Dhall.Core.Chunks [] . StrictText.pack

parseGenericPackageDescriptionThrows
  :: ByteString.ByteString
  -> IO Cabal.GenericPackageDescription
parseGenericPackageDescriptionThrows source =
  case Cabal.parseGenericPackageDescription ( StrictText.unpack $ StrictText.decodeUtf8 source ) of
    Cabal.ParseFailed e -> do
      putStrLn "Could not parse Cabal file: "

      error ( show e )

    Cabal.ParseOk _warnings genericPackageDescription ->
      return genericPackageDescription


cabalToDhall
  :: DhallLocation
  -> Cabal.GenericPackageDescription
  -> Expr.Expr Dhall.Parser.Src Dhall.Core.Import
cabalToDhall dhallLocation genericPackageDescription
  = Expr.Let
      ( Expr.makeBinding "prelude" ( Expr.Embed ( preludeLocation dhallLocation ) ) )
  $ Expr.Let
      ( Expr.makeBinding "types" ( Expr.Embed ( typesLocation dhallLocation ) ) )
  $ absurd <$>
      Dhall.embed
        genericPackageDescriptionToDhall
        genericPackageDescription


-- Note: the Show instance is used by --print-type.
data KnownDefault
  = CompilerOptions
  | BuildInfo
  | Library
--  | MainLibrary
--  | NamedLibrary
  | Executable
  | Benchmark
  | TestSuite
  | Package
  | SourceRepo
  deriving ( Bounded, Enum, Eq, Ord, Read, Show )

data VersionRange
  = AnyVersion
  | EarlierVersion
  | OrEarlierVersion
  | IntersectVersionRanges
  | IntervalVersionRange
  | UnionVersionRanges
  | MajorBoundVersion
  | OrLaterVersion
  | LaterVersion
  | ThisVersion
  | NotThisVersion
  | WithinVersion
  | NoVersion
  deriving ( Bounded, Enum, Eq, Ord, Read, Show )

data PreludeReference
  = PreludeDefault KnownDefault
  | PreludeV
  | PreludeVersionRange VersionRange
  | PreludeSPDX Dhall.Text
  deriving ( Show )

data TypeReference
  = TypeBenchmark
  | TypeBuildType
  | TypeCompiler
  | TypeCompilerOption
  | TypeConfig
  | TypeCustomSetup
  | TypeExecutable
  | TypeExtension
  | TypeForeignLibrary
  | TypeLanguage
  | TypeLibrary
  | TypeLicense
  | TypeLicenseExceptionId
  | TypeLicenseId
  | TypeMixin
  | TypeModuleRenaming
  | TypeOS
  | TypeRepoKind
  | TypeRepoType
  | TypeScope
  | TypeSourceRepo
  | TypeSPDX
  | TypeTestSuite
  | TypeVersion
  | TypeVersionRange
  deriving ( Bounded, Enum, Eq, Ord, Read, Show )

resolveDefaultVar :: Dhall.Text -> Expr.Expr s a
resolveDefaultVar name =
  Expr.Var "prelude" `Expr.Field` "defaults" `Expr.Field` name

resolvePreludeVar :: PreludeReference -> Expr.Expr s a
resolvePreludeVar = \case
  PreludeDefault typ ->
    resolveDefaultVar ( StrictText.pack ( show typ ) )
  PreludeV ->
    Expr.Var "prelude" `Expr.Field` "v"
  PreludeVersionRange rng ->
    Expr.Var "prelude" `Expr.Field` StrictText.pack ( uncapitalize ( show rng ) )
    where uncapitalize (h:xs) = Char.toLower h : xs
          uncapitalize "" = ""  
  PreludeSPDX field ->
    Expr.Var "prelude" `Expr.Field` "SPDX" `Expr.Field` field

resolveVersionRange :: VersionRange -> Expr.Expr s a
resolveVersionRange = resolvePreludeVar . PreludeVersionRange

resolveType :: TypeReference -> Expr.Expr s a
resolveType = \case
  TypeBenchmark ->
    Expr.Var "types" `Expr.Field` "Benchmark"
  TypeBuildType ->
    Expr.Var "types" `Expr.Field` "BuildType"
  TypeCompiler ->
    Expr.Var "types" `Expr.Field` "Compiler"
  TypeCompilerOption ->
    Expr.Var "types" `Expr.Field` "CompilerOption"
  TypeConfig ->
    Expr.Var "types" `Expr.Field` "Config"
  TypeCustomSetup ->
    Expr.Var "types" `Expr.Field` "CustomSetup"
  TypeExecutable ->
    Expr.Var "types" `Expr.Field` "Executable"
  TypeExtension ->
    Expr.Var "types" `Expr.Field` "Extension"
  TypeForeignLibrary ->
    Expr.Var "types" `Expr.Field` "ForeignLibrary"
  TypeLanguage ->
    Expr.Var "types" `Expr.Field` "Language"
  TypeLibrary ->
    Expr.Var "types" `Expr.Field` "Library"
  TypeLicense ->
    Expr.Var "types" `Expr.Field` "License"
  TypeLicenseExceptionId ->
    Expr.Var "types" `Expr.Field` "LicenseExceptionId"
  TypeLicenseId ->
    Expr.Var "types" `Expr.Field` "LicenseId"
  TypeMixin ->
    Expr.Var "types" `Expr.Field` "Mixin"
  TypeModuleRenaming ->
    Expr.Var "types" `Expr.Field` "ModuleRenaming"
  TypeOS ->
    Expr.Var "types" `Expr.Field` "OS"
  TypeRepoKind ->
    Expr.Var "types" `Expr.Field` "RepoKind"
  TypeRepoType ->
    Expr.Var "types" `Expr.Field` "RepoType"
  TypeScope ->
    Expr.Var "types" `Expr.Field` "Scope"
  TypeSourceRepo ->
    Expr.Var "types" `Expr.Field` "SourceRepo"
  TypeSPDX ->
    Expr.Var "types" `Expr.Field` "SPDX"
  TypeTestSuite ->
    Expr.Var "types" `Expr.Field` "TestSuite"
  TypeVersion ->
    Expr.Var "types" `Expr.Field` "Version"
  TypeVersionRange ->
    Expr.Var "types" `Expr.Field` "VersionRange"
    
type Default s a
   = ( PreludeReference -> Expr.Expr s a )
   -> Map.Map StrictText.Text ( Expr.Expr s a )

getDefault
  :: ( Eq s )
  => Dhall.Core.Import
  -> ( PreludeReference -> Expr.Expr s Dhall.Core.Import )
  -> KnownDefault
  -> Expr.Expr s Dhall.Core.Import
getDefault typesLoc resolve typ = withTypesImport expr
  where
    withTypesImport =
      Expr.Let ( Expr.makeBinding "types" ( Expr.Embed typesLoc ) )

    factorBuildInfo fields =
      let
        shared = Map.filter id ( Map.intersectionWith (==) fields ( buildInfoDefault resolve ) )
      in
        if | null shared
             -> Expr.RecordLit fields
           | null ( Map.difference fields shared )
             -> resolve ( PreludeDefault BuildInfo )
           | otherwise
             -> Expr.Prefer
                  ( resolve ( PreludeDefault BuildInfo ) )
                  ( Expr.RecordLit ( Map.difference fields shared ) )

    expr =
      case typ of
        CompilerOptions ->
          Expr.RecordLit ( compilerOptionsDefault resolve )
        BuildInfo ->
          Expr.RecordLit ( buildInfoDefault resolve )
        Library ->
          factorBuildInfo ( libraryDefault resolve )
--        MainLibrary ->
--          factorBuildInfo ( libraryDefault False resolve )
--        NamedLibrary ->
--          factorBuildInfo ( libraryDefault True resolve )
        Executable ->
          factorBuildInfo ( executableDefault resolve )
        Benchmark ->
          factorBuildInfo ( benchmarkDefault resolve )
        TestSuite ->
          factorBuildInfo ( testSuiteDefault resolve )
        Package ->
          Expr.RecordLit ( packageDefault resolve )
        SourceRepo ->
          Expr.RecordLit ( sourceRepoDefault resolve )


emptyListDefault
  :: StrictText.Text
  -> Expr.Expr s a
  -> ( StrictText.Text, Expr.Expr s a )
emptyListDefault name ty =
  ( name, Expr.ListLit ( Just ( Expr.App Expr.List ty ) ) mempty )


emptyOptionalDefault
  :: StrictText.Text
  -> Expr.Expr s a
  -> ( StrictText.Text, Expr.Expr s a )
emptyOptionalDefault name ty =
  ( name, Expr.App Expr.None ty )


textFieldDefault
  :: StrictText.Text
  -> StrictText.Text
  -> ( StrictText.Text, Expr.Expr s a )
textFieldDefault name def =
  ( name
  , Expr.TextLit ( Dhall.Core.Chunks [] def )
  )

generaliseDeclared :: Dhall.InputType t -> Expr.Expr s a
generaliseDeclared =
  Dhall.Core.denote . fmap absurd . Dhall.declared

generaliseEmbed :: Dhall.InputType t -> t -> Expr.Expr s a
generaliseEmbed a =
  Dhall.Core.denote . fmap Dhall.TypeCheck.absurd . ( Dhall.embed a )


compilerOptionsDefault :: Default s a
compilerOptionsDefault _resolve =
  ( Map.fromList
    [ emptyListDefault "Eta" Expr.Text
    , ( "GHC" , Expr.ListLit ( Just Expr.Text ) opts )
    , emptyListDefault "GHCJS" Expr.Text
    , emptyListDefault "HBC" Expr.Text
    , emptyListDefault "Helium" Expr.Text
    , emptyListDefault "Hugs" Expr.Text
    , emptyListDefault "JHC" Expr.Text
    , emptyListDefault "LHC" Expr.Text
    , emptyListDefault "NHC" Expr.Text
    , emptyListDefault "UHC" Expr.Text
    , emptyListDefault "YHC" Expr.Text
    ]
  )
  where opts =
          Seq.fromList $ map Expr.TextLit
                          [ "-Wall"
                          , "-fwarn-incomplete-uni-patterns"
                          , "-fwarn-incomplete-record-updates"
                          ]


buildInfoDefault :: Default s a
buildInfoDefault resolve = fields
  where
    fields = Map.fromList
      [ emptyListDefault "autogen-modules" Expr.Text
      , emptyListDefault "build-depends" ( generaliseDeclared dependency )
      , emptyListDefault "build-tool-depends" ( generaliseDeclared exeDependency )
      , emptyListDefault "build-tools"
          ( generaliseDeclared legacyExeDependency )
      , ( "buildable", Expr.BoolLit True )
      , emptyListDefault "c-sources" Expr.Text
      , emptyListDefault "cc-options" Expr.Text
      , ( "compiler-options", resolve ( PreludeDefault CompilerOptions ) )
      , emptyListDefault "cpp-options" Expr.Text
      , ( "default-extensions" , defaultExtensions )
      , ( "default-language"
        , Expr.Some
          ( resolveType TypeLanguage `Expr.Field` "Haskell2010" )
        )
      , emptyListDefault "extra-framework-dirs" Expr.Text
      , emptyListDefault "extra-ghci-libraries" Expr.Text
      , emptyListDefault "extra-lib-dirs" Expr.Text
--      , emptyListDefault "extra-libraries" Expr.Text
      , emptyListDefault "maven-depends" Expr.Text
      , emptyListDefault "frameworks" Expr.Text
      , emptyListDefault "hs-source-dirs" Expr.Text
      , emptyListDefault "includes" Expr.Text
      , emptyListDefault "include-dirs" Expr.Text
      , emptyListDefault "install-includes" Expr.Text
      , emptyListDefault "js-sources" Expr.Text
      , emptyListDefault "ld-options" Expr.Text
      , emptyListDefault "other-extensions" ( generaliseDeclared extension )
      , emptyListDefault "other-languages" ( generaliseDeclared language )
      , emptyListDefault "other-modules" Expr.Text
      , emptyListDefault "pkgconfig-depends" ( generaliseDeclared pkgconfigDependency )
      , ( "profiling-options", resolve ( PreludeDefault CompilerOptions ) )
      , ( "shared-options", resolve ( PreludeDefault CompilerOptions ) )
      -- , ( "static-options", resolve ( PreludeDefault CompilerOptions ) )
      , emptyListDefault "mixins" ( generaliseDeclared mixin )
      , emptyListDefault "java-sources" Expr.Text
{--   , emptyListDefault "asm-options" Expr.Text
      , emptyListDefault "asm-sources" Expr.Text
      , emptyListDefault "cmm-options" Expr.Text
      , emptyListDefault "cmm-sources" Expr.Text
      , emptyListDefault "cxx-options" Expr.Text
      , emptyListDefault "cxx-sources" Expr.Text
      , emptyListDefault "virtual-modules" Expr.Text
      , emptyListDefault "extra-lib-flavours" Expr.Text
      , emptyListDefault "extra-bundled-libs" Expr.Text
      , emptyListDefault "autogen-includes" Expr.Text
      , emptyListDefault "extra-dyn-lib-flavours" Expr.Text
--}
      ]

defaultExtensions :: Expr.Expr s a
defaultExtensions =
  Expr.ListLit ( Just ( generaliseDeclared extension ) )
               ( fmap ( generaliseEmbed extension ) ( Seq.fromList cabalExts ) )
  where cabalExts =
          map Cabal.EnableExtension
            [ Cabal.BangPatterns
            , Cabal.DataKinds
            , Cabal.DeriveFoldable
            , Cabal.DeriveFunctor
            , Cabal.DeriveGeneric
            , Cabal.DeriveTraversable
            , Cabal.EmptyCase
            , Cabal.ExistentialQuantification
            , Cabal.FlexibleContexts
            , Cabal.FlexibleInstances
            , Cabal.FunctionalDependencies
            , Cabal.GeneralizedNewtypeDeriving
            , Cabal.MagicHash
            , Cabal.MultiParamTypeClasses
            , Cabal.MultiWayIf
            , Cabal.LambdaCase
            , Cabal.OverloadedStrings
            , Cabal.RankNTypes
            , Cabal.StandaloneDeriving
            , Cabal.ScopedTypeVariables
            , Cabal.TupleSections
            , Cabal.TypeFamilies
            , Cabal.TypeOperators
            ]


{--
libraryVisibility :: Dhall.InputType Cabal.LibraryVisibility
libraryVisibility =
  Dhall.InputType
    { Dhall.embed = \case
        Cabal.LibraryVisibilityPublic ->
            Expr.Var "types" `Expr.Field` "LibraryVisibility" `Expr.Field` "public"
        Cabal.LibraryVisibilityPrivate ->
            Expr.Var "types" `Expr.Field` "LibraryVisibility" `Expr.Field` "private"
    , Dhall.declared =
        Expr.Var "types" `Expr.Field` "LibraryVisibility"
    }
--}

libraryDefault :: Default s a
libraryDefault resolve = buildInfoDefault resolve <> specificFields
  where
    specificFields = Map.fromList
      [ emptyListDefault "exposed-modules" Expr.Text
      , emptyListDefault "other-modules" Expr.Text
      , emptyListDefault "reexported-modules"
          ( generaliseDeclared moduleReexport )
      , emptyListDefault "signatures" Expr.Text
      ]
{--
      , ( "visibility"
        , ( resolve PreludeConstructorsLibraryVisibility `Expr.Field` visibility )
        )
      ]
    visibility = if named
      then "private"
      else "public"
--}

benchmarkDefault :: Default s a
benchmarkDefault = buildInfoDefault


testSuiteDefault :: Default s a
testSuiteDefault = buildInfoDefault


executableDefault :: Default s a
executableDefault = buildInfoDefault
{--
executableDefault resolve = buildInfoDefault resolve <> specificFields
  where
    specificFields =
      Map.singleton "scope"
        ( resolveType TypeScope `Expr.Field` "Public" )
--}


packageDefault :: Default s a
packageDefault resolve = fields
  where
    configType = resolveType TypeConfig
    named name typ = Expr.Record
      ( Map.fromList
          [ ( "name"
            , Expr.Text
            )
          , ( name
            , Expr.Pi
                "config"
                configType
                ( generaliseDeclared typ )
            )
          ]
      )

    fields = Map.fromList
      [ textFieldDefault "author" ""
      , emptyListDefault "flags" ( generaliseDeclared flag )
      , emptyListDefault "benchmarks" ( named "benchmark" benchmark )
      , textFieldDefault "bug-reports" ""
      , ( "build-type" 
        , generaliseEmbed ( maybeToDhall buildType ) ( Just Cabal.Simple )
        )
      , ( "cabal-version"
        , Expr.App
            ( resolve PreludeV )
            ( Expr.TextLit ( Dhall.Core.Chunks [] "1.12" ) )
        )
      , textFieldDefault "category" ""
      , textFieldDefault "copyright" ""
      , textFieldDefault "data-dir" ""
      , emptyListDefault "data-files" Expr.Text
      , textFieldDefault "description" ""
      , emptyListDefault "executables" ( named "executable" executable )
      , emptyListDefault "extra-doc-files" Expr.Text
      , emptyListDefault "extra-source-files" Expr.Text
      , emptyListDefault "extra-tmp-files" Expr.Text
      , emptyListDefault "foreign-libraries" ( named "foreign-lib" foreignLibrary )
      , textFieldDefault "homepage" ""
      , emptyOptionalDefault "library"
          ( Expr.Pi
              "config"
              configType
              ( generaliseDeclared library )
          )
      , ( "license"
        , resolveType TypeLicense `Expr.Field` "AllRightsReserved"
        )
      , emptyListDefault "license-files" Expr.Text
      , textFieldDefault "maintainer" ""
      , textFieldDefault "package-url" ""
      , emptyListDefault "source-repos" ( generaliseDeclared sourceRepo )
      , textFieldDefault "stability" ""
      , emptyListDefault "sub-libraries" ( named "library" library )
      , textFieldDefault "synopsis" ""
      , emptyListDefault "test-suites" ( named "test-suite" testSuite )
      , emptyListDefault "tested-with"
          ( Expr.Record
              ( Map.fromList
                  [ ( "compiler", generaliseDeclared compilerFlavor )
                  , ( "version", generaliseDeclared versionRange )
                  ]
              )
          )
      , emptyListDefault "x-fields"
          ( Expr.Record
              ( Map.fromList
                  [ ( "_1", Expr.Text ), ( "_2", Expr.Text ) ]
              )
          )
      , emptyOptionalDefault "custom-setup"
          ( generaliseDeclared setupBuildInfo )
      ]


sourceRepoDefault :: Default s a
sourceRepoDefault _ = fields
  where
    fields = Map.fromList
      [ emptyOptionalDefault "type" ( generaliseDeclared repoType )
      , emptyOptionalDefault "location" Expr.Text
      , emptyOptionalDefault "module" Expr.Text
      , emptyOptionalDefault "branch" Expr.Text
      , emptyOptionalDefault "tag" Expr.Text
      , emptyOptionalDefault "subdir" Expr.Text
      , ( "kind"
        , resolveType TypeRepoKind `Expr.Field` "RepoHead"
        )
      , emptyOptionalDefault "commit" Expr.Text
      ]


data DefaultComparison s a
  = DefaultComparisonMatch
  | DefaultComparisonReplace ( Expr.Expr s a )
  deriving ( Show )


extractDefaultComparisonReplace
  :: DefaultComparison s a
  -> Maybe ( Expr.Expr s a )
extractDefaultComparisonReplace DefaultComparisonMatch =
  Nothing
extractDefaultComparisonReplace ( DefaultComparisonReplace expr ) =
  Just expr


nonDefaultFields
  :: ( Eq a )
  => Map.Map StrictText.Text ( Expr.Expr s a )
  -> Map.Map StrictText.Text ( Expr.Expr s a )
  -> Map.Map StrictText.Text ( Expr.Expr s a )
nonDefaultFields defs fields =
  let
    withoutDefaults = Map.difference fields defs
    compared = Map.intersectionWith compareToDefault defs fields
    changed = Map.mapMaybe extractDefaultComparisonReplace compared
  in
    withoutDefaults <> changed


compareToDefault :: ( Eq a ) => Expr.Expr s a -> Expr.Expr s a -> DefaultComparison s a
compareToDefault def expr | Dhall.Core.judgmentallyEqual def expr =
  DefaultComparisonMatch
compareToDefault _ expr =
  DefaultComparisonReplace expr


withDefault :: ( Eq a ) => KnownDefault -> Default s a -> Expr.Expr s a -> Expr.Expr s a
withDefault typ defs ( Expr.RecordLit fields ) =
  let
    nonDefaults = nonDefaultFields ( defs resolvePreludeVar ) fields
    name = StrictText.pack ( show typ )
  in
    if null nonDefaults
    then resolveDefaultVar name
    else Expr.Prefer
           ( resolveDefaultVar name )
           ( Expr.RecordLit nonDefaults )
withDefault _ _ expr =
  expr


newtype RecordInputType a =
  RecordInputType
    { _unRecordInputType ::
        Map.Map Dhall.Text ( Dhall.InputType a )
    }
  deriving ( Semigroup, Monoid )


instance Contravariant RecordInputType where
  contramap f ( RecordInputType map ) =
    RecordInputType ( fmap ( contramap f ) map )


recordField :: Dhall.Text -> Dhall.InputType a -> RecordInputType a
recordField k v =
  RecordInputType ( Map.singleton k v )


runRecordInputType :: RecordInputType a -> Dhall.InputType a
runRecordInputType ( RecordInputType m ) =
  Dhall.InputType
    { Dhall.embed =
        \a -> sortExpr ( Expr.RecordLit ( fmap ( \t -> Dhall.embed t a ) m ) )
    , Dhall.declared = sortExpr ( Expr.Record ( fmap Dhall.declared m ) )
    }


runRecordInputTypeWithDefault :: KnownDefault -> Default Dhall.Parser.Src Dhall.TypeCheck.X -> RecordInputType a -> Dhall.InputType a
runRecordInputTypeWithDefault typ def m =
  let
    Dhall.InputType embed declared = runRecordInputType m
  in
    Dhall.InputType ( withDefault typ def . embed ) declared


genericPackageDescriptionToDhall
  :: Dhall.InputType Cabal.GenericPackageDescription
genericPackageDescriptionToDhall =
  let
    named k v =
      listOf
        ( runRecordInputType
            ( mconcat
                [ fst >$< recordField "name" unqualComponentName
                , snd >$< recordField k v
                ]
            )
        )

  in
  runRecordInputTypeWithDefault Package packageDefault
    ( mconcat
        [ Cabal.packageDescription >$< packageDescriptionToRecord
        , recordField "flags" ( Cabal.genPackageFlags >$< ( listOf flag ) )
        , recordField "library" ( Cabal.condLibrary >$< maybeToDhall ( condTree library ) )
        , recordField "sub-libraries" ( Cabal.condSubLibraries >$< named "library" ( condTree library ) )
        , recordField "foreign-libraries" ( Cabal.condForeignLibs >$< named "foreign-lib" ( condTree foreignLibrary ) )
        , recordField "executables" ( Cabal.condExecutables >$< named "executable" ( condTree executable ) )
        , recordField "test-suites" ( Cabal.condTestSuites >$< named "test-suite" ( condTree testSuite ) )
        , recordField "benchmarks" ( Cabal.condBenchmarks >$< named "benchmark" ( condTree benchmark ) )
        ]
    )


packageDescriptionToRecord
  :: RecordInputType Cabal.PackageDescription
packageDescriptionToRecord =
  mconcat
    [ contramap Cabal.package packageIdentifierToRecord
    , recordField "source-repos" ( contramap Cabal.sourceRepos ( listOf sourceRepo ) )
    , recordField "cabal-version" ( contramap Cabal.specVersionRaw specVersion )
    , recordField "build-type" ( contramap Cabal.buildType ( maybeToDhall buildType ) )
    , recordField "license" ( contramap Cabal.license licenseToDhall )
    , recordField "license-files" ( contramap Cabal.licenseFiles ( listOf stringToDhall ) )
    , recordField "copyright" ( contramap Cabal.copyright stringToDhall )
    , recordField "maintainer" ( contramap Cabal.maintainer stringToDhall )
    , recordField "author" ( contramap Cabal.author stringToDhall )
    , recordField "stability" ( contramap Cabal.stability stringToDhall )
    , recordField "tested-with" ( contramap Cabal.testedWith ( listOf compiler ) )
    , recordField "homepage" ( contramap Cabal.homepage stringToDhall )
    , recordField "package-url" ( contramap Cabal.pkgUrl stringToDhall )
    , recordField "bug-reports" ( contramap Cabal.bugReports stringToDhall )
    , recordField "synopsis" ( contramap Cabal.synopsis stringToDhall )
    , recordField "description" ( contramap Cabal.description stringToDhall )
    , recordField "category" ( contramap Cabal.category stringToDhall )
    , recordField "custom-setup" ( contramap Cabal.setupBuildInfo ( maybeToDhall setupBuildInfo ) )
    , recordField "data-files" ( contramap Cabal.dataFiles ( listOf stringToDhall ) )
    , recordField "data-dir" ( contramap Cabal.dataDir stringToDhall )
    , recordField "extra-source-files" ( contramap Cabal.extraSrcFiles ( listOf stringToDhall ) )
    , recordField "extra-tmp-files" ( contramap Cabal.extraTmpFiles ( listOf stringToDhall ) )
    , recordField "extra-doc-files" ( contramap Cabal.extraDocFiles ( listOf stringToDhall ) )
    , recordField
        "x-fields"
        ( Cabal.customFieldsPD
            >$<
              listOf
                ( runRecordInputType
                    ( mconcat
                        [ fst >$< recordField "_1" stringToDhall
                        , snd >$< recordField "_2" stringToDhall
                        ]
                    )
                )
        )
    ]


packageIdentifierToRecord
  :: RecordInputType Cabal.PackageIdentifier
packageIdentifierToRecord =
  mconcat
    [ recordField "name" ( contramap Cabal.pkgName packageNameToDhall )
    , recordField "version" ( contramap Cabal.pkgVersion versionToDhall )
    ]


packageNameToDhall :: Dhall.InputType Cabal.PackageName
packageNameToDhall =
  contramap Cabal.unPackageName stringToDhall


versionToDhall :: Dhall.InputType Cabal.Version
versionToDhall =
  Dhall.InputType
    { Dhall.embed =
        Expr.App ( resolvePreludeVar PreludeV )
          . Dhall.embed stringToDhall
          . show
          . Cabal.disp
    , Dhall.declared = resolveType TypeVersion
    }


stringToDhall :: Dhall.InputType String
stringToDhall =
  contramap StrictText.pack Dhall.inject

licenseToDhall :: Dhall.InputType Cabal.License
licenseToDhall =
  Dhall.InputType
    { Dhall.embed = \l ->
        case l of
          Cabal.GPL v ->
            license "GPL" ( Dhall.embed ( maybeToDhall versionToDhall ) v )
          Cabal.AGPL v ->
            license "AGPL" ( Dhall.embed ( maybeToDhall versionToDhall ) v )
          Cabal.LGPL v ->
            license "LGPL" ( Dhall.embed ( maybeToDhall versionToDhall ) v )
          Cabal.BSD2 ->
            licenseNullary "BSD2"
          Cabal.BSD3 ->
            licenseNullary "BSD3"
          Cabal.BSD4 ->
            licenseNullary "BSD4"
          Cabal.MIT ->
            licenseNullary "MIT"
          Cabal.ISC ->
            licenseNullary "ISC"
          Cabal.MPL v ->
            license "MPL" ( Dhall.embed versionToDhall v )
          Cabal.Apache v ->
            license "Apache" ( Dhall.embed ( maybeToDhall versionToDhall ) v )
          Cabal.PublicDomain ->
            licenseNullary "PublicDomain"
          Cabal.AllRightsReserved ->
            licenseNullary "AllRightsReserved"
          -- Note: SPDX.NONE is what Cabal reports for a file without
          -- a 'license' field, even for pre-2.2 spec versions.
--          Left SPDX.NONE ->
--            licenseNullary "AllRightsReserved"
          Cabal.UnspecifiedLicense ->
            licenseNullary "Unspecified"
          Cabal.UnknownLicense "UnspecifiedLicense"  ->
            licenseNullary "Unspecified"
          Cabal.UnknownLicense l ->
            license "Unknown" ( Expr.TextLit (Dhall.Core.Chunks [] (StrictText.pack l)) )
          Cabal.OtherLicense ->
            licenseNullary "Other"
--          Left ( SPDX.License x ) ->
--            license "SPDX" ( Dhall.embed spdxLicenseExpressionToDhall x )
    , Dhall.declared = typeLicense
    }
  where
    typeLicense = resolveType TypeLicense
    licenseNullary name = typeLicense `Expr.Field` name
    license = Expr.App . licenseNullary

{--
spdxLicenseExpressionToDhall :: Dhall.InputType SPDX.LicenseExpression
spdxLicenseExpressionToDhall =
    Dhall.InputType
    { Dhall.embed =
        let
          go lexp = case lexp of
            SPDX.ELicense ( SPDX.ELicenseId ident ) exceptionMay ->
              Expr.App
                ( Expr.App
                    ( resolvePreludeVar ( PreludeSPDX "license" ) )
                    ( Dhall.embed spdxLicenseIdToDhall ident )
                )
                ( Dhall.embed ( maybeToDhall spdxLicenseExceptionIdToDhall ) exceptionMay )
            SPDX.ELicense (SPDX.ELicenseIdPlus ident) exceptionMay ->
              Expr.App
                ( Expr.App
                    ( resolvePreludeVar ( PreludeSPDX "licenseVersionOrLater" ) )
                    ( Dhall.embed spdxLicenseIdToDhall ident )
                )
                ( Dhall.embed ( maybeToDhall spdxLicenseExceptionIdToDhall ) exceptionMay )
            SPDX.ELicense (SPDX.ELicenseRef ref) exceptionMay ->
              case SPDX.licenseDocumentRef ref of
                Nothing ->
                  Expr.App
                    ( Expr.App
                        ( resolvePreludeVar ( PreludeSPDX "ref" ) )
                        ( Dhall.embed stringToDhall ( SPDX.licenseRef ref ) )
                    )
                    ( Dhall.embed ( maybeToDhall spdxLicenseExceptionIdToDhall ) exceptionMay )
                Just file ->
                  Expr.App
                    ( Expr.App
                        ( Expr.App
                            ( resolvePreludeVar ( PreludeSPDX "refWithFile" ) )
                            ( Dhall.embed stringToDhall ( SPDX.licenseRef ref ) )
                        )
                        ( Dhall.embed stringToDhall file )
                    )
                    ( Dhall.embed ( maybeToDhall spdxLicenseExceptionIdToDhall ) exceptionMay )
            SPDX.EOr a b ->
              Expr.App
                ( Expr.App
                    ( resolvePreludeVar ( PreludeSPDX  "or" ) )
                    ( go a )
                )
                ( go b )
            SPDX.EAnd a b ->
              Expr.App
                ( Expr.App
                    ( resolvePreludeVar ( PreludeSPDX "and" ) )
                    ( go a )
                )
                ( go b )
        in go
    , Dhall.declared =
        resolveType TypeSPDX
    }

spdxLicenseIdToDhall :: Dhall.InputType SPDX.LicenseId
spdxLicenseIdToDhall =
  Dhall.InputType
    { Dhall.embed = \ident ->
        Expr.Var "types" `Expr.Field` "LicenseId" `Expr.Field` identName ident
    , Dhall.declared =
        Expr.Var "types" `Expr.Field` "LicenseId"
    }

  where
  licenseIdType = resolveType TypeLicenseId
  identName :: SPDX.LicenseId -> StrictText.Text
  identName e =
    StrictText.pack ( show e )

spdxLicenseExceptionIdToDhall :: Dhall.InputType SPDX.LicenseExceptionId
spdxLicenseExceptionIdToDhall =
  Dhall.InputType
    { Dhall.embed = \ident ->
        Expr.Var "types" `Expr.Field` "LicenseExceptionId" `Expr.Field` identName ident
    , Dhall.declared =
        Expr.Var "types" `Expr.Field` "LicenseExceptionId"
    }

  where
    licenseExIdType = resolveType TypeLicenseExceptionId
    identName :: SPDX.LicenseExceptionId -> StrictText.Text
    identName e =
      StrictText.pack ( show e )
--}


maybeToDhall :: Dhall.InputType a -> Dhall.InputType ( Maybe a )
maybeToDhall t =
  Dhall.InputType
    { Dhall.embed =
        \a -> case a of
            Nothing -> Expr.App Expr.None (Dhall.declared t)
            Just x  -> Expr.Some ( Dhall.embed t x )
    , Dhall.declared = Expr.App Expr.Optional ( Dhall.declared t )
    }


listOf :: Dhall.InputType a -> Dhall.InputType [ a ]
listOf t =
  Dhall.InputType
    { Dhall.embed =
        \a ->
          Expr.ListLit
            ( foldl ( \_ _ -> Nothing ) ( Just ( Expr.App Expr.List ( Dhall.declared t ) ) ) a )
            ( foldMap ( pure . Dhall.embed t ) a )
    , Dhall.declared = Expr.App Expr.List ( Dhall.declared t )
    }


compiler :: Dhall.InputType ( Cabal.CompilerFlavor, Cabal.VersionRange )
compiler =
  runRecordInputType
    ( mconcat
        [ recordField "compiler" ( contramap fst compilerFlavor )
        , recordField "version" ( contramap snd versionRange )
        ]
    )


compilerFlavor :: Dhall.InputType Cabal.CompilerFlavor
compilerFlavor =
  let
    compilerType = resolveType TypeCompiler
    nullary k = compilerType `Expr.Field` k
    appCompiler k v = Expr.App ( nullary k ) v

  in
  Dhall.InputType
    { Dhall.embed = \case
        Cabal.Eta ->
          nullary "Eta"

        Cabal.GHC ->
          nullary "GHC"

        Cabal.GHCJS ->
          nullary "GHCJS"

        Cabal.HBC ->
          nullary "HBC"

        Cabal.HaskellSuite v ->
          appCompiler "HaskellSuite"
          ( Expr.Record ( Map.singleton "_1" ( dhallString v ) ) )

        Cabal.Helium ->
          nullary "Helium"

        Cabal.Hugs ->
          nullary "Hugs"

        Cabal.JHC ->
          nullary "JHC"

        Cabal.LHC ->
          nullary "LHC"

        Cabal.NHC ->
          nullary "NHC"

        Cabal.OtherCompiler v ->
          appCompiler "OtherCompiler"
          ( Expr.Record ( Map.singleton "_1" ( dhallString v ) ) )

        Cabal.UHC ->
          nullary "UHC"

        Cabal.YHC ->
          nullary "YHC"
    , Dhall.declared = compilerType
    }


intervalVersionRange :: Dhall.InputType Cabal.VersionRange
intervalVersionRange = Dhall.InputType 
    { Dhall.embed =
        \case
          and@(Cabal.IntersectVersionRanges _ _) ->
            viaInterval and

          or@(Cabal.UnionVersionRanges _ _) ->
            viaInterval or

          vr -> Dhall.embed versionRange vr
    
    , Dhall.declared = resolveType TypeVersionRange
    }
    where viaInterval vr =
             let vis = Cabal.versionIntervals
                      ( Cabal.toVersionIntervals vr )
                 vis' = map ( StrictText.pack . show . Cabal.disp ) vis

             in Expr.App ( resolveVersionRange IntervalVersionRange )
                         -- workaround https://github.com/dhall-lang/dhall-haskell/issues/1254
                         (Expr.Annot
                           ( Expr.ListLit Nothing
                             (fmap (\t-> Expr.TextLit (Dhall.Core.Chunks [] t))
                               (Seq.fromList vis')))
                           (Expr.App Expr.List Expr.Text))

versionRange :: Dhall.InputType Cabal.VersionRange
versionRange =
  Dhall.InputType
    { Dhall.embed =
        \versionRange0 ->
          let
            go = Cabal.foldVersionRange
              -- AnyVersion
              ( resolveVersionRange AnyVersion )
              -- ThisVersion
              ( \v -> Expr.App
                  ( resolveVersionRange ThisVersion )
                  ( Dhall.embed versionToDhall v )
              )
              -- LaterVersion
              ( \v -> Expr.App
                  ( resolveVersionRange LaterVersion )
                  ( Dhall.embed versionToDhall v )
              )
              -- EarlierVersion
              ( \v -> Expr.App
                  ( resolveVersionRange EarlierVersion )
                  ( Dhall.embed versionToDhall v )
              )
              -- UnionVersionRanges
              ( \a b -> Expr.App
                  ( Expr.App
                      ( resolveVersionRange UnionVersionRanges )
                      a
                  )
                  b
              )
              -- IntersectVersionRanges
              ( \a b -> Expr.App
                  ( Expr.App
                      ( resolveVersionRange IntersectVersionRanges )
                      a
                  )
                  b
              )

          in
          go ( Cabal.fromVersionIntervals ( Cabal.toVersionIntervals versionRange0 ) )
    , Dhall.declared = resolveType TypeVersionRange
    }


sourceRepo :: Dhall.InputType Cabal.SourceRepo
sourceRepo =
  ( runRecordInputTypeWithDefault SourceRepo sourceRepoDefault
      ( mconcat
          [ recordField "kind" ( contramap Cabal.repoKind repoKind )
          , recordField "type" ( contramap Cabal.repoType ( maybeToDhall repoType ) )
          , recordField "location" ( contramap Cabal.repoLocation ( maybeToDhall stringToDhall ) )
          , recordField "module" ( contramap Cabal.repoModule ( maybeToDhall stringToDhall ) )
          , recordField "branch" ( contramap Cabal.repoBranch ( maybeToDhall stringToDhall ) )
          , recordField "tag" ( contramap Cabal.repoTag ( maybeToDhall stringToDhall ) )
          , recordField "subdir" ( contramap Cabal.repoSubdir ( maybeToDhall stringToDhall ) )
          ]
      )
  )
  { Dhall.declared =
      resolveType TypeSourceRepo
  }


repoKind :: Dhall.InputType Cabal.RepoKind
repoKind =
  Dhall.InputType
    { Dhall.embed = \case
        Cabal.RepoThis ->
          repoKindType `Expr.Field` "RepoThis"
        Cabal.RepoHead ->
          repoKindType `Expr.Field` "RepoHead"
        Cabal.RepoKindUnknown str ->
          Expr.App
            ( repoKindType `Expr.Field` "RepoThis" )
            ( Expr.RecordLit ( Map.singleton "_1" ( dhallString str ) ) )
    , Dhall.declared = repoKindType
    }
  where repoKindType = resolveType TypeRepoKind

repoType :: Dhall.InputType Cabal.RepoType
repoType =
  Dhall.InputType
    { Dhall.embed = \case
        Cabal.Darcs ->
          constr "Darcs"
        Cabal.Git ->
          constr "Git"
        Cabal.SVN ->
          constr "SVN"
        Cabal.CVS ->
          constr "CVS"
        Cabal.Mercurial ->
          constr "Mercurial"
        Cabal.GnuArch ->
          constr "GnuArch"
        Cabal.Monotone ->
          constr "Monotone"
        Cabal.Bazaar ->
          constr "Bazaar"
        Cabal.OtherRepoType str ->
          Expr.App
            ( constr "OtherRepoType" )
            ( Expr.RecordLit ( Map.singleton "_1" ( dhallString str ) ) )
    , Dhall.declared = repoTypeType
    }
  where
    repoTypeType = resolveType TypeRepoType
    constr name = repoTypeType `Expr.Field` name


specVersion :: Dhall.InputType ( Either Cabal.Version Cabal.VersionRange )
specVersion =
  Dhall.InputType
    { Dhall.embed = either ( Dhall.embed versionToDhall ) ( error "Only exact cabal-versions are supported" )
    , Dhall.declared = Dhall.declared versionToDhall
    }


buildType :: Dhall.InputType Cabal.BuildType
buildType =
  Dhall.InputType
    { Dhall.embed = \case
        Cabal.Simple ->
          buildTypeType `Expr.Field` "Simple"

        Cabal.Configure ->
          buildTypeType `Expr.Field` "Configure"

        Cabal.Custom ->
          buildTypeType `Expr.Field` "Custom"

        Cabal.Make ->
          buildTypeType `Expr.Field` "Make"

        Cabal.UnknownBuildType unknown ->
           error ( "Unable to embed Cabal.UnknownBuildType " ++ unknown ) 
        
    , Dhall.declared = buildTypeType
    }
  where buildTypeType = resolveType TypeBuildType

setupBuildInfo :: Dhall.InputType Cabal.SetupBuildInfo
setupBuildInfo =
  ( runRecordInputType
      ( mconcat
          [ recordField "setup-depends" ( contramap Cabal.setupDepends ( listOf dependency ) )
          ]
      )
  )
    { Dhall.declared =
        Expr.Var "types" `Expr.Field` "SetupBuildInfo"
    }


{--
libraryName :: Dhall.InputType Cabal.LibraryName
libraryName =
  Dhall.InputType
    { Dhall.embed = \case
        Cabal.LMainLibName ->
          Expr.Var "types" `Expr.Field` "LibraryName" `Expr.Field` "main-library"
        Cabal.LSubLibName c ->
          Expr.App
            ( Expr.Var "types" `Expr.Field` "LibraryName" `Expr.Field` "sub-library" )
            ( Dhall.embed unqualComponentName c )
    , Dhall.declared =
        Expr.Var "types" `Expr.Field` "LibraryName"
    }
--}

dependency :: Dhall.InputType Cabal.Dependency
dependency =
  ( runRecordInputType
    ( mconcat
        [ recordField "package" ( contramap ( \( Cabal.Dependency p _ ) -> p ) packageNameToDhall )
        , recordField "bounds" ( contramap ( \( Cabal.Dependency _ a ) -> a ) intervalVersionRange )
        ]
    )
  )
    { Dhall.declared =
        Expr.Var "types" `Expr.Field` "Dependency"
    }


flag :: Dhall.InputType Cabal.Flag
flag =
  runRecordInputType
    ( mconcat
        [ recordField "name" ( contramap Cabal.flagName flagName )
        , recordField "default" ( contramap Cabal.flagDefault Dhall.inject )
        , recordField "description" ( contramap Cabal.flagDescription stringToDhall )
        , recordField "manual" ( contramap Cabal.flagManual Dhall.inject )
        ]
    )


flagName :: Dhall.InputType Cabal.FlagName
flagName =
  contramap Cabal.unFlagName stringToDhall


library :: Dhall.InputType Cabal.Library
library =
  ( runRecordInputTypeWithDefault 
      Library 
      libraryDefault
      ( mconcat
          [ contramap Cabal.libBuildInfo buildInfoRecord
          , recordField
              "exposed-modules"
              ( contramap Cabal.exposedModules ( listOf moduleName ) )
          , recordField
              "reexported-modules"
              ( contramap Cabal.reexportedModules ( listOf moduleReexport ) )
          , recordField
              "signatures"
              ( contramap Cabal.signatures ( listOf moduleName ) )
{--
              , recordField
              "visibility"
              ( contramap Cabal.libVisibility libraryVisibility )
--}
              ]
      )
  )
    { Dhall.declared = resolveType TypeLibrary
    }


unifyCondTree
  :: ( Monoid a )
  => Cabal.CondTree v x a
  -> ConfigTree ( Cabal.Condition v ) a
unifyCondTree =
  let
    branch
      :: ( Monoid a )
      => Cabal.CondBranch v x a
      -> ConfigTree ( Cabal.Condition v ) a
    branch ( Cabal.CondBranch cond true false ) =
      Branch cond ( tree true ) ( maybe mempty tree false )

    tree
      :: ( Monoid a )
      => Cabal.CondTree v x a
      -> ConfigTree ( Cabal.Condition v ) a
    tree ( Cabal.CondNode acc _ branches) =
      return acc `mappend` foldMap branch branches
  in
  tree


condTree
  :: ( Monoid a )
  => Dhall.InputType a
  -> Dhall.InputType ( Cabal.CondTree Cabal.ConfVar x a )
condTree t =
  let
    go = \case
      Leaf a ->
        Dhall.embed t a

      Branch cond a b ->
        Expr.BoolIf
          ( Dhall.embed condBranchCondition cond )
          ( go a )
          ( go b )

    configRecord =
      resolveType TypeConfig

  in
  Dhall.InputType
    { Dhall.embed =
        Expr.Lam "config" configRecord
          . go
          . unifyCondTree
    , Dhall.declared =
        Expr.Pi "_" configRecord ( Dhall.declared t )
    }


moduleName :: Dhall.InputType Cabal.ModuleName
moduleName =
  contramap ( show . Cabal.disp ) stringToDhall


condBranchCondition :: Dhall.InputType (Cabal.Condition Cabal.ConfVar)
condBranchCondition =
  Dhall.InputType
    { Dhall.declared = Expr.Bool
    , Dhall.embed =
        \a ->
          case a of
            Cabal.Var ( Cabal.OS os0 ) ->
              Expr.App ( Expr.Field ( Expr.Var "config" ) "os" ) ( Dhall.embed os os0 )

            Cabal.Var ( Cabal.Arch arch0 ) ->
              Expr.App ( Expr.Field ( Expr.Var "config" ) "arch" ) ( Dhall.embed arch arch0 )

            Cabal.Var ( Cabal.Flag flagName0 ) ->
              Expr.App ( Expr.Field ( Expr.Var "config" ) "flag" ) ( Dhall.embed flagName flagName0 )

            Cabal.Var ( Cabal.Impl c v ) ->
              Expr.App ( Expr.App ( Expr.Field ( Expr.Var "config" ) "impl" ) ( Dhall.embed compilerFlavor c ) ) ( Dhall.embed versionRange v )

            Cabal.Lit b ->
              Expr.BoolLit b

            Cabal.CNot c ->
              Expr.BoolEQ ( Expr.BoolLit False ) ( Dhall.embed condBranchCondition c )

            Cabal.CAnd a b ->
              Expr.BoolAnd ( Dhall.embed condBranchCondition a ) ( Dhall.embed condBranchCondition b )

            Cabal.COr a b ->
              Expr.BoolOr ( Dhall.embed condBranchCondition a ) ( Dhall.embed condBranchCondition b )
    }


os :: Dhall.InputType Cabal.OS
os =
  Dhall.InputType
    { Dhall.embed = \case
        Cabal.Linux      -> os "Linux"
        Cabal.Windows    -> os "Windows"
        Cabal.OSX        -> os "OSX"
        Cabal.FreeBSD    -> os "FreeBSD"
        Cabal.OpenBSD    -> os "OpenBSD"
        Cabal.NetBSD     -> os "NetBSD"
        Cabal.DragonFly  -> os "DragonFly"
        Cabal.Solaris    -> os "Solaris"
        Cabal.AIX        -> os "AIX"
        Cabal.HPUX       -> os "HPUX"
        Cabal.IRIX       -> os "IRIX"
        Cabal.HaLVM      -> os "HaLVM"
        Cabal.Hurd       -> os "Hurd"
        Cabal.IOS        -> os "IOS"
        Cabal.Android    -> os "Android"
        Cabal.Ghcjs      -> os "Ghcjs"
        Cabal.OtherOS os ->
            appOS "OtherOS"
            ( Expr.RecordLit ( Map.singleton "_1" ( dhallString os ) ) )

    , Dhall.declared = osType
    }
  where osType = resolveType TypeOS
        os name = osType `Expr.Field` name
        appOS name = Expr.App ( os name )
        

arch :: Dhall.InputType Cabal.Arch
arch =
  Dhall.InputType
    { Dhall.embed = \case
        Cabal.I386 ->
          arch "I386"
        Cabal.X86_64 ->
          arch "X86_64"
        Cabal.PPC ->
          arch "PPC"
        Cabal.PPC64 ->
          arch "PPC64"
        Cabal.Sparc ->
          arch "Sparc"
        Cabal.Arm ->
          arch "Arm"
        Cabal.Mips ->
          arch "Mips"
        Cabal.SH ->
          arch "SH"
        Cabal.IA64 ->
          arch "IA64"
        Cabal.S390 ->
          arch "S390"
        Cabal.Alpha ->
          arch "Alpha"
        Cabal.Hppa ->
          arch "Hppa"
        Cabal.Rs6000 ->
          arch "Rs6000"
        Cabal.M68k ->
          arch "M68k"
        Cabal.Vax ->
          arch "Vax"
        Cabal.JavaScript ->
          arch "JavaScript"
--        Cabal.AArch64 ->
--          arch "AArch64"
        Cabal.OtherArch s ->
          Expr.App
            ( arch "OtherArch" )
            ( Expr.RecordLit ( Map.singleton "_1" ( dhallString s ) ) )
    , Dhall.declared =
        Expr.Var "types" `Expr.Field` "Arch"
    }
  where
  arch name =
    Expr.Var "types" `Expr.Field` "Arch" `Expr.Field` name


buildInfoRecord :: RecordInputType Cabal.BuildInfo
buildInfoRecord =
  mconcat
    [ recordField "buildable" ( contramap Cabal.buildable Dhall.inject )
    , recordField "build-tools" ( contramap Cabal.buildTools ( listOf legacyExeDependency ) )
    , recordField "build-tool-depends" ( contramap Cabal.buildToolDepends ( listOf exeDependency ) )
    , recordField "cpp-options" ( contramap Cabal.cppOptions ( listOf stringToDhall ) )
    , recordField "cc-options" ( contramap Cabal.ccOptions ( listOf stringToDhall ) )
    , recordField "ld-options" ( contramap Cabal.ldOptions ( listOf stringToDhall ) )
    , recordField "pkgconfig-depends" ( contramap Cabal.pkgconfigDepends ( listOf pkgconfigDependency ) )
    , recordField "frameworks" ( contramap Cabal.frameworks ( listOf stringToDhall ) )
    , recordField "extra-framework-dirs" ( contramap Cabal.extraFrameworkDirs ( listOf stringToDhall ) )
    , recordField "c-sources" ( contramap Cabal.cSources ( listOf stringToDhall ) )
    , recordField "js-sources" ( contramap Cabal.jsSources ( listOf stringToDhall ) )
    , recordField "hs-source-dirs" ( contramap Cabal.hsSourceDirs ( listOf stringToDhall ) )
    , recordField "other-modules" ( contramap Cabal.otherModules ( listOf moduleName ) )
    , recordField "autogen-modules" ( contramap Cabal.autogenModules ( listOf moduleName ) )
    , recordField "default-language" ( contramap Cabal.defaultLanguage ( maybeToDhall language ) )
    , recordField "other-languages" ( contramap Cabal.otherLanguages ( listOf language ) )
    , recordField "default-extensions" ( Cabal.defaultExtensions >$< listOf extension )
    , recordField "other-extensions" ( Cabal.otherExtensions >$< listOf extension )
    --    , recordField "extra-libraries" ( Cabal.extraLibs >$< listOf stringToDhall )
    , recordField "maven-depends" ( Cabal.extraLibs >$< listOf stringToDhall )
    , recordField "extra-ghci-libraries" ( Cabal.extraGHCiLibs >$< listOf stringToDhall )
    , recordField "extra-lib-dirs" ( Cabal.extraLibDirs >$< listOf stringToDhall )
    , recordField "include-dirs" ( Cabal.includeDirs >$< listOf stringToDhall )
    , recordField "includes" ( Cabal.includes >$< listOf stringToDhall )
    , recordField "install-includes" ( Cabal.installIncludes >$< listOf stringToDhall )
    , recordField "compiler-options" ( Cabal.options >$< compilerOptions )
    , recordField "profiling-options" ( Cabal.profOptions >$< compilerOptions )
    , recordField "shared-options" ( Cabal.sharedOptions >$< compilerOptions )
    --    , recordField "static-options" ( Cabal.staticOptions >$< compilerOptions )
    , recordField "build-depends" ( Cabal.targetBuildDepends >$< listOf dependency )
    , recordField "mixins" ( Cabal.mixins >$< listOf mixin )
    {--
    , recordField "asm-options" ( Cabal.asmOptions >$< listOf stringToDhall)
    , recordField "asm-sources" ( Cabal.asmSources >$< listOf stringToDhall)
    , recordField "cmm-options" ( Cabal.cmmOptions >$< listOf stringToDhall )
    , recordField "cmm-sources" ( Cabal.cmmSources >$< listOf stringToDhall )
    , recordField "cxx-options" ( Cabal.cxxOptions >$< listOf stringToDhall )
    , recordField "cxx-sources" ( Cabal.cxxSources >$< listOf stringToDhall)
    , recordField "virtual-modules" ( Cabal.virtualModules >$< listOf moduleName )
    , recordField "extra-lib-flavours" ( Cabal.extraLibFlavours >$< listOf stringToDhall )
    , recordField "extra-bundled-libs" ( Cabal.extraBundledLibs >$< listOf stringToDhall )
    , recordField "autogen-includes" ( Cabal.autogenIncludes >$< listOf stringToDhall )
    , recordField "extra-dyn-lib-flavours" ( Cabal.extraDynLibFlavours >$< listOf stringToDhall )
    --}
    ]


moduleReexport :: Dhall.InputType Cabal.ModuleReexport
moduleReexport =
  runRecordInputType
    ( mconcat
        [ recordField "original"
             ( ( \a -> ( Cabal.moduleReexportOriginalPackage a, Cabal.moduleReexportOriginalName a ) ) >$<
                runRecordInputType
                 ( mconcat
                     [ recordField "package" ( fst >$< maybeToDhall packageNameToDhall )
                     , recordField "name" ( snd >$< moduleName )
                     ]
                 )
             )
        , recordField "name" ( Cabal.moduleReexportName >$< moduleName )
        ]
    )


legacyExeDependency :: Dhall.InputType Cabal.LegacyExeDependency
legacyExeDependency =
  runRecordInputType
    ( mconcat
        [ recordField "exe" ( ( \( Cabal.LegacyExeDependency exe _ ) -> exe ) >$< stringToDhall )
        , recordField "version" ( ( \( Cabal.LegacyExeDependency _ version ) -> version ) >$< versionRange )
        ]
    )

exeDependency :: Dhall.InputType Cabal.ExeDependency
exeDependency =
  runRecordInputType
    ( mconcat
        [ recordField "package" ( ( \( Cabal.ExeDependency packageName _ _ ) -> packageName ) >$< packageNameToDhall )
        , recordField "component" ( ( \( Cabal.ExeDependency _ component _ ) -> component ) >$< unqualComponentName )
        , recordField "version" ( ( \( Cabal.ExeDependency _ _ version ) -> version ) >$< intervalVersionRange )
        ]
    )


unqualComponentName :: Dhall.InputType Cabal.UnqualComponentName
unqualComponentName =
  show . Cabal.disp >$< stringToDhall


pkgconfigDependency :: Dhall.InputType Cabal.PkgconfigDependency
pkgconfigDependency =
  runRecordInputType
    ( mconcat
        [ recordField "name" ( ( \( Cabal.PkgconfigDependency a _version ) -> a ) >$< pkgconfigName )
        , recordField "version" ( ( \( Cabal.PkgconfigDependency _name a ) -> a ) >$< intervalVersionRange )
        ]
    )


pkgconfigName :: Dhall.InputType Cabal.PkgconfigName
pkgconfigName =
  show . Cabal.disp >$< stringToDhall

{--
-- PkgconfigVersion is restricted to ASCII-only characters.
pkgconfigVersion :: Dhall.InputType Cabal.PkgconfigVersion
pkgconfigVersion = (\ ( Cabal.PkgconfigVersion a ) -> StrictText.decodeLatin1 a ) >$< Dhall.inject

pkgconfigVersionRange :: Dhall.InputType Cabal.PkgconfigVersionRange
pkgconfigVersionRange =  Dhall.InputType
    { Dhall.embed =
          let
            go = \case
              Cabal.PcAnyVersion ->
                Expr.Var "prelude" `Expr.Field` "pkg-config" `Expr.Field` "anyVersion"
              Cabal.PcThisVersion v ->
                Expr.App
                  ( Expr.Var "prelude" `Expr.Field` "pkg-config" `Expr.Field` "thisVersion" )
                  ( Dhall.embed pkgconfigVersion v )
              Cabal.PcLaterVersion v ->
                Expr.App
                  ( Expr.Var "prelude" `Expr.Field` "pkg-config" `Expr.Field` "laterVersion" )
                  ( Dhall.embed pkgconfigVersion v )
              Cabal.PcEarlierVersion v ->
                Expr.App
                  ( Expr.Var "prelude" `Expr.Field` "pkg-config" `Expr.Field` "earlierVersion" )
                  ( Dhall.embed pkgconfigVersion v )
              Cabal.PcOrLaterVersion v ->
                Expr.App
                  ( Expr.Var "prelude" `Expr.Field` "pkg-config" `Expr.Field` "orLaterVersion" )
                  ( Dhall.embed pkgconfigVersion v )
              Cabal.PcOrEarlierVersion v ->
                Expr.App
                  ( Expr.Var "prelude" `Expr.Field` "pkg-config" `Expr.Field` "orEarlierVersion" )
                  ( Dhall.embed pkgconfigVersion v )
              Cabal.PcUnionVersionRanges a b ->
                Expr.App
                  ( Expr.App
                    ( Expr.Var "prelude" `Expr.Field` "pkg-config" `Expr.Field` "unionVersionRanges" )
                    ( go a )
                  )
                  ( go b )
              Cabal.PcIntersectVersionRanges a b ->
                Expr.App
                  ( Expr.App
                    ( Expr.Var "prelude" `Expr.Field` "pkg-config" `Expr.Field` "intersectVersionRanges" )
                    ( go a )
                  )
                  ( go b )
          in
          go
    , Dhall.declared =
        Expr.Var "types" `Expr.Field` "PkgconfigVersionRange"
    }
--}

language :: Dhall.InputType Cabal.Language
language =
  Dhall.InputType
    { Dhall.embed = \case
        Cabal.Haskell2010 ->
          lang "Haskell2010"
        Cabal.Haskell98 ->
          lang "Haskell98"
        Cabal.UnknownLanguage s ->
          Expr.App
            ( lang "UnknownLanguage" )
            ( Expr.RecordLit ( Map.singleton "_1" ( dhallString s ) ) )
    , Dhall.declared =
        langType
    }
  where
    langType = resolveType TypeLanguage
    lang name = langType  `Expr.Field` name


extension :: Dhall.InputType Cabal.Extension
extension =
  Dhall.InputType
    { Dhall.embed =
        \a ->
          case a of
            Cabal.EnableExtension ext ->
              extWith True ext

            Cabal.DisableExtension ext ->
              extWith False ext

            _ ->
              error "Unknown extension"
    , Dhall.declared = extType
    }

  where

  extName :: Cabal.KnownExtension -> StrictText.Text
  extName e = StrictText.pack ( show e )

  extType = resolveType TypeExtension
  
  extWith trueFalse ext = Expr.App
                          ( extType `Expr.Field` extName ext )
                          ( Expr.BoolLit trueFalse )


compilerOptions :: Dhall.InputType [ ( Cabal.CompilerFlavor, [ String ] ) ]
compilerOptions =
  Dhall.InputType
    { Dhall.embed = \xs ->
        withDefault CompilerOptions compilerOptionsDefault
          ( Expr.RecordLit
              ( Map.fromList
                  ( map
                      ( \( c, opts ) ->
                          ( StrictText.pack ( show c )
                          , Expr.ListLit ( Just ( Expr.App Expr.List Expr.Text ) ) ( dhallString <$> Seq.fromList opts )
                          )
                      )
                      xs
                  )
              )
          )
    , Dhall.declared = resolveType TypeCompilerOption 
    }


mixin :: Dhall.InputType Cabal.Mixin
mixin =
  ( runRecordInputType
      ( mconcat
          [ recordField "package" ( Cabal.mixinPackageName >$< packageNameToDhall )
          , recordField "renaming" ( Cabal.mixinIncludeRenaming >$< includeRenaming )
          ]
      )
  )
    { Dhall.declared = resolveType TypeMixin }


includeRenaming :: Dhall.InputType Cabal.IncludeRenaming
includeRenaming =
  runRecordInputType
    ( mconcat
        [ recordField "provides" ( Cabal.includeProvidesRn >$< moduleRenaming )
        , recordField "requires" ( Cabal.includeRequiresRn >$< moduleRenaming )
        ]
    )


moduleRenaming :: Dhall.InputType Cabal.ModuleRenaming
moduleRenaming =
  Dhall.InputType
    { Dhall.embed =
        \a ->
          case a of
            Cabal.ModuleRenaming renamed ->
              Expr.App
                ( moduleRenamingType `Expr.Field` "renaming" )
                ( Expr.ListLit
                    Nothing
                    ( fmap
                        (\ ( src, dst ) ->
                           Expr.RecordLit
                             ( Map.fromList
                                 [ ( "rename", Dhall.embed moduleName src )
                                 , ( "to", Dhall.embed moduleName dst )
                                 ]
                             )
                        )
                        ( Seq.fromList renamed )
                    )
                )
            Cabal.DefaultRenaming ->
              moduleRenamingType `Expr.Field` "default"
            Cabal.HidingRenaming hidden ->
              Expr.App
                ( moduleRenamingType `Expr.Field` "hiding" )
                ( Expr.ListLit
                    Nothing
                    ( Dhall.embed moduleName <$> Seq.fromList hidden )
                )
    , Dhall.declared = moduleRenamingType
    }
  where moduleRenamingType = resolveType TypeModuleRenaming

benchmark :: Dhall.InputType Cabal.Benchmark
benchmark =
  (  runRecordInputTypeWithDefault Benchmark benchmarkDefault
       ( mconcat
           [ recordField "main-is" ( ( \( Cabal.BenchmarkExeV10 _ s ) -> s ) . Cabal.benchmarkInterface >$< stringToDhall )
           , Cabal.benchmarkBuildInfo >$< buildInfoRecord
           ]
       )
  )
    { Dhall.declared = resolveType TypeBenchmark
    }


testSuite :: Dhall.InputType Cabal.TestSuite
testSuite =
  ( runRecordInputTypeWithDefault TestSuite testSuiteDefault
      ( mconcat
          [ recordField "type" ( Cabal.testInterface >$< testSuiteInterface )
          , Cabal.testBuildInfo >$< buildInfoRecord
          ]
      )
  )
  { Dhall.declared = resolveType TypeTestSuite }


testSuiteInterface :: Dhall.InputType Cabal.TestSuiteInterface
testSuiteInterface =
  Dhall.InputType
    { Dhall.embed = \case
        Cabal.TestSuiteExeV10 _ main ->
          Expr.App
            ( interface "exitcode-stdio" )
            ( Dhall.embed
              ( runRecordInputType ( recordField "main-is" stringToDhall ) )
              main
            )
        Cabal.TestSuiteLibV09 _ m ->
          Expr.App
            ( interface "detailed" )
            ( Dhall.embed
              ( runRecordInputType ( recordField "module" moduleName ) )
              m
            )
    , Dhall.declared =
        Expr.Var "types" `Expr.Field` "TestType"
    }
  where
  interface name =
    Expr.Var "types" `Expr.Field` "TestType" `Expr.Field` name


executable :: Dhall.InputType Cabal.Executable
executable =
  ( runRecordInputTypeWithDefault Executable executableDefault
      ( mconcat
          [ recordField "main-is" ( Cabal.modulePath >$< stringToDhall )
          , Cabal.buildInfo >$< buildInfoRecord
          ]
      )
  )
    { Dhall.declared = resolveType TypeExecutable }

{-
executableScope :: Dhall.InputType Cabal.ExecutableScope
executableScope =
  Dhall.InputType
    { Dhall.embed = \case
        Cabal.ExecutablePublic ->
            Expr.Var "types" `Expr.Field` "Scope" `Expr.Field` "Public"
        Cabal.ExecutablePrivate ->
            Expr.Var "types" `Expr.Field` "Scope" `Expr.Field` "Private"
    , Dhall.declared =
        typeScope
    }
  where typeScope = resolveType TypeScope
-}

foreignLibrary :: Dhall.InputType Cabal.ForeignLib
foreignLibrary =
  ( runRecordInputType
      ( mconcat
          [ recordField "type" ( Cabal.foreignLibType >$< foreignLibType )
          , recordField "options" ( Cabal.foreignLibOptions >$< ( listOf foreignLibOption ) )
          , Cabal.foreignLibBuildInfo >$< buildInfoRecord
          , recordField "lib-version-info" ( Cabal.foreignLibVersionInfo >$< maybeToDhall versionInfo )
          , recordField "lib-version-linux" ( Cabal.foreignLibVersionLinux >$< maybeToDhall versionToDhall )
          , recordField "mod-def-files" ( Cabal.foreignLibModDefFile >$< listOf stringToDhall )
          ]
      )
  )
  { Dhall.declared = resolveType TypeForeignLibrary }


versionInfo :: Dhall.InputType Cabal.LibVersionInfo
versionInfo =
  Cabal.libVersionInfoCRA >$<
  runRecordInputType
    ( mconcat
        [ recordField "current" ( ( \( a, _, _ ) -> fromIntegral a :: Natural ) >$< ( Dhall.inject ) )
        , recordField "revision" ( ( \( _, a, _ ) -> fromIntegral a :: Natural ) >$< ( Dhall.inject ) )
        , recordField "age" ( ( \( _, _, a ) -> fromIntegral a :: Natural ) >$< ( Dhall.inject ) )
        ]
    )


foreignLibOption :: Dhall.InputType Cabal.ForeignLibOption
foreignLibOption =
  Dhall.InputType
    { Dhall.embed = \case
        Cabal.ForeignLibStandalone ->
          Expr.Var "types" `Expr.Field` "ForeignLibOption" `Expr.Field` "Standalone"
    , Dhall.declared =
        Expr.Var "types" `Expr.Field` "ForeignLibOption"
    }


foreignLibType :: Dhall.InputType Cabal.ForeignLibType
foreignLibType =
  Dhall.InputType
    { Dhall.embed = \case
        Cabal.ForeignLibNativeShared ->
          ty "Shared"
        Cabal.ForeignLibNativeStatic ->
          ty "Static"
    , Dhall.declared =
        Expr.Var "types" `Expr.Field` "ForeignLibType"
    }
  where
  ty name =
    Expr.Var "types" `Expr.Field` "ForeignLibType" `Expr.Field` name
