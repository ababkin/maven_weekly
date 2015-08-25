{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE FlexibleContexts #-}
import Control.Applicative((<$>))
import Control.Monad.Trans.Control(MonadBaseControl)
import Control.Monad.IO.Class(MonadIO)
import Control.Monad.Logger(MonadLogger, runStderrLoggingT)
import Control.Monad.Trans.Reader(runReaderT, ReaderT)
import Control.Monad.Trans(liftIO)
import Database.Persist(Entity(..))
import Database.Persist.Sql(SqlBackend)
import Database.Persist.Postgresql(withPostgresqlConn, runSqlPersistM)
import Data.Text(Text)
import SendGrid(SendGridEmail, sendEmail) 
import Queries.Group(allGroups)
import Schema

import Snap.Snaplet(with)
import Snap.Snaplet.Auth(AuthUser)
import Snap.Snaplet.Auth.Backends.Persistent(SnapAuthUser)

data NewsLetter = NewsLetter {
    newsLetterContent :: [Text]
  , newsLetterRecipients :: [Entity SnapAuthUser]
}


connStr = "host='localhost' dbname='snap-test' user='jamesvanneman' password=''"

main :: IO ()
main = do
  runStderrLoggingT $ withPostgresqlConn connStr $ \conn -> do
      liftIO $ flip runSqlPersistM conn $ do 
        groups <- allGroups
        liftIO $ print groups


groupIdFromLink :: Entity Link -> GroupId
groupIdFromLink = undefined

linkContent :: Entity Link -> Text
linkContent = undefined

generateEmailFor :: NewsLetter -> SendGridEmail
generateEmailFor = undefined
