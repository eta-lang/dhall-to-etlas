let ty = ../types.dhall

let sensibleDefaults = ../defaults/BuildInfo.dhall

let clearOpts
    : ty.CompilerOptions → ty.CompilerOptions
    =   λ(bi : ty.CompilerOptions)
      → let emptyText = [] : List Text
        
        in    bi
            ⫽ { Eta =
                  emptyText
              , GHC =
                  emptyText
              , GHCJS =
                  emptyText
              , HBC =
                  emptyText
              , Helium =
                  emptyText
              , Hugs =
                  emptyText
              , JHC =
                  emptyText
              , LHC =
                  emptyText
              , NHC =
                  emptyText
              , UHC =
                  emptyText
              , YHC =
                  emptyText
              }

let clearBI
    : ty.BuildInfo → ty.BuildInfo
    =   λ(bi : ty.BuildInfo)
      →   bi
        ⫽ sensibleDefaults
        ⫽ { default-extensions =
              [] : List ty.Extension
          , default-language =
              None ty.Language
          , compiler-options =
              clearOpts bi.compiler-options
          , profiling-options =
              clearOpts bi.profiling-options
          , shared-options =
              clearOpts bi.shared-options
          }

in  clearBI
