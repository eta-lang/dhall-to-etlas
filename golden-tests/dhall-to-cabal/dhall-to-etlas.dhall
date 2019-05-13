let prelude = ./../../dhall/prelude.dhall

let types = ./../../dhall/types.dhall

let v = prelude.v

let pkg =
        λ(name : Text)
      → λ(version-range : types.VersionRange)
      → { bounds = version-range, package = name }

let pkgVer =
        λ(packageName : Text)
      → λ(minor : Text)
      → λ(major : Text)
      → pkg
        packageName
        ( prelude.intersectVersionRanges
          (prelude.orLaterVersion (v minor))
          (prelude.earlierVersion (v major))
        )

let deps =
      { etlas-cabal =
          pkgVer "etlas-cabal" "1.3.0.0" "1.4"
      , Diff =
          pkgVer "Diff" "0.3.4" "0.4"
      , base =
          pkgVer "base" "4.5" "5"
      , bytestring =
          pkgVer "bytestring" "0.10" "0.11"
      , containers =
          pkgVer "containers" "0.5" "0.6"
      , directory =
          pkgVer "directory" "1.3.0.2" "1.4"
      , dhall =
          pkgVer "dhall" "1.23.0" "1.24"
      , dhall-to-etlas =
          pkg "dhall-to-etlas" prelude.anyVersion
      , dhall-to-cabal =
          pkg "dhall-to-cabal" prelude.anyVersion
      , filepath =
          pkgVer "filepath" "1.4" "1.5"
      , insert-ordered-containers =
          pkgVer "insert-ordered-containers" "0.2.1.0" "0.3"
      , optparse-applicative =
          pkgVer "optparse-applicative" "0.13.2" "0.15"
      , prettyprinter =
          pkgVer "prettyprinter" "1.2.0.1" "1.3"
      , contravariant =
          pkgVer "contravariant" "1.4" "1.5"
      , hashable =
          pkgVer "hashable" "1.2.6.1" "1.3"
      , tasty =
          pkgVer "tasty" "0.11" "1.3"
      , tasty-golden =
          pkgVer "tasty-golden" "2.3" "2.4"
      , tasty-hunit =
          pkgVer "tasty-hunit" "0.10.0.1" "0.11"
      , text =
          pkgVer "text" "1.2" "1.3"
      , transformers =
          pkgVer "transformers" "0.2.0.0" "0.6"
      , formatting =
          pkgVer "formatting" "6.3.1" "6.4"
      , vector =
          pkgVer "vector" "0.11.0.0" "0.13"
      , semigroups =
          pkgVer "semigroups" "0.18.0" "0.19"
      }

let warning-options =
      [ "-Wall"
      , "-fno-warn-safe"
      , "-fno-warn-unsafe"
      , "-fno-warn-implicit-prelude"
      , "-fno-warn-missing-import-lists"
      , "-fno-warn-missing-local-sigs"
      , "-fno-warn-monomorphism-restriction"
      , "-fno-warn-name-shadowing"
      ]

in    prelude.utils.GitHub-project
      { owner = "eta-lang", repo = "dhall-to-etlas" }
    ⫽ { synopsis =
          "Compile Dhall expressions to Etlas files"
      , description =
          ''
          dhall-to-etlas takes Dhall expressions and compiles them into Etlas
          files. All of the features of Dhall are supported, such as let
          bindings and imports, and all features of Etlas are supported
          (including conditional stanzas).
          ''
      , category =
          "Distribution"
      , build-type =
          Some types.BuildType.Simple
      , maintainer =
          "atreyu.bbb@gmail.com"
      , author =
          "Ollie Charles <ollie@ocharles.org.uk>"
      , extra-source-files =
          [ "Changelog.md"
          , "README.md"
          , "dhall/SPDX/*.dhall"
          , "dhall/Version/*.dhall"
          , "dhall/VersionRange/*.dhall"
          , "dhall/defaults/*.dhall"
          , "dhall/*.dhall"
          , "dhall/types/*.dhall"
          , "dhall/types/SPDX/*.dhall"
          , "dhall/utils/*.dhall"
          , "golden-tests/dhall-to-cabal/*.dhall"
          , "golden-tests/dhall-to-cabal/*.cabal"
          , "golden-tests/cabal-to-dhall/*.dhall"
          , "golden-tests/cabal-to-dhall/*.cabal"
          ]
      , license =
          types.License.MIT
      , license-files =
          [ "LICENSE" ]
      , version =
          v "1.2.0.0"
      , cabal-version =
          v "1.12"
      , library =
          prelude.unconditional.library
          (   prelude.defaults.empty.Library
            ⫽ { build-depends =
                  [ deps.etlas-cabal
                  , deps.base
                  , deps.bytestring
                  , deps.containers
                  , deps.contravariant
                  , deps.dhall
                  , deps.hashable
                  , deps.insert-ordered-containers
                  , deps.text
                  , deps.transformers
                  , deps.vector
                  , deps.semigroups
                  ]
              , compiler-options =
                  prelude.defaults.CompilerOptions ⫽ { GHC = warning-options }
              , exposed-modules =
                  [ "DhallToCabal", "DhallLocation", "CabalToDhall" ]
              , hs-source-dirs =
                  [ "lib" ]
              , other-extensions =
                  [ types.Extension.GADTs True
                  , types.Extension.GeneralizedNewtypeDeriving True
                  , types.Extension.LambdaCase True
                  , types.Extension.OverloadedStrings True
                  , types.Extension.RecordWildCards True
                  ]
              , other-modules =
                  [ "DhallToCabal.ConfigTree"
                  , "DhallToCabal.Diff"
                  , "Dhall.Extra"
                  , "Paths_dhall_to_etlas"
                  ]
              , default-language =
                  Some types.Language.Haskell2010
              }
          )
      , executables =
          [ prelude.unconditional.executable
            "dhall-to-etlas"
            (   prelude.defaults.empty.Executable
              ⫽ { build-depends =
                    [ deps.etlas-cabal
                    , deps.base
                    , deps.dhall
                    , deps.dhall-to-etlas
                    , deps.insert-ordered-containers
                    , deps.optparse-applicative
                    , deps.prettyprinter
                    , deps.text
                    , deps.transformers
                    ]
                , compiler-options =
                    prelude.defaults.CompilerOptions ⫽ { GHC = warning-options }
                , hs-source-dirs =
                    [ "exe" ]
                , main-is =
                    "Main.hs"
                , other-extensions =
                    [ types.Extension.NamedFieldPuns True ]
                , other-modules =
                    [ "Paths_dhall_to_cabal" ]
                , default-language =
                    Some types.Language.Haskell2010
                }
            )
          , prelude.unconditional.executable
            "etlas-to-dhall"
            (   prelude.defaults.empty.Executable
              ⫽ { build-depends =
                    [ deps.base
                    , deps.dhall
                    , deps.bytestring
                    , deps.dhall-to-etlas
                    , deps.optparse-applicative
                    , deps.prettyprinter
                    , deps.text
                    ]
                , compiler-options =
                    prelude.defaults.CompilerOptions ⫽ { GHC = warning-options }
                , hs-source-dirs =
                    [ "cabal-to-dhall" ]
                , main-is =
                    "Main.hs"
                , other-extensions =
                    [ types.Extension.NamedFieldPuns True ]
                , other-modules =
                    [ "Paths_dhall_to_etlas" ]
                , default-language =
                    Some types.Language.Haskell2010
                }
            )
          , prelude.unconditional.executable
            "dhall-to-cabal-meta"
            (   prelude.defaults.empty.Executable
              ⫽ { build-depends =
                    [ deps.base
                    , deps.directory
                    , deps.dhall
                    , deps.dhall-to-etlas
                    , deps.filepath
                    , deps.optparse-applicative
                    , deps.prettyprinter
                    ]
                , hs-source-dirs =
                    [ "meta" ]
                , default-language =
                    Some types.Language.Haskell2010
                , compiler-options =
                    prelude.defaults.CompilerOptions ⫽ { GHC = warning-options }
                , main-is =
                    "Main.hs"
                }
            )
          ]
      , test-suites =
          [ prelude.unconditional.test-suite
            "golden-tests"
            (   prelude.defaults.empty.TestSuite
              ⫽ { build-depends =
                    [ deps.base
                    , deps.etlas-cabal
                    , deps.Diff
                    , deps.bytestring
                    , deps.dhall
                    , deps.dhall-to-etlas
                    , deps.filepath
                    , deps.prettyprinter
                    , deps.tasty
                    , deps.tasty-golden
                    , deps.text
                    ]
                , compiler-options =
                    prelude.defaults.CompilerOptions ⫽ { GHC = warning-options }
                , hs-source-dirs =
                    [ "golden-tests" ]
                , type =
                    types.TestType.exitcode-stdio { main-is = "GoldenTests.hs" }
                , default-language =
                    Some types.Language.Haskell2010
                }
            )
          , prelude.unconditional.test-suite
            "unit-tests"
            (   prelude.defaults.TestSuite
              ⫽ { build-depends =
                    [ deps.base
                    , deps.etlas-cabal
                    , deps.dhall
                    , deps.dhall-to-cabal
                    , deps.tasty
                    , deps.tasty-hunit
                    , deps.text
                    ]
                , compiler-options =
                    prelude.defaults.CompilerOptions ⫽ { GHC = warning-options }
                , hs-source-dirs =
                    [ "tests" ]
                , type =
                    types.TestType.exitcode-stdio { main-is = "Tests.hs" }
                , default-language =
                    Some types.Language.Haskell2010
                , other-modules =
                    [ "DhallToCabal.Tests" ]
                }
            )
          ]
      }
