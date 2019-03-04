  ./SimplePackage.dhall
⩓ { bug-reports :
      Text
  , build-type :
      Optional ./BuildType.dhall
  , cabal-version :
      ./Version.dhall
  , copyright :
      Text
  , custom-setup :
      Optional ./CustomSetup.dhall
  , data-dir :
      Text
  , data-files :
      List Text
  , extra-doc-files :
      List Text
  , extra-tmp-files :
      List Text
  , flags :
      List { default : Bool, description : Text, manual : Bool, name : Text }
  , foreign-libraries :
      List { foreign-lib : ./Guarded.dhall ./ForeignLibrary.dhall, name : Text }
  , homepage :
      Text
  , package-url :
      Text
  , source-repos :
      List ./SourceRepo.dhall
  , stability :
      Text
  , sub-libraries :
      List { library : ./Guarded.dhall ./Library.dhall, name : Text }
  , tested-with :
      List { compiler : ./Compiler.dhall, version : ./VersionRange.dhall }
  , version :
    ./Version.dhall
  , x-fields :
      List { _1 : Text, _2 : Text }
  }
