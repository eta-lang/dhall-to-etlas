let Package = ./../types/Package.dhall

let DefaultProject : Type = { owner : Text } ⩓ Package

let gitHubTag-project = ./GitHubTag-project.dhall

let vToText = ./../Version/toText.dhall

let default-project
    : DefaultProject → Package
    =   λ(project : DefaultProject)
      →   gitHubTag-project
          (   project.{ owner }
            ⫽ { repo = project.name, version = vToText project.version }
          )
        ⫽ project.{ author
                  , benchmarks
                  , bug-reports
                  , build-type
                  , cabal-version
                  , category
                  , copyright
                  , custom-setup
                  , data-dir
                  , data-files
                  , description
                  , executables
                  , extra-doc-files
                  , extra-source-files
                  , extra-tmp-files
                  , flags
                  , foreign-libraries
                  , homepage
                  , library
                  , license
                  , license-files
                  , maintainer
                  , name
                  , package-url
                  , source-repos
                  , stability
                  , sub-libraries
                  , synopsis
                  , test-suites
                  , tested-with
                  , version
                  , x-fields
                  }

in  default-project
