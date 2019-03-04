{ author :
    Text
, benchmarks :
    List { benchmark : ./Guarded.dhall ./Benchmark.dhall, name : Text }
, category :
    Text
, description :
    Text
, executables :
    List { executable : ./Guarded.dhall ./Executable.dhall, name : Text }
, extra-source-files :
    List Text
, library :
    Optional (./Guarded.dhall ./Library.dhall)
, license :
    ./License.dhall
, license-files :
    List Text
, maintainer :
    Text
, name :
    Text
, synopsis :
    Text
, test-suites :
    List { name : Text, test-suite : ./Guarded.dhall ./TestSuite.dhall }
}
