let prelude = ./../../dhall/prelude.dhall

let types = ./../../dhall/types.dhall

in    prelude.defaults.Package
    ⫽ { name =
          "dhall-to-etlas"
      , version =
          prelude.v "1.2.0.0"
      , author =
          "Ollie Charles <ollie@ocharles.org.uk>"
      , bug-reports =
          "https://github.com/eta-lang/dhall-to-etlas/issues"
      , category =
          "Distribution"
      , description =
          ''
          dhall-to-etlas takes Dhall expressions and compiles them into Etlas
          files. All of the features of Dhall are supported, such as let
          bindings and imports, and all features of Etlas are supported
          (including conditional stanzas).
          ''
      , executables =
          [ { executable =
                  λ(config : types.Config)
                →   prelude.defaults.Executable
                  ⫽ { main-is =
                        "Main.hs"
                    , build-depends =
                        [ { bounds =
                              prelude.intervalVersionRange
                              ([ "[1.3.0.0,1.4)" ] : List Text)
                          , package =
                              "etlas-cabal"
                          }
                        , { bounds =
                              prelude.intervalVersionRange
                              ([ "[4.5,5)" ] : List Text)
                          , package =
                              "base"
                          }
                        , { bounds =
                              prelude.intervalVersionRange
                              ([ "[1.15.0,1.16)" ] : List Text)
                          , package =
                              "dhall"
                          }
                        , { bounds =
                              prelude.anyVersion
                          , package =
                              "dhall-to-etlas"
                          }
                        , { bounds =
                              prelude.intervalVersionRange
                              ([ "[0.2.1.0,0.3)" ] : List Text)
                          , package =
                              "insert-ordered-containers"
                          }
                        , { bounds =
                              prelude.intervalVersionRange
                              ([ "[0.13.2,0.15)" ] : List Text)
                          , package =
                              "optparse-applicative"
                          }
                        , { bounds =
                              prelude.intervalVersionRange
                              ([ "[1.2.0.1,1.3)" ] : List Text)
                          , package =
                              "prettyprinter"
                          }
                        , { bounds =
                              prelude.intervalVersionRange
                              ([ "[1.2,1.3)" ] : List Text)
                          , package =
                              "text"
                          }
                        , { bounds =
                              prelude.intervalVersionRange
                              ([ "[0.2.0.0,0.6)" ] : List Text)
                          , package =
                              "transformers"
                          }
                        ]
                    , compiler-options =
                          prelude.defaults.CompilerOptions
                        ⫽ { GHC =
                              [ "-Wall"
                              , "-fno-warn-safe"
                              , "-fno-warn-unsafe"
                              , "-fno-warn-implicit-prelude"
                              , "-fno-warn-missing-import-lists"
                              , "-fno-warn-missing-local-sigs"
                              , "-fno-warn-monomorphism-restriction"
                              , "-fno-warn-name-shadowing"
                              ] : List Text
                          }
                    , default-extensions =
                        [] : List types.Extension
                    , hs-source-dirs =
                        [ "exe" ]
                    , other-extensions =
                        [ types.Extension.NamedFieldPuns True ]
                    , other-modules =
                        [ "Paths_dhall_to_cabal" ]
                    }
            , name =
                "dhall-to-etlas"
            }
          , { executable =
                  λ(config : types.Config)
                →   prelude.defaults.Executable
                  ⫽ { main-is =
                        "Main.hs"
                    , build-depends =
                        [ { bounds =
                              prelude.intervalVersionRange
                              ([ "[4.5,5)" ] : List Text)
                          , package =
                              "base"
                          }
                        , { bounds =
                              prelude.intervalVersionRange
                              ([ "[1.15.0,1.16)" ] : List Text)
                          , package =
                              "dhall"
                          }
                        , { bounds =
                              prelude.intervalVersionRange
                              ([ "[0.10,0.11)" ] : List Text)
                          , package =
                              "bytestring"
                          }
                        , { bounds =
                              prelude.anyVersion
                          , package =
                              "dhall-to-etlas"
                          }
                        , { bounds =
                              prelude.intervalVersionRange
                              ([ "[0.13.2,0.15)" ] : List Text)
                          , package =
                              "optparse-applicative"
                          }
                        , { bounds =
                              prelude.intervalVersionRange
                              ([ "[1.2.0.1,1.3)" ] : List Text)
                          , package =
                              "prettyprinter"
                          }
                        , { bounds =
                              prelude.intervalVersionRange
                              ([ "[1.2,1.3)" ] : List Text)
                          , package =
                              "text"
                          }
                        ]
                    , compiler-options =
                          prelude.defaults.CompilerOptions
                        ⫽ { GHC =
                              [ "-Wall"
                              , "-fno-warn-safe"
                              , "-fno-warn-unsafe"
                              , "-fno-warn-implicit-prelude"
                              , "-fno-warn-missing-import-lists"
                              , "-fno-warn-missing-local-sigs"
                              , "-fno-warn-monomorphism-restriction"
                              , "-fno-warn-name-shadowing"
                              ] : List Text
                          }
                    , default-extensions =
                        [] : List types.Extension
                    , hs-source-dirs =
                        [ "cabal-to-dhall" ]
                    , other-extensions =
                        [ types.Extension.NamedFieldPuns True ]
                    , other-modules =
                        [ "Paths_dhall_to_etlas" ]
                    }
            , name =
                "etlas-to-dhall"
            }
          , { executable =
                  λ(config : types.Config)
                →   prelude.defaults.Executable
                  ⫽ { main-is =
                        "Main.hs"
                    , build-depends =
                        [ { bounds =
                              prelude.intervalVersionRange
                              ([ "[4.5,5)" ] : List Text)
                          , package =
                              "base"
                          }
                        , { bounds =
                              prelude.intervalVersionRange
                              ([ "[1.3.0.2,1.4)" ] : List Text)
                          , package =
                              "directory"
                          }
                        , { bounds =
                              prelude.intervalVersionRange
                              ([ "[1.15.0,1.16)" ] : List Text)
                          , package =
                              "dhall"
                          }
                        , { bounds =
                              prelude.anyVersion
                          , package =
                              "dhall-to-etlas"
                          }
                        , { bounds =
                              prelude.intervalVersionRange
                              ([ "[1.4,1.5)" ] : List Text)
                          , package =
                              "filepath"
                          }
                        , { bounds =
                              prelude.intervalVersionRange
                              ([ "[0.13.2,0.15)" ] : List Text)
                          , package =
                              "optparse-applicative"
                          }
                        , { bounds =
                              prelude.intervalVersionRange
                              ([ "[1.2.0.1,1.3)" ] : List Text)
                          , package =
                              "prettyprinter"
                          }
                        ]
                    , compiler-options =
                          prelude.defaults.CompilerOptions
                        ⫽ { GHC =
                              [ "-Wall"
                              , "-fno-warn-safe"
                              , "-fno-warn-unsafe"
                              , "-fno-warn-implicit-prelude"
                              , "-fno-warn-missing-import-lists"
                              , "-fno-warn-missing-local-sigs"
                              , "-fno-warn-monomorphism-restriction"
                              , "-fno-warn-name-shadowing"
                              ] : List Text
                          }
                    , default-extensions =
                        [] : List types.Extension
                    , hs-source-dirs =
                        [ "meta" ]
                    }
            , name =
                "dhall-to-cabal-meta"
            }
          ]
      , extra-source-files =
          [ "Changelog.md"
          , "README.md"
          , "dhall/SPDX/and.dhall"
          , "dhall/SPDX/license.dhall"
          , "dhall/SPDX/licenseVersionOrLater.dhall"
          , "dhall/SPDX/or.dhall"
          , "dhall/SPDX/ref.dhall"
          , "dhall/SPDX/refWithFile.dhall"
          , "dhall/Version/v.dhall"
          , "dhall/VersionRange/anyVersion.dhall"
          , "dhall/VersionRange/differenceVersionRanges.dhall"
          , "dhall/VersionRange/earlierVersion.dhall"
          , "dhall/VersionRange/intersectVersionRanges.dhall"
          , "dhall/VersionRange/invertVersionRange.dhall"
          , "dhall/VersionRange/laterVersion.dhall"
          , "dhall/VersionRange/majorBoundVersion.dhall"
          , "dhall/VersionRange/noVersion.dhall"
          , "dhall/VersionRange/notThisVersion.dhall"
          , "dhall/VersionRange/orEarlierVersion.dhall"
          , "dhall/VersionRange/orLaterVersion.dhall"
          , "dhall/VersionRange/thisVersion.dhall"
          , "dhall/VersionRange/unionVersionRanges.dhall"
          , "dhall/VersionRange/withinVersion.dhall"
          , "dhall/defaults/Benchmark.dhall"
          , "dhall/defaults/BuildInfo.dhall"
          , "dhall/defaults/CompilerOptions.dhall"
          , "dhall/defaults/Executable.dhall"
          , "dhall/defaults/Library.dhall"
          , "dhall/defaults/Package.dhall"
          , "dhall/defaults/SourceRepo.dhall"
          , "dhall/defaults/TestSuite.dhall"
          , "dhall/prelude.dhall"
          , "dhall/types.dhall"
          , "dhall/types/Arch.dhall"
          , "dhall/types/Benchmark.dhall"
          , "dhall/types/BuildType.dhall"
          , "dhall/types/Compiler.dhall"
          , "dhall/types/CompilerOptions.dhall"
          , "dhall/types/Config.dhall"
          , "dhall/types/CustomSetup.dhall"
          , "dhall/types/Dependency.dhall"
          , "dhall/types/Executable.dhall"
          , "dhall/types/Extension.dhall"
          , "dhall/types/Flag.dhall"
          , "dhall/types/ForeignLibrary.dhall"
          , "dhall/types/Guarded.dhall"
          , "dhall/types/Language.dhall"
          , "dhall/types/Library.dhall"
          , "dhall/types/License.dhall"
          , "dhall/types/Mixin.dhall"
          , "dhall/types/ModuleRenaming.dhall"
          , "dhall/types/OS.dhall"
          , "dhall/types/Package.dhall"
          , "dhall/types/RepoKind.dhall"
          , "dhall/types/RepoType.dhall"
          , "dhall/types/SPDX.dhall"
          , "dhall/types/SPDX/LicenseExceptionId.dhall"
          , "dhall/types/SPDX/LicenseId.dhall"
          , "dhall/types/Scope.dhall"
          , "dhall/types/SetupBuildInfo.dhall"
          , "dhall/types/SourceRepo.dhall"
          , "dhall/types/TestSuite.dhall"
          , "dhall/types/TestType.dhall"
          , "dhall/types/Version.dhall"
          , "dhall/types/VersionRange.dhall"
          , "dhall/types/builtin.dhall"
          , "dhall/unconditional.dhall"
          , "dhall/utils/GitHub-project.dhall"
          , "dhall/utils/majorVersions.dhall"
          , "dhall/utils/mapSourceRepos.dhall"
          , "dhall/utils/package.dhall"
          , "golden-tests/dhall-to-cabal/*.dhall"
          , "golden-tests/dhall-to-cabal/*.cabal"
          , "golden-tests/cabal-to-dhall/*.dhall"
          , "golden-tests/cabal-to-dhall/*.cabal"
          ]
      , homepage =
          "https://github.com/eta-lang/dhall-to-etlas"
      , library =
          Some
          (   λ(config : types.Config)
            →   prelude.defaults.Library
              ⫽ { build-depends =
                    [ { bounds =
                          prelude.intervalVersionRange
                          ([ "[1.3.0.0,1.4)" ] : List Text)
                      , package =
                          "etlas-cabal"
                      }
                    , { bounds =
                          prelude.intervalVersionRange
                          ([ "[4.5,5)" ] : List Text)
                      , package =
                          "base"
                      }
                    , { bounds =
                          prelude.intervalVersionRange
                          ([ "[0.10,0.11)" ] : List Text)
                      , package =
                          "bytestring"
                      }
                    , { bounds =
                          prelude.intervalVersionRange
                          ([ "[0.5,0.6)" ] : List Text)
                      , package =
                          "containers"
                      }
                    , { bounds =
                          prelude.intervalVersionRange
                          ([ "[1.4,1.5)" ] : List Text)
                      , package =
                          "contravariant"
                      }
                    , { bounds =
                          prelude.intervalVersionRange
                          ([ "[1.15.0,1.16)" ] : List Text)
                      , package =
                          "dhall"
                      }
                    , { bounds =
                          prelude.intervalVersionRange
                          ([ "[1.2.6.1,1.3)" ] : List Text)
                      , package =
                          "hashable"
                      }
                    , { bounds =
                          prelude.intervalVersionRange
                          ([ "[0.2.1.0,0.3)" ] : List Text)
                      , package =
                          "insert-ordered-containers"
                      }
                    , { bounds =
                          prelude.intervalVersionRange
                          ([ "[1.2,1.3)" ] : List Text)
                      , package =
                          "text"
                      }
                    , { bounds =
                          prelude.intervalVersionRange
                          ([ "[0.2.0.0,0.6)" ] : List Text)
                      , package =
                          "transformers"
                      }
                    , { bounds =
                          prelude.intervalVersionRange
                          ([ "[0.11.0.0,0.13)" ] : List Text)
                      , package =
                          "vector"
                      }
                    , { bounds =
                          prelude.intervalVersionRange
                          ([ "[0.18.0,0.19)" ] : List Text)
                      , package =
                          "semigroups"
                      }
                    ]
                , compiler-options =
                      prelude.defaults.CompilerOptions
                    ⫽ { GHC =
                          [ "-Wall"
                          , "-fno-warn-safe"
                          , "-fno-warn-unsafe"
                          , "-fno-warn-implicit-prelude"
                          , "-fno-warn-missing-import-lists"
                          , "-fno-warn-missing-local-sigs"
                          , "-fno-warn-monomorphism-restriction"
                          , "-fno-warn-name-shadowing"
                          ] : List Text
                      }
                , default-extensions =
                    [] : List types.Extension
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
                , exposed-modules =
                    [ "DhallToCabal", "DhallLocation", "CabalToDhall" ]
                }
          )
      , license =
          types.License.MIT
      , license-files =
          [ "LICENSE" ]
      , maintainer =
          "atreyu.bbb@gmail.com"
      , source-repos =
          [   prelude.defaults.SourceRepo
            ⫽ { type =
                  Some types.RepoType.Git
              , location =
                  Some "https://github.com/eta-lang/dhall-to-etlas"
              }
          ]
      , synopsis =
          "Compile Dhall expressions to Etlas files"
      , test-suites =
          [ { name =
                "golden-tests"
            , test-suite =
                  λ(config : types.Config)
                →   prelude.defaults.TestSuite
                  ⫽ { type =
                        < exitcode-stdio =
                            { main-is = "GoldenTests.hs" }
                        | detailed :
                            { module : Text }
                        >
                    , build-depends =
                        [ { bounds =
                              prelude.intervalVersionRange
                              ([ "[4.5,5)" ] : List Text)
                          , package =
                              "base"
                          }
                        , { bounds =
                              prelude.intervalVersionRange
                              ([ "[1.3.0.0,1.4)" ] : List Text)
                          , package =
                              "etlas-cabal"
                          }
                        , { bounds =
                              prelude.intervalVersionRange
                              ([ "[0.3.4,0.4)" ] : List Text)
                          , package =
                              "Diff"
                          }
                        , { bounds =
                              prelude.intervalVersionRange
                              ([ "[0.10,0.11)" ] : List Text)
                          , package =
                              "bytestring"
                          }
                        , { bounds =
                              prelude.intervalVersionRange
                              ([ "[1.15.0,1.16)" ] : List Text)
                          , package =
                              "dhall"
                          }
                        , { bounds =
                              prelude.anyVersion
                          , package =
                              "dhall-to-etlas"
                          }
                        , { bounds =
                              prelude.intervalVersionRange
                              ([ "[1.4,1.5)" ] : List Text)
                          , package =
                              "filepath"
                          }
                        , { bounds =
                              prelude.intervalVersionRange
                              ([ "[1.2.0.1,1.3)" ] : List Text)
                          , package =
                              "prettyprinter"
                          }
                        , { bounds =
                              prelude.intervalVersionRange
                              ([ "[0.11,1.2)" ] : List Text)
                          , package =
                              "tasty"
                          }
                        , { bounds =
                              prelude.intervalVersionRange
                              ([ "[2.3,2.4)" ] : List Text)
                          , package =
                              "tasty-golden"
                          }
                        , { bounds =
                              prelude.intervalVersionRange
                              ([ "[1.2,1.3)" ] : List Text)
                          , package =
                              "text"
                          }
                        ]
                    , compiler-options =
                          prelude.defaults.CompilerOptions
                        ⫽ { GHC =
                              [ "-Wall"
                              , "-fno-warn-safe"
                              , "-fno-warn-unsafe"
                              , "-fno-warn-implicit-prelude"
                              , "-fno-warn-missing-import-lists"
                              , "-fno-warn-missing-local-sigs"
                              , "-fno-warn-monomorphism-restriction"
                              , "-fno-warn-name-shadowing"
                              ] : List Text
                          }
                    , default-extensions =
                        [] : List types.Extension
                    , hs-source-dirs =
                        [ "golden-tests" ]
                    }
            }
          ]
      }
