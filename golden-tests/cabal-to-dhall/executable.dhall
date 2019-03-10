let prelude = ./../../dhall/prelude.dhall

let types = ./../../dhall/types.dhall

in    prelude.defaults.Package
    ⫽ { name =
          "blah"
      , version =
          prelude.v "1"
      , cabal-version =
          prelude.v "2.0"
      , executables =
          [ { executable =
                  λ(config : types.Config)
                →   prelude.defaults.Executable
                  ⫽ { main-is =
                        "Main.hs"
                    , default-extensions =
                        [] : List types.Extension
                    }
            , name =
                "hello"
            }
          ]
      }
