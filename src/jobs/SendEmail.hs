import Database.Persist(Entity(..))
import SendGrid(SendGridEmail, sendEmail) 
import Schema

import Snap.Snaplet.Auth(AuthUser)
import Snap.Snaplet.Auth.Backends.Persistent(SnapAuthUser)

main :: IO ()
main = do 
  groups <- allGroups
  mapM_ sendGroupEmail groups

allGroups :: IO [Entity Group]
allGroups = undefined

oneWeek = 7

linksForGroup :: Int -> Entity Group -> IO [Entity Link]
linksForGroup = undefined

generateEmailFor :: [Entity Link] -> [Entity SnapAuthUser] -> SendGridEmail
generateEmailFor = undefined

usersForGroup :: Entity Group -> IO [Entity SnapAuthUser]
usersForGroup = undefined

sendGroupEmail :: Entity Group -> IO ()
sendGroupEmail group = do 
  recentlyAddedLinks <- linksForGroup oneWeek group 
  usersInGroup <- usersForGroup group
  sendEmail $ generateEmailFor recentlyAddedLinks usersInGroup 
