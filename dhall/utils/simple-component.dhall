let ty = ../types.dhall

let Guarded = ./../types/Guarded.dhall

let SimpleBuildInfo =
      { build-depends : List ty.Dependency, hs-source-dirs : List Text }

let SimpleLibrary = SimpleBuildInfo ⩓ { exposed-modules : List Text }

let PackageLibrary = Optional (Guarded ty.Library)

let defaultLibrary = ./../defaults/Library.dhall

let SimpleExecutable = SimpleBuildInfo ⩓ { name : Text, main-is : Text }

let SimpleBenchmark = SimpleExecutable

let PackageExecutable = { name : Text, executable : Guarded ty.Executable }

let PackageBenchmark = { name : Text, benchmark : Guarded ty.Benchmark }

let defaultExecutable = ./../defaults/Executable.dhall

let defaultBenchmark = ./../defaults/Benchmark.dhall

let SimpleTestSuite = SimpleExecutable

let PackageTestSuite = { name : Text, test-suite : Guarded ty.TestSuite }

let defaultTestSuite = ./../defaults/TestSuite.dhall

let uncond = ./../unconditional.dhall

let benchmark
    : SimpleBenchmark → PackageBenchmark
    =   λ(benchmark : SimpleBenchmark)
      → uncond.benchmark
        benchmark.name
        (   defaultBenchmark
          ⫽ benchmark.{ build-depends, main-is, hs-source-dirs }
        )

let executable
    : SimpleExecutable → PackageExecutable
    =   λ(executable : SimpleExecutable)
      → uncond.executable
        executable.name
        (   defaultExecutable
          ⫽ executable.{ build-depends, main-is, hs-source-dirs }
        )

let library
    : SimpleLibrary → PackageLibrary
    = λ(library : SimpleLibrary) → uncond.library (defaultLibrary ⫽ library)

let test-suite
    : SimpleTestSuite → PackageTestSuite
    =   λ(testSuite : SimpleTestSuite)
      → uncond.test-suite
        testSuite.name
        (   defaultTestSuite
          ⫽ testSuite.{ build-depends, hs-source-dirs }
          ⫽ { type = ty.TestType.exitcode-stdio testSuite.{ main-is } }
        )

in  { benchmark =
        benchmark
    , executable =
        executable
    , library =
        library
    , test-suite =
        test-suite
    }
