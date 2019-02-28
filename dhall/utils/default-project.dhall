let Guarded = ./../types/Guarded.dhall

let Package = ./../types/package.dhall

let DefaultProject =
      { repo-owner :
          Text
      , author :
          Text
      , category :
          Text
      , description :
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
      , test-suites :
          List { name : Text, test-suite : Guarded ./../types/TestSuite.dhall }
      , version :
          Text
      }

let gitHubTag-project = ./GitHubTag-project.dhall

let default-project
    : DefaultProject → Package
    =   λ(project : DefaultProject)
      →   gitHubTag-project
          (   project.{ version }
            ⫽ { owner = project.repo-owner, repo = project.name }
          )
        ⫽ project.{ author
                  , category
                  , description
                  , executables
                  , extra-source-files
                  , library
                  , license
                  , license-files
                  , maintainer
                  , name
                  , test-suites
                  }

in  default-project
