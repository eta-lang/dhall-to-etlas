let prelude = ./../../dhall/prelude.dhall

let types = ./../../dhall/types.dhall

in    prelude.defaults.Package
    ⫽ { executables =
          [ { executable =
                  λ(config : types.Config)
                → prelude.defaults.Executable ⫽ { main-is = "Main.hs" }
            , name = "hello"
            }
          ]
      , name = "etlas-defaults"
      , version = prelude.v "1"
      }
