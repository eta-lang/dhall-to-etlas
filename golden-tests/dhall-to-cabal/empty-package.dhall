  ../../dhall/defaults/Package.dhall
⫽ { name =
      "Name"
  , version =
      ../../dhall/Version/v.dhall "1"
  , executables =
      [ { name =
            "foo"
        , executable =
              λ(config : ../../dhall/types/Config.dhall)
            →   (../../utils/resetComponent.dhall).library
                ../../dhall/defaults/Executable.dhall
              ⫽ { main-is = "Main.hs" }
        }
      ]
  }
