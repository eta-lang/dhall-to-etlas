let Dependency = ../../types/Dependency.dhall

let cons = ./cons.dhall

let v = ../../Version/v.dhall

let and = ../../VersionRange/intersectVersionRanges.dhall

let orLater = ../../VersionRange/orLaterVersion.dhall

let earlier = ../../VersionRange/earlierVersion.dhall

let pvp
    : Text → Text → Text → Dependency
    =   λ(packageName : Text)
      → λ(minor : Text)
      → λ(major : Text)
      → cons packageName (and (orLater (v minor)) (earlier (v major)))

in  pvp
