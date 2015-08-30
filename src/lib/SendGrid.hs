{-# LANGUAGE OverloadedStrings #-}
module SendGrid(SendGridEmail(..), SendGridApiKey, sendEmail) where
  import Data.ByteString(ByteString, append)
  import Data.Text(Text)
  import Control.Lens(view, (&), (.~))
  import Network.Wreq(responseBody, postWith, FormParam(..), header, defaults, Options )

  data SendGridEmail = SendGridEmail {
       emailTo :: [Text]
     , emailFrom :: Text
     , emailSubject :: Text
     , emailText :: Text
    } deriving Show

  type SendGridApiKey = ByteString

  toFormParams :: SendGridEmail -> [FormParam]
  toFormParams email = toParams ++ [fromParam, subjectParam, textParam] 
                      where
                        toParams = map ("to[]" :=) (emailTo email)
                        fromParam = "from" := (emailFrom email)
                        subjectParam = "subject" := (emailSubject email)
                        textParam = "text" := (emailText email)

  sendEmail :: SendGridApiKey -> SendGridEmail -> IO ()
  sendEmail apiKey email = do 
    let params = defaults & header "Authorization" .~ ["Bearer " `append` apiKey]
    res <- postWith params "http://api.sendgrid.com/api/mail.send.json" (toFormParams email)
    print $ view responseBody res
