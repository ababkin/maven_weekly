{-# LANGUAGE OverloadedStrings #-}
import Database.Persist(Entity(..))
import Data.Text(Text)
import SendGrid(SendGridEmail, sendEmail) 
import Queries.Group(allLinksForGroups, usersForGroupId)
import Schema

import Snap.Snaplet.Auth(AuthUser)
import Snap.Snaplet.Auth.Backends.Persistent(SnapAuthUser)
import Snap.Snaplet.Persistent(runPersist)

data NewsLetter = NewsLetter {
  newsLetterRecipients :: [Entity SnapAuthUser]
  , newsLetterContent :: [Text]
}

main :: IO ()
main = do 
  links <- runPersist $ allLinksForGroups
  usersByGroup <- mapM usersForGroupId links
  let newsletters = zipWith NewsLetter usersByGroup links
  mapM_ (sendEmail "123") . generateEmailFor newsletters

generateEmailFor :: NewsLetter -> SendGridEmail
generateEmailFor = undefined
