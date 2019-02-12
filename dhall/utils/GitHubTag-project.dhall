let GitHubTagProject : Type = { owner : Text, repo : Text, version : Text }

let v = ../Version/v.dhall

let setTag =
        λ(version : Text)
      → ./mapSourceRepos.dhall
        (   λ(srcRepo : ../types/SourceRepo.dhall)
          →   srcRepo
            ⫽ { tag =
                  Some version
              , kind =
                  (../types/RepoKind.dhall).RepoThis {=}
              }
        )

let gitHubTag-project =
        λ(github : GitHubTagProject)
      → let project = ./GitHub-project.dhall github.{ owner, repo }
        
        let projectV = project ⫽ { version = v github.version }
        
        in  setTag github.version projectV

in  gitHubTag-project
