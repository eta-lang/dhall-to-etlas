let prelude = ./../../dhall/prelude.dhall

let types = ./../../dhall/types.dhall

in    prelude.defaults.Package
    ⫽ { cabal-version =
          prelude.v "2.0"
      , flags =
          [ { default =
                False
            , description =
                "print debug output. not suitable for production"
            , manual =
                False
            , name =
                "wai-servlet-debug"
            }
          ]
      , library =
          Some
          (   λ(config : types.Config)
            →       if config.impl
                       types.Compiler.GHC
                       ( prelude.unionVersionRanges
                         (prelude.thisVersion (prelude.v "0.0.9.7"))
                         (prelude.laterVersion (prelude.v "0.0.9.7"))
                       )
              
              then        if config.impl
                             types.Compiler.GHC
                             (prelude.earlierVersion (prelude.v "0.7.0.2"))
                    
                    then        if config.impl
                                   types.Compiler.GHC
                                   ( prelude.unionVersionRanges
                                     (prelude.thisVersion (prelude.v "0.0.9"))
                                     (prelude.laterVersion (prelude.v "0.0.9"))
                                   )
                          
                          then        if config.flag "wai-servlet-debug"
                                
                                then    prelude.defaults.Library
                                      ⫽ { cpp-options =
                                            [ "-DINTEROP"
                                            , "-DPURE_JAVA_WITH"
                                            , "-DWAI_SERVLET_DEBUG"
                                            ]
                                        , default-extensions =
                                            [] : List types.Extension
                                        , maven-depends =
                                            [ "javax.servlet:servlet-api:2.5" ]
                                        }
                                
                                else    prelude.defaults.Library
                                      ⫽ { cpp-options =
                                            [ "-DINTEROP", "-DPURE_JAVA_WITH" ]
                                        , default-extensions =
                                            [] : List types.Extension
                                        }
                          
                          else  if config.flag "wai-servlet-debug"
                          
                          then    prelude.defaults.Library
                                ⫽ { cpp-options =
                                      [ "-DINTEROP"
                                      , "-DPURE_JAVA_WITH"
                                      , "-DWAI_SERVLET_DEBUG"
                                      ]
                                  , default-extensions =
                                      [] : List types.Extension
                                  , maven-depends =
                                      [ "javax.servlet:servlet-api:2.5" ]
                                  }
                          
                          else    prelude.defaults.Library
                                ⫽ { cpp-options =
                                      [ "-DINTEROP", "-DPURE_JAVA_WITH" ]
                                  , default-extensions =
                                      [] : List types.Extension
                                  }
                    
                    else  if config.impl
                             types.Compiler.GHC
                             ( prelude.unionVersionRanges
                               (prelude.thisVersion (prelude.v "0.0.9"))
                               (prelude.laterVersion (prelude.v "0.0.9"))
                             )
                    
                    then        if config.flag "wai-servlet-debug"
                          
                          then    prelude.defaults.Library
                                ⫽ { cpp-options =
                                      [ "-DINTEROP", "-DWAI_SERVLET_DEBUG" ]
                                  , default-extensions =
                                      [] : List types.Extension
                                  , maven-depends =
                                      [ "javax.servlet:servlet-api:2.5" ]
                                  }
                          
                          else    prelude.defaults.Library
                                ⫽ { cpp-options =
                                      [ "-DINTEROP" ]
                                  , default-extensions =
                                      [] : List types.Extension
                                  }
                    
                    else  if config.flag "wai-servlet-debug"
                    
                    then    prelude.defaults.Library
                          ⫽ { cpp-options =
                                [ "-DINTEROP", "-DWAI_SERVLET_DEBUG" ]
                            , default-extensions =
                                [] : List types.Extension
                            , maven-depends =
                                [ "javax.servlet:servlet-api:2.5" ]
                            }
                    
                    else    prelude.defaults.Library
                          ⫽ { cpp-options =
                                [ "-DINTEROP" ]
                            , default-extensions =
                                [] : List types.Extension
                            }
              
              else  if config.impl
                       types.Compiler.GHC
                       (prelude.earlierVersion (prelude.v "0.7.0.2"))
              
              then        if config.impl
                             types.Compiler.GHC
                             ( prelude.unionVersionRanges
                               (prelude.thisVersion (prelude.v "0.0.9"))
                               (prelude.laterVersion (prelude.v "0.0.9"))
                             )
                    
                    then        if config.flag "wai-servlet-debug"
                          
                          then    prelude.defaults.Library
                                ⫽ { cpp-options =
                                      [ "-DPURE_JAVA_WITH"
                                      , "-DWAI_SERVLET_DEBUG"
                                      ]
                                  , default-extensions =
                                      [] : List types.Extension
                                  , maven-depends =
                                      [ "javax.servlet:servlet-api:2.5" ]
                                  }
                          
                          else    prelude.defaults.Library
                                ⫽ { cpp-options =
                                      [ "-DPURE_JAVA_WITH" ]
                                  , default-extensions =
                                      [] : List types.Extension
                                  }
                    
                    else  if config.flag "wai-servlet-debug"
                    
                    then    prelude.defaults.Library
                          ⫽ { cpp-options =
                                [ "-DPURE_JAVA_WITH", "-DWAI_SERVLET_DEBUG" ]
                            , default-extensions =
                                [] : List types.Extension
                            , maven-depends =
                                [ "javax.servlet:servlet-api:2.5" ]
                            }
                    
                    else    prelude.defaults.Library
                          ⫽ { cpp-options =
                                [ "-DPURE_JAVA_WITH" ]
                            , default-extensions =
                                [] : List types.Extension
                            }
              
              else  if config.impl
                       types.Compiler.GHC
                       ( prelude.unionVersionRanges
                         (prelude.thisVersion (prelude.v "0.0.9"))
                         (prelude.laterVersion (prelude.v "0.0.9"))
                       )
              
              then        if config.flag "wai-servlet-debug"
                    
                    then    prelude.defaults.Library
                          ⫽ { cpp-options =
                                [ "-DWAI_SERVLET_DEBUG" ]
                            , default-extensions =
                                [] : List types.Extension
                            , maven-depends =
                                [ "javax.servlet:servlet-api:2.5" ]
                            }
                    
                    else    prelude.defaults.Library
                          ⫽ { default-extensions = [] : List types.Extension }
              
              else  if config.flag "wai-servlet-debug"
              
              then    prelude.defaults.Library
                    ⫽ { cpp-options =
                          [ "-DWAI_SERVLET_DEBUG" ]
                      , default-extensions =
                          [] : List types.Extension
                      , maven-depends =
                          [ "javax.servlet:servlet-api:2.5" ]
                      }
              
              else    prelude.defaults.Library
                    ⫽ { default-extensions = [] : List types.Extension }
          )
      , license =
          types.License.Unspecified
      , name =
          "wai-servlet"
      , version =
          prelude.v "0.1.5.0"
      }
