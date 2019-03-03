let unconditional
    : ∀(A : Type) → A → ./types/Guarded.dhall A
    = λ(A : Type) → λ(a : A) → λ(_ : ./types/Config.dhall) → a

let benchmark
    :   ∀(name : Text)
      → ∀(executable : ./types/Benchmark.dhall)
      → { name :
            Text
        , benchmark :
            ./types/Guarded.dhall ./types/Benchmark.dhall
        }
    =   λ(name : Text)
      → λ(benchmark : ./types/Benchmark.dhall)
      → { name =
            name
        , benchmark =
            unconditional ./types/Benchmark.dhall benchmark
        }


let executable
    :   ∀(name : Text)
      → ∀(executable : ./types/Executable.dhall)
      → { name :
            Text
        , executable :
            ./types/Guarded.dhall ./types/Executable.dhall
        }
    =   λ(name : Text)
      → λ(executable : ./types/Executable.dhall)
      → { name =
            name
        , executable =
            unconditional ./types/Executable.dhall executable
        }

let library
    :   ∀(library : ./types/Library.dhall)
      → Optional (./types/Guarded.dhall ./types/Library.dhall)
    =   λ(library : ./types/Library.dhall)
      → Some (unconditional ./types/Library.dhall library)

let test-suite
    :   ∀(name : Text)
      → ∀(test-suite : ./types/TestSuite.dhall)
      → { name :
            Text
        , test-suite :
            ./types/Guarded.dhall ./types/TestSuite.dhall
        }
    =   λ(name : Text)
      → λ(test-suite : ./types/TestSuite.dhall)
      → { name =
            name
        , test-suite =
            unconditional ./types/TestSuite.dhall test-suite
        }

in  { benchmark = benchmark
    , executable = executable
    , library = library
    , test-suite = test-suite
    }
