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
import qualified Database.Persist.TH  as DPTH
import qualified Data.Text as T
import           Data.Time.Clock(UTCTime)
import           Snap.Snaplet.Auth.Backends.Persistent(SnapAuthUserId)

DPTH.share [DPTH.mkPersist DPTH.sqlSettings, DPTH.mkMigrate "migrateAll"] [DPTH.persistLowerCase|
  Group
    name T.Text
    deriving Show Eq Ord
  UserGroup
    user_id SnapAuthUserId
    group_id GroupId
    deriving Show
  Link
    createdAt UTCTime default=CURRENT_DATE
    groupId  GroupId
    addedByUserId SnapAuthUserId
    url T.Text
    sent Bool default=False
    deriving Show
|]
