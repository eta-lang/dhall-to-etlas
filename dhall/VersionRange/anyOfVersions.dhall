let Version = ../types/Version.dhall

let VersionRange = ../types/VersionRange.dhall

let unionVersionRanges = ../VersionRange/unionVersionRanges.dhall

let noVersion = ../VersionRange/noVersion.dhall

let anyOfVersions
    : (Version → VersionRange) → List Version → VersionRange
    =   λ(mkVersionRange : Version → VersionRange)
      → λ(versions : List Version)
      → Optional/fold
        VersionRange
        ( List/fold
          Version
          versions
          (Optional VersionRange)
          (   λ(v : Version)
            → λ(r : Optional VersionRange)
            → Optional/fold
              VersionRange
              r
              (Optional VersionRange)
              (   λ(r : VersionRange)
                → Some (unionVersionRanges (mkVersionRange v) r)
              )
              (Some (mkVersionRange v))
          )
          (None VersionRange)
        )
        VersionRange
        (λ(a : VersionRange) → a)
        noVersion

in  anyOfVersions
