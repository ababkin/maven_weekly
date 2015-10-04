{-# LANGUAGE OverloadedStrings #-}
module Handlers.Filters(requireUser, requireNoUser) where
  import           Application(auth)
  import           Snap.Snaplet(with)
  import           Snap.Core(redirect, modifyResponse, setResponseStatus)
  import           Snap.Snaplet.Auth(currentUser)

  requireNoUser redirectPath handler =
    maybe handler (const $ redirect redirectPath) =<< with auth currentUser

  requireUser actionWithUser =
    maybe (modifyResponse (setResponseStatus 403 "") >> redirect "/login") actionWithUser =<< with auth currentUser

