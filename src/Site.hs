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
import           Control.Monad.Trans(liftIO)
import           Data.ByteString (ByteString)
import           Database.Persist
import           DB.Settings(postgresConnString, postgresPoolSize)
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
import           System.Directory(getCurrentDirectory)
import           Handlers.Authentication(handleLoginSubmit, handleLogin, handleLogout)
import           Handlers.Filters(requireUser, requireNoUser)
import           Handlers.Links(addLink, newLink)
import           Handlers.Users(handleNewUser)

routes :: [(ByteString, Handler App App ())]
routes = [
            ("/", method GET $ redirect "/new-link" )
          , ("/login",  requireNoUser "/new-link" $ with auth handleLoginSubmit)
          , ("/add-link", requireUser addLink)
          , ("/new-link", requireUser newLink)
          , ("/new_user", requireNoUser "/new-link" $ with auth handleNewUser)
          , ("",          serveDirectory "static")
         ]

writePostgresConnectionVariables :: IO ()
writePostgresConnectionVariables = do 
  connectionString <- postgresConnString
  currentDir <- getCurrentDirectory
  let filePath = currentDir ++ "/snaplets/persist/devel.cfg"
  writeFile filePath ("postgre-con-str=" ++ show connectionString ++ "\n" ++ postgresPoolSize)

app :: SnapletInit App App
app = makeSnaplet "app" "An snaplet example application." Nothing $ do
    liftIO writePostgresConnectionVariables
    nestSnaplet "db" db $ initPersist $ DPSQL.runMigrationUnsafe migrateAuth
    d <- nestSnaplet "db" db $ initPersist (DPSQL.runMigrationUnsafe migrateAll) 
    s <- nestSnaplet "sess" sess $ initCookieSessionManager "site_key.txt" "sess" (Just 3600)
    a <- nestSnaplet "auth" auth $ initPersistAuthManager sess (persistPool $ snapletValue `view` d)
    h <- nestSnaplet "" heist $ heistInit "templates"
    addRoutes routes
    return $ App d s a h
