let prelude = ./../../dhall/prelude.dhall

let types = ./../../dhall/types.dhall

in    prelude.defaults.Package
    ⫽ { cabal-version =
          prelude.v "2.0"
      , license =
          types.License.Unspecified
      , name =
          "test"
      , version =
          prelude.v "1.0"
      }
