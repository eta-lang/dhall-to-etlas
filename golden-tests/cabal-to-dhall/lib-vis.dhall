let prelude = ./../../dhall/prelude.dhall

let types = ./../../dhall/types.dhall

in    prelude.defaults.Package
    ⫽ { build-type = None types.BuildType
      , cabal-version = prelude.v "3.0"
      , library =
          Some
          (   λ(config : types.Config)
            →   prelude.defaults.Library
              ⫽ { default-extensions = [] : List types.Extension }
          )
      , license = types.License.Unspecified
      , name = "multilib"
      , sub-libraries =
          [ { library =
                  λ(config : types.Config)
                →   prelude.defaults.Library
                  ⫽ { default-extensions = [] : List types.Extension }
            , name = "x"
            }
          , { library =
                  λ(config : types.Config)
                →   prelude.defaults.Library
                  ⫽ { default-extensions = [] : List types.Extension }
            , name = "y"
            }
          ]
      , version = prelude.v "0"
      }