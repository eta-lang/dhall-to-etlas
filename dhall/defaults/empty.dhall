let mapBI = ./../utils/mapBuildInfo.dhall

let resetBI = ./../utils/resetBuildInfo.dhall

in  { Benchmark =
        resetBI ./Benchmark.dhall
    , Executable =
        resetBI ./Executable.dhall
    , Library =
        mapBI.library resetBI ./Library.dhall
    , TestSuite =
        resetBI ./TestSuite.dhall
    }
