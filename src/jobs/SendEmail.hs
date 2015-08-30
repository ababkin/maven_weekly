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
import Data.Hashable(Hashable(..))
import Data.Monoid(mconcat)
import Data.Maybe(catMaybes)
import qualified Data.Traversable as T
import Database.Persist(Entity(..), PersistEntity)
import Database.Persist.Sql(SqlBackend)
import Database.Persist.Postgresql(withPostgresqlConn, runSqlPersistM)
import Data.Text(Text)
import SendGrid(SendGridEmail(..), sendEmail) 
import Queries.Group(allGroups, linkUserGroup)
import Schema

import Snap.Snaplet(with)
import Snap.Snaplet.Auth(AuthUser(..))
import Snap.Snaplet.Auth.Backends.Persistent(SnapAuthUser)
import StringHelpers(byteStringToString)
import Data.HashMap(Map, insert, empty, insertWith, lookup)
import Prelude hiding(lookup)
import System.Environment(getEnv)

data NewsLetter = NewsLetter {
    newsLetterContent :: [Text]
  , newsLetterRecipients :: [Entity SnapAuthUser]
}


connStr = "host='localhost' dbname='snap-test' user='jamesvanneman' password=''"


sortByGroup :: [(Link, AuthUser, Group)] -> Map Text [(Link, AuthUser)]
sortByGroup xs = foldr insertLinkUser empty xs
  where 
    insertLinkUser :: (Link, AuthUser, Group) -> Map Text [(Link, AuthUser)] -> Map Text [(Link, AuthUser)] 
    insertLinkUser (link, user, group) hash = case lookup (groupName group) hash of 
                                                  Just a -> insert (groupName group) ((link, user) : a) hash
                                                  Nothing -> insert (groupName group) [(link, user)] hash

emailsForGroup :: Map Text [(Link, AuthUser)] -> Map Text SendGridEmail
emailsForGroup hash = mapWithKey generateEmail hash
  where
    generateEmail key xs = SendGridEmail userEmails "info@domain.com" "Some Subject" links
      where
        userEmails = foldr userEmail


extractEntities :: (PersistEntity a, PersistEntity c) => [(Entity a, b, Entity c)] -> [(a, b, c)]
extractEntities xs = flip map xs $ (\(x, y, z) -> (entityVal x, y, entityVal z) )

main :: IO ()
main = do
  runStderrLoggingT $ withPostgresqlConn connStr $ \conn -> do
      liftIO $ flip runSqlPersistM conn $ do 
        xs <- extractEntities `liftM` linkUserGroup
        apiKey <- liftIO $ BCH.pack <$> getEnv "SENDGRID_API_KEY"
        liftIO $ do 
          T.mapM (sendEmail apiKey) $ emailsForGroup $ sortByGroup xs
          return ()
