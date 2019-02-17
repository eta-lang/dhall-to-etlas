let Dependency = ./types/Dependency.dhall

let idx-types =
      https://raw.githubusercontent.com/jneira/etlas-index/dhall-deps/dhall/types.dhall

let idx =
      https://raw.githubusercontent.com/jneira/etlas-index/dhall-deps/dhall/index.dhall

let boot =
      https://raw.githubusercontent.com/jneira/etlas-index/dhall-deps/dhall/boot-packages.dhall

let v = ./Version/v.dhall

let thisVersion = ./VersionRange/thisVersion.dhall

let idxPkgToDep =
        λ(pkg : idx-types.IndexedPackage)
      → { package = pkg.name, bounds = thisVersion (v pkg.lastest) }

let pkgToDep =
        λ(pkg : idx-types.Package)
      → { package = pkg.name, bounds = thisVersion (v pkg.version) }

let deps = idx Dependency idxPkgToDep ⫽ boot Dependency pkgToDep

in  deps
