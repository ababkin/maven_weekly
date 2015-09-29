module DB.Settings(postgresConnString, postgresPoolSize) where
import           Data.Monoid(mconcat)
import           System.Environment(getEnv)

postgresConnString :: IO String
postgresConnString = do 
  host <- getEnv "DATABASE_HOST"
  port <- getEnv "DATABASE_PORT"
  user <- getEnv "DATABASE_USER"
  password <- getEnv "DATABASE_PASSWORD"
  name <- getEnv "DATABASE_NAME"
  return $ mconcat ["host=", host, " port=", port, " dbname=", name , " user=", user, " password=", password]

postgresPoolSize :: String
postgresPoolSize = "postgre-pool-size=10"
