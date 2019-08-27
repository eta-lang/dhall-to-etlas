let prelude = ./../../dhall/prelude.dhall

let types = ./../../dhall/types.dhall

in    prelude.defaults.Package
    ⫽ { build-type =
          None types.BuildType
      , license =
          types.License.Unknown "MYUnknownLicense"
      , name =
          "test"
      , version =
          prelude.v "1.0"
      }
