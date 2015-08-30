{-# LANGUAGE TypeFamilies      #-} -- web-routes
{-# LANGUAGE TemplateHaskell     #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE DeriveGeneric     #-}
{-# LANGUAGE OverloadedStrings          #-}


------------------------------------------------------------------------------
-- | This module defines our application's state type and an alias for its
-- handler monad.
module Application where

------------------------------------------------------------------------------
import Snap.Snaplet.Auth
import Snap.Snaplet.Session
import Control.Lens
import Control.Applicative.Alternative((<|>))
import Control.Applicative ((<$), (<*>), (<$>))
import Database.Persist.Sql
import Snap.Snaplet
import Database.Persist.Class (PersistEntity(..))
import Web.Routes.PathInfo(PathInfo(..), segment)
import Snap.Snaplet.Persistent
import Schema
import Web.PathPieces
import qualified Control.Monad.State as MS
-- Paths and params use Text.
import Data.Text (Text)
import Data.Int(Int64)
import Snap.Snaplet.Heist


------------------------------------------------------------------------------
------------------------------------------------------------------------------

data App = App { 
      _db :: Snaplet PersistState
    , _sess :: Snaplet SessionManager
    , _auth :: Snaplet (AuthManager App)
    , _heist :: Snaplet (Heist App)
  }


makeLenses ''App

instance HasHeist App where
    heistLens = subSnaplet heist

instance HasPersistPool (Handler b App) where
  getPersistPool = with db getPersistPool


------------------------------------------------------------------------------
type AppHandler = Handler App App
