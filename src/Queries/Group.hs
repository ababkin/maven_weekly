{-# LANGUAGE RankNTypes        #-}
{-# LANGUAGE FlexibleContexts  #-}
module Queries.Group( groupsForUser, groupIdFromParam, idFromGroupEntity, usersInGroup, linksForGroup, allGroups) where

import           Control.Applicative((<$>))
import           Control.Monad.Trans(MonadIO)
import           Control.Monad.Reader(ReaderT)
import           Control.Monad.Logger(MonadLogger)
import           Control.Monad.Trans.Control(MonadBaseControl)
import           Data.Text(Text)
import           Data.ByteString (ByteString)
import           Database.Persist.Sql
import qualified Database.Esqueleto      as E
import           Database.Esqueleto((^.))
import           Data.Maybe(fromJust)
import           Schema
import           StringHelpers(byteStringToString)
import           Snap.Snaplet.Auth(AuthUser(..))
import           Snap.Snaplet.Auth.Backends.Persistent

type PersistentBackend = MonadIO a => ReaderT SqlBackend a [Entity Group] 

-- allLinksForGroups :: (MonadBaseControl IO a, MonadLogger a, MonadIO a) => ReaderT SqlBackend a [(E.Value (Key Group), E.Value Text)]
-- allLinksForGroups = E.select $ E.from $ \link -> do 
                      -- E.groupBy ( link ^. LinkGroupId )
                      -- return (link ^. LinkGroupId, link ^. LinkUrl)

allGroups :: (MonadBaseControl IO a, MonadLogger a, MonadIO a) => ReaderT SqlBackend a [Entity Group]
allGroups = E.select $ E.from (\g -> return g)

groupIdFromParam :: ByteString -> GroupId
groupIdFromParam = GroupKey . SqlBackendKey . fromIntegral . read . byteStringToString

idFromGroupEntity :: Entity Group -> Int
idFromGroupEntity = fromIntegral . unSqlBackendKey . unGroupKey . entityKey

usersInGroup :: (MonadBaseControl IO m, MonadLogger m, MonadIO m) => Entity Group ->  SqlPersistT m [AuthUser]
usersInGroup  entityGroup = fmap (map db2au) $ do 
                              E.select $ E.from $ \(user `E.InnerJoin` userGroup `E.InnerJoin` group) -> do
                                  E.on $ group ^. GroupId E.==. userGroup ^. UserGroupGroup_id
                                  E.on $ userGroup ^. UserGroupUser_id E.==. user ^. SnapAuthUserId
                                  E.where_ ( group ^. GroupId E.==. (E.val $ entityKey entityGroup) )
                                  return user

linksForGroup :: (MonadBaseControl IO m, MonadLogger m, MonadIO m) =>  Entity Group -> SqlPersistT m [Entity Link]
linksForGroup group = do
  E.select $ E.from $ \(link) -> do
              E.where_ ( link ^. LinkGroupId E.==. E.val (entityKey group) )
              return link


groupsForUser :: AuthUser -> PersistentBackend
groupsForUser user = do 
  E.select $ E.from $ \(group `E.InnerJoin` userGroup) -> do
              E.on $ group ^. GroupId E.==. userGroup ^. UserGroupGroup_id
              E.where_ ( userGroup ^. UserGroupUser_id E.==. (E.val . fromJust $ userDBKey user ))
              return group

