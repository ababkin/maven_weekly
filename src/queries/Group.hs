{-# LANGUAGE RankNTypes        #-}
module Queries.Group(groupIdFromParam, idFromGroupEntity, groupsForUser, allLinksForGroups, usersForGroupId) where
import           Control.Monad.Trans(MonadIO)
import           Control.Monad.Reader(ReaderT)
import           Data.ByteString (ByteString)
import           Database.Persist.Sql
import qualified Database.Esqueleto      as E
import           Database.Esqueleto((^.))
import           Data.Maybe(fromJust)
import           Schema
import           StringHelpers(byteStringToString)
import           Snap.Snaplet.Auth(AuthUser)
import           Snap.Snaplet.Auth.Backends.Persistent(userDBKey, SnapAuthUser)

type PersistentBackend = MonadIO a => ReaderT SqlBackend a [Entity Group] 

allLinksForGroups :: MonadIO a => ReaderT SqlBackend a [Entity Link]
allLinksForGroups = E.select $ E.from $ \link -> do 
                      E.groupBy ( link ^. LinkGroupId )
                      return link
usersForGroupId :: MonadIO a => ReaderT SqlBackend a [Entity SnapAuthUser]
usersForGroupId = undefined

groupIdFromParam :: ByteString -> GroupId
groupIdFromParam = GroupKey . SqlBackendKey . fromIntegral . read . byteStringToString

idFromGroupEntity :: Entity Group -> Int
idFromGroupEntity = fromIntegral . unSqlBackendKey . unGroupKey . entityKey

groupsForUser :: AuthUser -> PersistentBackend
groupsForUser user = do 
  E.select $ E.from $ \(group `E.InnerJoin` userGroup) -> do
              E.on $ group ^. GroupId E.==. userGroup ^. UserGroupGroup_id
              E.where_ ( userGroup ^. UserGroupUser_id E.==. (E.val . fromJust $ userDBKey user ))
              return group

