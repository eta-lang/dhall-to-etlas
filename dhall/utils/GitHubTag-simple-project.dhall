let Guarded = ./../types/Guarded.dhall

let Package = ./../types/Package.dhall

let SimpleGithubProject =
      ./../types/SimplePackage.dhall ⩓ { repo-owner : Text, version : Text }

let gitHubTag-project = ./GitHubTag-project.dhall

let GitHubTag-simple-project
    : SimpleGithubProject → Package
    =   λ(project : SimpleGithubProject)
      →   gitHubTag-project
          (   project.{ version }
            ⫽ { owner = project.repo-owner, repo = project.name }
          )
        ⫽ project.{ author
                  , benchmarks
                  , category
                  , description
                  , executables
                  , extra-source-files
                  , library
                  , license
                  , license-files
                  , maintainer
                  , name
                  , synopsis
                  , test-suites
                  }

in  GitHubTag-simple-project
