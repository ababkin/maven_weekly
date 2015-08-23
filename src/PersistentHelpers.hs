module PersistentHelpers(groupIdFromParam, idFromGroupEntity, groupsForUser) where
import           Data.ByteString (ByteString)
import           Database.Persist.Sql
import           Data.Text(Text)
import           Schema
import           StringHelpers(byteStringToString)
import qualified Database.Esqueleto      as E
import           Snap.Snaplet.Auth(AuthUser)
import           Snap.Snaplet.Auth.Backends.Persistent(userDBKey)
import           Database.Esqueleto((^.))
import           Control.Monad.Trans(MonadIO)
import           Control.Monad.Reader(ReaderT)
import           Data.Maybe(fromJust)

groupIdFromParam :: ByteString -> GroupId
groupIdFromParam = GroupKey . SqlBackendKey . fromIntegral . read . byteStringToString

idFromGroupEntity :: Entity Group -> Int
idFromGroupEntity = fromIntegral . unSqlBackendKey . unGroupKey . entityKey

groupsForUser :: MonadIO a => AuthUser -> ReaderT SqlBackend a [Entity Group]
groupsForUser user = do 
  E.select $ E.from $ \(group `E.InnerJoin` userGroup) -> do
              E.on $ group ^. GroupId E.==. userGroup ^. UserGroupGroup_id
              E.where_ ( userGroup ^. UserGroupUser_id E.==. (E.val . fromJust $ userDBKey user ))
              return group

