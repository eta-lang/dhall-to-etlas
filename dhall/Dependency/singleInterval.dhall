let Dependency = ../types/Dependency.dhall

let cons = ./cons.dhall

let v = ../Version/v.dhall

let intervals = ../VersionRange/intervalsVersionRange.dhall

let singleInterval
    : Text → Text → Dependency
    =   λ(packageName : Text)
      → λ(interval : Text)
      → cons packageName (intervals [ interval ])

in  singleInterval
