{ defaults =
    ./defaults/all.dhall
, Dependency =
    ./Dependency/package.dhall
, anyVersion =
    ./VersionRange/anyVersion.dhall
, anyOfVersions =
    ./VersionRange/anyOfVersions.dhall
, earlierVersion =
    ./VersionRange/earlierVersion.dhall
, orEarlierVersion =
    ./VersionRange/orEarlierVersion.dhall
, intersectVersionRanges =
    ./VersionRange/intersectVersionRanges.dhall
, unionVersionRanges =
    ./VersionRange/unionVersionRanges.dhall
, majorBoundVersion =
    ./VersionRange/majorBoundVersion.dhall
, orLaterVersion =
    ./VersionRange/orLaterVersion.dhall
, laterVersion =
    ./VersionRange/laterVersion.dhall
, thisVersion =
    ./VersionRange/thisVersion.dhall
, notThisVersion =
    ./VersionRange/notThisVersion.dhall
, withinVersion =
    ./VersionRange/withinVersion.dhall
, intervalsVersionRange =
    ./VersionRange/intervalsVersionRange.dhall
, v =
    ./Version/v.dhall
, noVersion =
    ./VersionRange/noVersion.dhall
, utils =
    ./utils/package.dhall
, unconditional =
    ./unconditional.dhall
, SPDX =
    ./SPDX/package.dhall
}
