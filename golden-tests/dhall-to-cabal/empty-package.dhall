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
            →   (../../dhall/defaults/empty.dhall).Executable
              ⫽ { main-is = "Main.hs" }
        }
      ]
  }
