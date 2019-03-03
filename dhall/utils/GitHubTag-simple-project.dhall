let Guarded = ./../types/Guarded.dhall

let Package = ./../types/Package.dhall

let SimpleGithubProject =
      { repo-owner :
          Text
      , author :
          Text
      , category :
          Text
      , executables :
          List { executable : Guarded ./../types/Executable.dhall, name : Text }
      , extra-source-files :
          List Text
      , library :
          Optional (Guarded ./../types/Library.dhall)
      , license :
          ./../types/License.dhall
      , license-files :
          List Text
      , maintainer :
          Text
      , name :
          Text
      , synopsis :
          Text
      , test-suites :
          List { name : Text, test-suite : Guarded ./../types/TestSuite.dhall }
      , version :
          Text
      }

let gitHubTag-project = ./GitHubTag-project.dhall

let GitHubTag-simple-project
    : SimpleGithubProject → Package
    =   λ(project : SimpleGithubProject)
      →   gitHubTag-project
          (   project.{ version }
            ⫽ { owner = project.repo-owner, repo = project.name }
          )
        ⫽ project.{ author
                  , category
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
