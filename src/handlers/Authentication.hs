{-# LANGUAGE OverloadedStrings #-}
module Handlers.Authentication(handleLoginSubmit, handleLogin, handleLogout) where
  -- | The application's routes.
  import           Application(App)
  import           Data.Monoid(mempty)
  import           Data.Text(Text)
  import           Heist((##), Splices)
  import qualified Heist.Interpreted as I
  import           Snap.Core(redirect)
  import           Snap.Snaplet(Handler)
  import           Snap.Snaplet.Auth(AuthManager, loginUser, logout)
  import           Snap.Snaplet.Heist(render, heistLocal)

  handleLoginSubmit :: Handler App (AuthManager App) ()
  handleLoginSubmit =
      loginUser "login" "password" Nothing
                (\_ -> handleLogin err) (redirect "/")
    where
      err = Just "Unknown user or password"

  handleLogin :: Maybe Text -> Handler App (AuthManager App) ()
  handleLogin authError = heistLocal (I.bindSplices errs) $ render "login"
    where
      errs = maybe mempty splice authError
      splice err = "loginError" ## I.textSplice err

  ------------------------------------------------------------------------------
  -- | Logs out and redirects the user to the site index.
  handleLogout :: Handler App (AuthManager App) ()
  handleLogout = logout >> redirect "/"

