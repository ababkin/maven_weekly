{-# LANGUAGE OverloadedStrings #-}
module Handlers.Filters(requireUser, requireNoUser) where
  import           Application(auth)
  import           Snap.Snaplet(with)
  import           Snap.Core(redirect, modifyResponse, setResponseStatus)
  import           Snap.Snaplet.Auth(currentUser)

  requireNoUser redirectPath handler = do 
    retrievedUser <- with auth currentUser
    case retrievedUser of
         Just user -> redirect redirectPath
         Nothing   -> handler

  requireUser actionWithUser =  do 
    retrievedUser <- with auth currentUser
    case retrievedUser of 
         Just user -> actionWithUser user
         Nothing   -> do 
          modifyResponse $ setResponseStatus 403 ""
          redirect "/login"

