let Package = ./../types/Package.dhall

let DefaultProject : Type = { owner : Text, repo : Text } ⩓ Package

let gitHubTag-project = ./GitHubTag-project.dhall

let Version = ./../types/Version.dhall

let id = λ(a : Type) → λ(x : a) → x

let extractVersion : Version → Text = λ(v : Version) → v Text (id Text)

let defaultProject
    : DefaultProject → Package
    =   λ(project : DefaultProject)
      →   gitHubTag-project
          (   project.{ owner, repo }
            ⫽ { version = extractVersion project.version }
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

in  defaultProject
