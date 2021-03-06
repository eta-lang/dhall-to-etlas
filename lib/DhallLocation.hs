{-# language OverloadedStrings #-}

module DhallLocation
  ( DhallLocation(..)
  , dhallFromGitHub
  )
  where

import Data.Version ( showVersion )

import qualified Data.Text as StrictText
import qualified Dhall.Core

import qualified Paths_dhall_to_etlas as Paths


data DhallLocation = DhallLocation
  { preludeLocation :: Dhall.Core.Import
  , typesLocation :: Dhall.Core.Import
  }


version :: StrictText.Text
version = StrictText.pack ( showVersion Paths.version )


dhallFromGitHub :: DhallLocation
dhallFromGitHub =
  DhallLocation
    { preludeLocation =
        Dhall.Core.Import
          { Dhall.Core.importHashed =
              Dhall.Core.ImportHashed
                { Dhall.Core.hash =
                    Nothing
                , Dhall.Core.importType =
                    Dhall.Core.Remote
                      ( Dhall.Core.URL
                          Dhall.Core.HTTPS
                          "raw.githubusercontent.com"
                          ( Dhall.Core.File
                             ( Dhall.Core.Directory [ "dhall", version, "dhall-to-etlas", "eta-lang" ] )
                             "prelude.dhall"
                          )
                          Nothing
                          Nothing
                      )
                }
          , Dhall.Core.importMode =
              Dhall.Core.Code
          }

    , typesLocation =
        Dhall.Core.Import
          { Dhall.Core.importHashed =
              Dhall.Core.ImportHashed
                { Dhall.Core.hash =
                    Nothing
                , Dhall.Core.importType =
                    Dhall.Core.Remote
                      ( Dhall.Core.URL
                          Dhall.Core.HTTPS
                          "raw.githubusercontent.com"
                          ( Dhall.Core.File
                             ( Dhall.Core.Directory [ "dhall", version, "dhall-to-etlas", "eta-lang" ] )
                             "types.dhall"
                          )
                          Nothing
                          Nothing
                      )
                }
          , Dhall.Core.importMode =
              Dhall.Core.Code
          }
    }
