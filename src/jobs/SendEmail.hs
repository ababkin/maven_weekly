{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE FlexibleContexts #-}
import Control.Applicative((<$>))
import Control.Monad(forM_, liftM, void)
import Control.Monad.Trans.Control(MonadBaseControl)
import Control.Monad.IO.Class(MonadIO)
import Control.Monad.Logger(MonadLogger, runStderrLoggingT)
import Control.Monad.Trans.Reader(runReaderT, ReaderT)
import Control.Monad.Trans(liftIO)
import qualified Data.ByteString.Char8 as BCH
import Data.Monoid(mconcat)
import Data.Maybe(mapMaybe)
import qualified Data.Traversable as T
import Database.Persist(Entity(..), PersistEntity)
import Database.Persist.Sql(SqlBackend)
import Database.Persist.Postgresql(withPostgresqlConn, runSqlPersistM)
import Data.Text(Text, append)
import DB.Settings(postgresConnString)
import SendGrid(SendGridEmail(..), sendEmail) 
import Queries.Group(allGroups, linksForGroup, usersInGroup)
import Schema
import Snap.Snaplet(with)
import Snap.Snaplet.Auth(AuthUser(..))
import Snap.Snaplet.Auth.Backends.Persistent(SnapAuthUser)
import StringHelpers(byteStringToString)
import Data.HashMap(Map, insert, empty, insertWith, lookup, mapWithKey)
import Prelude hiding(lookup)
import System.Environment(getEnv)

main :: IO ()
main = do
  connStr <- BCH.pack <$> postgresConnString
  runStderrLoggingT $ withPostgresqlConn connStr $ \conn -> void $
      liftIO $ flip runSqlPersistM conn $ do 
        groups <- allGroups
        links <- mapM linksForGroup groups
        members <- mapM usersInGroup groups
        liftIO $ do 
          apiKey <- BCH.pack <$> getEnv "SENDGRID_API_KEY"
          T.mapM (sendEmail apiKey) $ emailsForGroup $ zip3 groups links members

emailsForGroup :: [(Entity Group, [Entity Link], [AuthUser])] -> [SendGridEmail]
emailsForGroup = map generateEmail
  where
    generateEmail :: (Entity Group, [Entity Link], [AuthUser]) -> SendGridEmail
    generateEmail (group, links, users) = SendGridEmail userEmails "no-reply@mavenweekly.com" ("Maven Weekly: " `append` (groupName $  entityVal group)) formattedLinks
      where
        userEmails = mapMaybe userEmail users
        formattedLinks = foldr (\x acc -> (formatLink x) `append` acc ) "" links
          where
            formatLink link  = linkUrl (entityVal link) `append` "\n\n\n"
