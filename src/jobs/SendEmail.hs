import Database.Persist(Entity(..))
import Network.Sendgrid.Api(EmailMessage) 
import Schema

import Snap.Snaplet.Auth(AuthUser)
import Snap.Snaplet.Auth.Backends.Persistent(SnapAuthUser)

main :: IO ()
main = do 
  groups <- allGroups
  mapM_ sendEmail groups



allGroups :: IO [Entity Group]
allGroups = undefined

oneWeek = 7

linksForGroup :: Int -> Entity Group -> IO [Entity Link]
linksForGroup = undefined

generateEmailFor :: [Entity Link] -> Entity SnapAuthUser -> EmailMessage
generateEmailFor = undefined

postToSendgrid :: EmailMessage -> IO ()
postToSendgrid = undefined

usersForGroup :: Entity Group -> IO [Entity SnapAuthUser]
usersForGroup = undefined

sendEmail :: Entity Group -> IO ()
sendEmail group = do 
  recentlyAddedLinks <- linksForGroup oneWeek group 
  usersInGroup <- usersForGroup group
  mapM_ (postToSendgrid . generateEmailFor recentlyAddedLinks) usersInGroup 
