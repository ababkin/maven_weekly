{-# LANGUAGE QuasiQuotes                #-}
{-# LANGUAGE MultiParamTypeClasses      #-}
{-# LANGUAGE TemplateHaskell            #-}
{-# LANGUAGE FlexibleInstances          #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE GADTs                      #-}
{-# LANGUAGE TypeFamilies               #-}
{-# LANGUAGE EmptyDataDecls               #-}
{-# LANGUAGE FlexibleContexts      #-}
{-# LANGUAGE OverloadedStrings          #-}


module Schema where
import qualified Data.Text as T
import qualified Database.Persist.TH  as DPTH
import           Snap.Snaplet.Auth.Backends.Persistent(SnapAuthUserId)
import           Data.Time.Clock(UTCTime)

DPTH.share [DPTH.mkPersist DPTH.sqlSettings, DPTH.mkMigrate "migrateAll"] [DPTH.persistLowerCase|
  Group
    name T.Text
    deriving Show Eq Ord
  UserGroup
    user_id SnapAuthUserId
    group_id GroupId
    deriving Show
  Link
    createdAt UTCTime default=CURRENT_TIME
    groupId  GroupId
    addedByUserId SnapAuthUserId
    url T.Text
    sent Bool default=False
    UniqueGroupUserId groupId addedByUserId
    deriving Show
|]
