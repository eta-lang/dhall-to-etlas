let prelude = ./../../dhall/prelude.dhall

let types = ./../../dhall/types.dhall

in    prelude.defaults.Package
    ⫽ { name =
          "test"
      , version =
          prelude.v "1.0"
      , license =
          types.License.Unspecified {=}
      }
