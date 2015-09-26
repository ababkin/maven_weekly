{-# LANGUAGE OverloadedStrings #-}
module Handlers.Users(handleNewUser) where
  import           Application(App)
  import           Control.Applicative.Alternative((<|>))
  import           Snap.Core(redirect, method, Method(..))
  import           Snap.Snaplet(Handler)
  import           Snap.Snaplet.Auth(AuthManager, registerUser)
  import           Snap.Snaplet.Heist(render)

  handleNewUser :: Handler App (AuthManager App) ()
  handleNewUser = method GET handleForm <|> method POST handleFormSubmit
    where
      handleForm = render "new_user"
      handleFormSubmit = registerUser "login" "password" >> redirect "/"

