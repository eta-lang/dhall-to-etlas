let ty = ../types.dhall

let Guarded = ./../types/Guarded.dhall

let SimpleLibrary = ty.SimpleBuildInfo ⩓ { exposed-modules : List Text }

let PackageLibrary = Optional (Guarded ty.Library)

let defaultLibrary = ./../defaults/Library.dhall

let SimpleExecutable = ty.SimpleBuildInfo ⩓ { name : Text, main-is : Text }

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
          ⫽ benchmark.{ build-depends
                      , compiler-options
                      , hs-source-dirs
                      , java-sources
                      , main-is
                      , maven-depends
                      , other-modules
                      }
        )

let executable
    : SimpleExecutable → PackageExecutable
    =   λ(executable : SimpleExecutable)
      → uncond.executable
        executable.name
        (   defaultExecutable
          ⫽ executable.{ build-depends
                       , compiler-options
                       , hs-source-dirs
                       , java-sources
                       , main-is
                       , maven-depends
                       , other-modules
                       }
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
          ⫽ testSuite.{ build-depends
                      , compiler-options
                      , hs-source-dirs
                      , java-sources
                      , maven-depends
                      , other-modules
                      }
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
