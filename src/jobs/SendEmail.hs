{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE FlexibleContexts #-}
import Control.Applicative((<$>))
import Control.Monad(forM_, liftM)
import Control.Monad.Trans.Control(MonadBaseControl)
import Control.Monad.IO.Class(MonadIO)
import Control.Monad.Logger(MonadLogger, runStderrLoggingT)
import Control.Monad.Trans.Reader(runReaderT, ReaderT)
import Control.Monad.Trans(liftIO)
import qualified Data.ByteString.Char8 as BCH
import Data.Monoid(mconcat)
import Data.Maybe(catMaybes)
import qualified Data.Traversable as T
import Database.Persist(Entity(..), PersistEntity)
import Database.Persist.Sql(SqlBackend)
import Database.Persist.Postgresql(withPostgresqlConn, runSqlPersistM)
import Data.Text(Text, append)
import DB.Settings(postgresConnString)
import SendGrid(SendGridEmail(..), sendEmail) 
import Queries.Group(allGroups, linkUserGroup)
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
  runStderrLoggingT $ withPostgresqlConn connStr $ \conn -> do
      liftIO $ flip runSqlPersistM conn $ do 
        xs <- extractEntities `liftM` linkUserGroup
        apiKey <- liftIO $ BCH.pack <$> getEnv "SENDGRID_API_KEY"
        liftIO $ do 
          T.mapM (sendEmail apiKey) $ emailsForGroup $ sortByGroup xs
          return ()

type GroupName = Text

sortByGroup :: [(Link, AuthUser, Group)] -> Map GroupName [(Link, AuthUser)]
sortByGroup xs = foldr insertLinkUser empty xs
  where 
    insertLinkUser :: (Link, AuthUser, Group) -> Map GroupName [(Link, AuthUser)] -> Map GroupName [(Link, AuthUser)] 
    insertLinkUser (link, user, group) hash = case lookup (groupName group) hash of 
                                                  Just a -> insert (groupName group) ((link, user) : a) hash
                                                  Nothing -> insert (groupName group) [(link, user)] hash

emailsForGroup :: Map GroupName [(Link, AuthUser)] -> Map GroupName SendGridEmail
emailsForGroup hash = mapWithKey generateEmail hash
  where
    generateEmail :: GroupName -> [(Link, AuthUser)] -> SendGridEmail
    generateEmail key xs = SendGridEmail userEmails "no-reply@mavenweekly.com" ("Maven Weekly: " `append` key) links
      where
        userEmails = catMaybes $ map (userEmail . snd) xs
        links = foldr (\x acc -> (formatLink x) `append` acc ) "" xs
          where
            formatLink (link, user) = linkUrl link `append` " from " `append` (userLogin user) `append` " \n\n\n"


extractEntities :: (PersistEntity a, PersistEntity c) => [(Entity a, b, Entity c)] -> [(a, b, c)]
extractEntities xs = flip map xs $ (\(x, y, z) -> (entityVal x, y, entityVal z) )
