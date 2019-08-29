let prelude = ../../dhall/prelude.dhall

let types = ../../dhall/types.dhall

let thisVersions = prelude.Dependency.thisVersions

let f =
        λ(buildInfo : types.BuildInfo)
      →   buildInfo
        ⫽ { build-depends =
                buildInfo.build-depends
              # [ thisVersions "injected" [ prelude.v "1.0" ] ]
          }

in  prelude.utils.mapBuildInfo
    f
    (   prelude.defaults.Package
      ⫽ { name =
            "pkg"
        , version =
            prelude.v "0"
        , library =
            Some
            (   λ(config : types.Config)
              →   prelude.defaults.empty.Library
                ⫽ { build-depends =
                      [ thisVersions
                        "library"
                        [ prelude.v "1.0" ]
                      ]
                  }
            )
        , custom-setup =
            Some
            { setup-depends =
                [ thisVersions "setup" [ prelude.v "1.0" ] ]
            }
        , benchmarks =
            [ { name =
                  "bench"
              , benchmark =
                    λ(config : types.Config)
                  →   prelude.defaults.empty.Benchmark
                    ⫽ { main-is =
                          "Bench.hs"
                      , build-depends =
                          [ thisVersions
                            "bench"
                            [ prelude.v "1.0" ]
                          ]
                      }
              }
            ]
        , executables =
            [ { name =
                  "exe"
              , executable =
                    λ(config : types.Config)
                  →   prelude.defaults.empty.Executable
                    ⫽ { main-is =
                          "Exe.hs"
                      , build-depends =
                          [ thisVersions
                            "exe"
                            [ prelude.v "1.0" ]
                          ]
                      }
              }
            ]
        , foreign-libraries =
            [ { name =
                  "flib"
              , foreign-lib =
                    λ(config : types.Config)
                  →   ../../dhall/defaults/BuildInfo.dhall
                    ⫽ { type = types.ForeignLibType.Static
                      , options = [] : List types.ForeignLibOption
                      , mod-def-files = [] : List Text
                      , lib-version-info = None { current : Natural, revision : Natural, age : Natural }
                      , lib-version-linux = None types.Version
                      , build-depends =
                          [ thisVersions
                            "flib"
                            [ prelude.v "1.0" ]
                          ]
                      }
              }
            ]
        , sub-libraries =
            [ { name =
                  "sublib"
              , library =
                    λ(config : types.Config)
                  →   prelude.defaults.empty.Library
                    ⫽ { build-depends =
                          [ thisVersions
                            "sublib"
                            [ prelude.v "1.0" ]
                          ]
                      }
              }
            ]
        , test-suites =
            [ { name =
                  "tests"
              , test-suite =
                    λ(config : types.Config)
                  →   prelude.defaults.empty.TestSuite
                    ⫽ { type =
                          types.TestType.exitcode-stdio { main-is = "Test.hs" }
                      , build-depends =
                          [ thisVersions
                            "tests"
                            [ prelude.v "1.0" ]
                          ]
                      }
              }
            ]
        }
    )
