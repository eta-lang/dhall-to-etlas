let prelude = ./../../dhall/prelude.dhall

let types = ./../../dhall/types.dhall

let dep = prelude.Dependency.singleInterval

let any = prelude.Dependency.any

let orLater-earlier = prelude.Dependency.orLater-earlier

let deps =
      { base =
          dep "base" "[4.5,5)"
      , bytestring =
          dep "bytestring" " [ 0.10 , 0.11 ) "
      , contravariant =
          dep "contravariant" "[1.5,1.6)"
      , containers =
          dep "containers" "[0.5,0.6)"
      , cryptonite =
          dep "cryptonite" "[0.23,1.0)"
      , dhall =
          dep "dhall" "[1.19.1,1.20)"
      , dhall-eta =
          any "dhall-eta"
      , directory =
          dep "directory" "[1.2.2.0,1.4)"
      , dotgen =
          dep "dotgen" "[0.4.2,0.5)"
      , eta-java-interop =
          dep "eta-java-interop" "[0.1.5.0,0.1.6)"
      , filepath =
          dep "filepath" "[1.4,1.5)"
      , megaparsec =
          orLater-earlier "megaparsec" "6.1.1" "7.1"
      , memory =
          orLater-earlier "memory" "0.14" "0.15"
      , lens =
          orLater-earlier "lens-family-core" "1.0.0" "1.3"
      , prettyprinter =
          orLater-earlier "prettyprinter" "1.2.0.1" "1.3"
      , scientific =
          dep "scientific" "[0.3.0.0,0.4)"
      , serialise =
          dep "serialise" "[0.2.0.0,0.3)"
      , tasty =
          dep "tasty" "[0.11.2,1.2)"
      , tasty-hunit =
          dep "tasty-hunit" "[0.9.2,0.11)"
      , text =
          dep "text" "[1.2,1.3)"
      , transformers =
          dep "transformers" "[0.2.0.0,0.6)"
      }

let comp = prelude.utils.simpleComponent

in  prelude.utils.GitHubTag-simple-project
    (   prelude.defaults.SimplePackage
      ⫽ { repo-owner =
            "eta-lang"
        , name =
            "dhall-eta"
        , version =
            "1.0.0"
        , synopsis =
            "dhall-eta is a eta library that wraps the haskell implementation of dhall configuration language."
        , category =
            "Language"
        , maintainer =
            "atreyu.bbb@gmail.com"
        , author =
            "Javier Neira Sánchez <atreyu.bbb@gmail.com>"
        , extra-source-files =
            [ "build.gradle"
            , "dhall-eta.cabal"
            , "dhall-eta.dhall"
            , "examples/build.gradle"
            , "examples/src/main/java/org/dhall/eta/example/*.java"
            , "gradlew"
            , "gradlew.bat"
            , "gradle/wrapper/gradle-wrapper.jar"
            , "gradle/wrapper/gradle-wrapper.properties"
            , "java/build.gradle"
            , "java/src/main/java/org/dhall/*.java"
            , "java/src/main/java/org/dhall/binary/*.java"
            , "java/src/main/java/org/dhall/binary/decoding/failure/*.java"
            , "java/src/main/java/org/dhall/common/types/*.java"
            , "java/src/main/java/org/dhall/common/types/either/*.java"
            , "java/src/main/java/org/dhall/common/types/functor/*.java"
            , "java/src/main/java/org/dhall/core/*.java"
            , "java/src/main/java/org/dhall/core/constant/*.java"
            , "java/src/main/java/org/dhall/core/expr/*.java"
            , "java/src/main/java/org/dhall/core/imports/*.java"
            , "java/src/main/java/org/dhall/core/imports/hashed/*.java"
            , "java/src/main/java/org/dhall/core/imports/types/*.java"
            , "java/src/main/java/org/dhall/core/imports/types/url/*.java"
            , "proguard.txt"
            , "README.md"
            , "settings.gradle"
            , "src/main/java/org/dhall/eta/*.java"
            , "src/test/resources/import/data/foo/bar/*.dhall"
            , "src/test/resources/import/success/*.dhall"
            ]
        , license =
            types.License.BSD3 {=}
        , license-files =
            [ "LICENSE" ]
        , library =
            comp.library
            (   prelude.defaults.SimpleBuildInfo
              ⫽ { build-depends =
                      [ deps.base
                      , deps.bytestring
                      , deps.containers
                      , deps.contravariant
                      , deps.cryptonite
                      , deps.dhall
                      , deps.eta-java-interop
                      , deps.megaparsec
                      , deps.memory
                      , deps.scientific
                      , deps.serialise
                      , deps.text
                      , deps.transformers
                      ]
                    # [ deps.dotgen, deps.lens, deps.prettyprinter ]
                , exposed-modules =
                    [ "Dhall.Eta"
                    , "Dhall.Eta.Binary"
                    , "Dhall.Eta.Context"
                    , "Dhall.Eta.Core"
                    , "Dhall.Eta.Core.Java"
                    , "Dhall.Eta.Import"
                    , "Dhall.Eta.Parser"
                    , "Dhall.Eta.Parser.Java"
                    , "Dhall.Eta.TypeCheck"
                    , "Dhall.Eta.TypeCheck.Java"
                    , "Eta.Types"
                    ]
                , hs-source-dirs =
                    [ "src/main/eta" ]
                , java-sources =
                    [ "@classes.java" ]
                , other-modules =
                    [ "Dhall.Eta.Map" ]
                }
            )
        , executables =
            [ comp.executable
              (   prelude.defaults.SimpleBuildInfo
                ⫽ { name =
                      "dhall-eta-all"
                  , build-depends =
                      [ deps.base, any "dhall-eta" ]
                  , hs-source-dirs =
                      [ "examples/src/main/eta" ]
                  , main-is =
                      "Main.hs"
                  }
              )
            ]
        , test-suites =
            [ comp.test-suite
              (   prelude.defaults.SimpleBuildInfo
                ⫽ { name =
                      "tasty"
                  , main-is =
                      "Dhall/Eta/Test/Main.hs"
                  , build-depends =
                        [ deps.base
                        , deps.dhall
                        , deps.directory
                        , deps.filepath
                        , deps.tasty
                        , deps.text
                        , deps.transformers
                        ]
                      # [ deps.dhall-eta, deps.tasty-hunit ]
                  , hs-source-dirs =
                      [ "src/test/eta" ]
                  , other-modules =
                      [ "Dhall.Eta.Test.Common"
                      , "Dhall.Eta.Test.Import"
                      , "Dhall.Eta.Test.Normalization"
                      , "Dhall.Eta.Test.Parser"
                      , "Dhall.Eta.Test.TypeCheck"
                      ]
                  }
              )
            ]
        }
    )
