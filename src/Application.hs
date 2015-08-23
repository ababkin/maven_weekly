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
-- Snap.Snaplet.Router.Types exports everything you need to
-- -- define your PathInfo and HasRouter instances.
import Snap.Snaplet.Router.Types
import Data.Int(Int64)
import Snap.Snaplet.Heist


------------------------------------------------------------------------------
------------------------------------------------------------------------------
data AppUrl = AddLink |  NewLink deriving (Eq, Show, Read, Generic)

data App = App { 
      _db :: Snaplet PersistState
    , _router :: Snaplet RouterState
    , _sess :: Snaplet SessionManager
    , _auth :: Snaplet (AuthManager App)
    , _heist :: Snaplet (Heist App)
  }

instance PathInfo AppUrl where
  toPathSegments  AddLink = ["add-link"]
  toPathSegments  NewLink = ["new-link"]
  fromPathSegments        = AddLink <$ segment "add-link"
                            <|> NewLink <$ segment "new-link"


makeLenses ''App

instance HasHeist App where
    heistLens = subSnaplet heist


-- You need to define a HasRouter instance for your app.
-- You must set type URL (Handler App App) to the URL
-- data type you defined above. The router in
-- `with router` is the lens for the @RouterState@ snaplet
-- you added to App.
instance HasRouter (Handler App App) where
    type URL (Handler App App) = AppUrl
    getRouterState = with router MS.get

instance HasPersistPool (Handler b App) where
  getPersistPool = with db getPersistPool


------------------------------------------------------------------------------
type AppHandler = Handler App App
