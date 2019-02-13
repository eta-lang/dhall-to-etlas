let ty = ../types.dhall

let toBuildInfo = ./toBuildInfo.dhall

let mapBuildInfoBench
    : (ty.BuildInfo → ty.BuildInfo) → ty.Benchmark → ty.Benchmark
    =   λ(f : ty.BuildInfo → ty.BuildInfo)
      → λ(comp : ty.Benchmark)
      → comp ⫽ f (toBuildInfo.benchmark comp)

let mapBuildInfoExe
    : (ty.BuildInfo → ty.BuildInfo) → ty.Executable → ty.Executable
    =   λ(f : ty.BuildInfo → ty.BuildInfo)
      → λ(comp : ty.Executable)
      → comp ⫽ f (toBuildInfo.executable comp)

let mapBuildInfoForeignLib
    : (ty.BuildInfo → ty.BuildInfo) → ty.ForeignLibrary → ty.ForeignLibrary
    =   λ(f : ty.BuildInfo → ty.BuildInfo)
      → λ(comp : ty.ForeignLibrary)
      → comp ⫽ f (toBuildInfo.foreignLibrary comp)

let mapBuildInfoLib
    : (ty.BuildInfo → ty.BuildInfo) → ty.Library → ty.Library
    =   λ(f : ty.BuildInfo → ty.BuildInfo)
      → λ(comp : ty.Library)
      → comp ⫽ f (toBuildInfo.library comp)

let mapBuildInfoTest
    : (ty.BuildInfo → ty.BuildInfo) → ty.TestSuite → ty.TestSuite
    =   λ(f : ty.BuildInfo → ty.BuildInfo)
      → λ(comp : ty.TestSuite)
      → comp ⫽ f (toBuildInfo.testSuite comp)

in  { benchmark =
        mapBuildInfoBench
    , executable =
        mapBuildInfoExe
    , foreignLibrary =
        mapBuildInfoForeignLib
    , library =
        mapBuildInfoLib
    , testSuite =
        mapBuildInfoTest
    }
