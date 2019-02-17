let Version = ../types/Version.dhall

let VersionRange = ../types/VersionRange.dhall

let thisVersion = ../VersionRange/thisVersion.dhall

let thisVersions
    : Text → List Version → { package : Text, bounds : VersionRange }
    = ./anyOfVersions.dhall thisVersion

in  thisVersions
