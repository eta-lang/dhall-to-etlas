let Version = ../types/Version.dhall

let VersionRange = ../types/VersionRange.dhall

let anyOfVersions = ../VersionRange/anyOfVersions.dhall

let anyOfVersionsDep
    :   (Version → VersionRange)
      → Text
      → List Version
      → { package : Text, bounds : VersionRange }
    =   λ(mkVersionRange : Version → VersionRange)
      → λ(package : Text)
      → λ(versions : List Version)
      → { package = package, bounds = anyOfVersions mkVersionRange versions }

in  anyOfVersionsDep
