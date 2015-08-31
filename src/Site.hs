{-# LANGUAGE EmptyDataDecls             #-}
{-# LANGUAGE OverloadedStrings          #-}
------------------------------------------------------------------------------

------------------------------------------------------------------------------
-- | This module is where all the routes and handlers are defined for your
-- site. The 'app' function is the initializer that combines everything
-- together and is exported by this module.
module Site (app) where
------------------------------------------------------------------------------
import           Application
import qualified Database.Persist.Sql as DPSQL
import           Control.Lens(view)
import           Data.ByteString (ByteString)
import           Database.Persist
import           Heist
import           Schema(migrateAll)
import           Snap.Core
import           Snap.Snaplet
import           Snap.Snaplet.Auth hiding (requireUser)
import           Snap.Snaplet.Auth.Backends.Persistent(initPersistAuthManager, migrateAuth)
import           Snap.Snaplet.Heist(heistInit)
import           Snap.Snaplet.Session.Backends.CookieSession(initCookieSessionManager)
import           Snap.Snaplet.Persistent(initPersist, persistPool)
import           Snap.Util.FileServe(serveDirectory)
import           Handlers.Authentication(handleLoginSubmit, handleLogin, handleLogout)
import           Handlers.Filters(requireUser, requireNoUser)
import           Handlers.Links(addLink, newLink)
import           Handlers.Users(handleNewUser)

routes :: [(ByteString, Handler App App ())]
routes = [
            ("/", method GET $ redirect "/login" )
          , ("/login",  requireNoUser "/new-link" $ with auth handleLoginSubmit)
          , ("/logout", with auth handleLogout)
          , ("/add-link", requireUser addLink)
          , ("/new-link", requireUser newLink)
          , ("/new_user", requireNoUser "/new-link" $ with auth handleNewUser)
          , ("",          serveDirectory "static")
         ]

app :: SnapletInit App App
app = makeSnaplet "app" "An snaplet example application." Nothing $ do
    d <- nestSnaplet "db" db $ initPersist (DPSQL.runMigrationUnsafe migrateAll) 
    -- Yea yea ok this is dumb. Show me how to really do it right.
    _ <- nestSnaplet "db" db $ initPersist (DPSQL.runMigrationUnsafe migrateAuth)
    s <- nestSnaplet "sess" sess $ initCookieSessionManager "site_key.txt" "sess" (Just 3600)
    a <- nestSnaplet "auth" auth $ initPersistAuthManager sess (persistPool $ snapletValue `view` d)
    h <- nestSnaplet "" heist $ heistInit "templates"
    addRoutes routes
    return $ App d s a h
