let Dependency = ../types/Dependency.dhall

let cons = ./cons.dhall

let anyVer = ../VersionRange/anyVersion.dhall

let anyDep
    : Text → Dependency
    = λ(pkgName : Text) → cons pkgName anyVer

in  anyDep
