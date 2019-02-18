let Dependency = ../types/Dependency.dhall

let cons = ./cons.dhall

let anyVer = ../VersionRange/anyVersion.dhall

let anyDep
    : Text → Text → Dependency
    = λ(pkgName : Text) → λ(version : Text) → cons pkgName anyVer

in  anyDep
