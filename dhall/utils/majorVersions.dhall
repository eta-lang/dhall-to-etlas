let Version = ../types/Version.dhall

let VersionRange = ../types/VersionRange.dhall

let majorBoundVersion = ../VersionRange/majorBoundVersion.dhall

let majorVersions
    : Text → List Version → { package : Text, bounds : VersionRange }
    = ./unionVersions.dhall majorBoundVersion

in majorVersions