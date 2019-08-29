let prelude = ./../../dhall/prelude.dhall

let types = ./../../dhall/types.dhall

in    prelude.defaults.Package
    ⫽ { build-type =
          None types.BuildType
      , cabal-version =
          prelude.v "2.4"
      , license =
          types.License.Unspecified
      , name =
          "foo"
      , source-repos =
          [   prelude.defaults.SourceRepo
            ⫽ { kind =
                  types.RepoKind.RepoThis { _1 = "blargh" }
              , location =
                  Some "https://example.com"
              , type =
                  Some types.RepoType.Git
              }
          ]
      , version =
          prelude.v "2"
      }
