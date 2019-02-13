let mapBI = ./mapBuildInfo.dhall

let resetBI = ./resetBuildInfo.dhall

in  { benchmark =
        mapBI.benchmark resetBI
    , executable =
        mapBI.executable resetBI
    , foreignLibrary =
        mapBI.foreignLibrary resetBI
    , library =
        mapBI.library resetBI
    , testSuite =
        mapBI.testSuite resetBI
    }
