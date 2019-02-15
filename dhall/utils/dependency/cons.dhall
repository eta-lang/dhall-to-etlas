let VersionRange = ../../types/VersionRange.dhall

let Dependency = ../../types/Dependency.dhall

let cons
    : Text → VersionRange → Dependency
    =   λ(name : Text)
      → λ(version-range : VersionRange)
      → { package = name, bounds = version-range }

in  cons
