let ty = ../types.dhall

let benchToBuildInfo
    : ty.Benchmark → ty.BuildInfo
    =   λ(comp : ty.Benchmark)
      → comp.{ autogen-modules
             , build-depends
             , build-tool-depends
             , build-tools
             , buildable
             , c-sources
             , cc-options
             , compiler-options
             , cpp-options
             , default-extensions
             , default-language
             , extra-framework-dirs
             , extra-ghci-libraries
             , extra-lib-dirs
             , maven-depends
             , frameworks
             , hs-source-dirs
             , includes
             , include-dirs
             , install-includes
             , js-sources
             , ld-options
             , other-extensions
             , other-languages
             , other-modules
             , pkgconfig-depends
             , profiling-options
             , shared-options
             , mixins
             , java-sources
             }

let exeToBuildInfo
    : ty.Executable → ty.BuildInfo
    =   λ(comp : ty.Executable)
      → comp.{ autogen-modules
             , build-depends
             , build-tool-depends
             , build-tools
             , buildable
             , c-sources
             , cc-options
             , compiler-options
             , cpp-options
             , default-extensions
             , default-language
             , extra-framework-dirs
             , extra-ghci-libraries
             , extra-lib-dirs
             , maven-depends
             , frameworks
             , hs-source-dirs
             , includes
             , include-dirs
             , install-includes
             , js-sources
             , ld-options
             , other-extensions
             , other-languages
             , other-modules
             , pkgconfig-depends
             , profiling-options
             , shared-options
             , mixins
             , java-sources
             }

let foreignLibToBuildInfo
    : ty.ForeignLibrary → ty.BuildInfo
    =   λ(comp : ty.ForeignLibrary)
      → comp.{ autogen-modules
             , build-depends
             , build-tool-depends
             , build-tools
             , buildable
             , c-sources
             , cc-options
             , compiler-options
             , cpp-options
             , default-extensions
             , default-language
             , extra-framework-dirs
             , extra-ghci-libraries
             , extra-lib-dirs
             , maven-depends
             , frameworks
             , hs-source-dirs
             , includes
             , include-dirs
             , install-includes
             , js-sources
             , ld-options
             , other-extensions
             , other-languages
             , other-modules
             , pkgconfig-depends
             , profiling-options
             , shared-options
             , mixins
             , java-sources
             }

let libToBuildInfo
    : ty.Library → ty.BuildInfo
    =   λ(comp : ty.Library)
      → comp.{ autogen-modules
             , build-depends
             , build-tool-depends
             , build-tools
             , buildable
             , c-sources
             , cc-options
             , compiler-options
             , cpp-options
             , default-extensions
             , default-language
             , extra-framework-dirs
             , extra-ghci-libraries
             , extra-lib-dirs
             , maven-depends
             , frameworks
             , hs-source-dirs
             , includes
             , include-dirs
             , install-includes
             , js-sources
             , ld-options
             , other-extensions
             , other-languages
             , other-modules
             , pkgconfig-depends
             , profiling-options
             , shared-options
             , mixins
             , java-sources
             }

let testToBuildInfo
    : ty.TestSuite → ty.BuildInfo
    =   λ(comp : ty.TestSuite)
      → comp.{ autogen-modules
             , build-depends
             , build-tool-depends
             , build-tools
             , buildable
             , c-sources
             , cc-options
             , compiler-options
             , cpp-options
             , default-extensions
             , default-language
             , extra-framework-dirs
             , extra-ghci-libraries
             , extra-lib-dirs
             , maven-depends
             , frameworks
             , hs-source-dirs
             , includes
             , include-dirs
             , install-includes
             , js-sources
             , ld-options
             , other-extensions
             , other-languages
             , other-modules
             , pkgconfig-depends
             , profiling-options
             , shared-options
             , mixins
             , java-sources
             }

in  { benchmark =
        benchToBuildInfo
    , executable =
        exeToBuildInfo
    , foreignLibrary =
        foreignLibToBuildInfo
    , library =
        libToBuildInfo
    , testSuite =
        testToBuildInfo
    }
