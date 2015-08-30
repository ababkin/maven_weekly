{-# LANGUAGE OverloadedStrings #-}
module Handlers.Links(addLink, newLink) where
  import           Application(AppUrl(..), App)
  import           Control.Applicative((<*>), (<$>), liftA)
  import           Control.Monad.Trans(liftIO)
  import           Database.Persist(insert, Entity(..))
  import           Data.Text(pack)
  import           Data.Time.Clock(getCurrentTime)
  import           Data.Monoid(mempty)
  import           Heist((##), Splices)
  import           Handlers.Filters(redirectIfNoUser, requireNoUser)
  import qualified Heist.Interpreted as I
  import           Queries.Group(groupIdFromParam, groupsForUser, idFromGroupEntity)
  import           Schema
  import           Snap.Core(redirect, method, Method(..), getPostParam, modifyResponse, setResponseStatus)
  import           Snap.Snaplet(Handler)
  import           Snap.Snaplet.Auth(AuthUser, AuthManager)
  import           Snap.Snaplet.Auth.Backends.Persistent(userDBKey)
  import           Snap.Snaplet.Heist(render, heistLocal, SnapletISplice)
  import           Snap.Snaplet.Persistent(runPersist)
  import           StringHelpers( byteStringToText )

  addLink :: AuthUser -> Handler App App ()
  addLink user = method POST $ do 
                          link <- getPostParam "link"
                          groupId <- (\x -> groupIdFromParam <$> x ) `liftA` getPostParam "group_id"
                          let currentUserId = userDBKey user
                          require3Params link groupId currentUserId $ \link gid userId -> do
                            currentTime <- liftIO getCurrentTime
                            -- TODO: Make sure the user is actually a part of this group
                            runPersist . insert $ Link currentTime gid userId (byteStringToText link) False
                            modifyResponse $ setResponseStatus 201 ""
                            render "add_link_success"
                            return ()

  newLink :: AuthUser -> Handler App App ()
  newLink user = method GET $ do 
    let userId = userDBKey user
    case userId of 
         Just id -> do
          userGroups <- runPersist $ groupsForUser user
          let splices = allLinkToGroupForms userGroups
          heistLocal (I.bindSplices splices) $ render "link_form" 
         Nothing -> do 
           modifyResponse $ setResponseStatus 403 ""
           redirect "/login"

  allLinkToGroupForms :: [Entity Group] -> Splices (SnapletISplice App)
  allLinkToGroupForms userGroups = "groupLinkForms" ## (renderLinkForms userGroups)

  renderLinkForms :: [Entity Group] -> SnapletISplice App
  renderLinkForms = I.mapSplices $ I.runChildrenWith . linkFormFromGroup

  linkFormFromGroup :: Monad n => Entity Group -> Splices (I.Splice n)
  linkFormFromGroup group = do
    "groupId"  ## I.textSplice . pack . show  $ idFromGroupEntity group
    "groupName"  ## I.textSplice  . groupName $ entityVal group

  require3Params :: (Show a, Show b, Show c) => Maybe a -> Maybe b -> Maybe c -> (a -> b -> c -> Handler App App ()) -> Handler App App ()
  require3Params a b c fn = case fn <$> a <*> b <*> c of 
                               Just a -> a >> return ()
                               Nothing -> do 
                                 render "missing_params"
                                 modifyResponse $ setResponseStatus 422 ""
                                 return ()
