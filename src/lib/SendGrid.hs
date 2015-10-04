{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE NamedFieldPuns #-}

module SendGrid(SendGridEmail(..), SendGridApiKey, sendEmail) where
  import Data.ByteString(ByteString, append)
  import Data.Text(Text)
  import Control.Lens(view, (&), (.~))
  import Network.Wreq(responseBody, postWith, FormParam(..), header, defaults, Options )

  data SendGridEmail = SendGridEmail {
       emailTo      :: [Text]
     , emailFrom    :: Text
     , emailSubject :: Text
     , emailText    :: Text
    } deriving Show

  type SendGridApiKey = ByteString

  toFormParams :: SendGridEmail -> [FormParam]
  toFormParams SendGridEmail{emailTo, emailFrom, emailSubject, emailText} = 
    toParams ++ [fromParam, subjectParam, textParam] 
      where
        toParams      = map ("to[]" :=) emailTo
        fromParam     = "from"    := emailFrom
        subjectParam  = "subject" := emailSubject
        textParam     = "text"    := emailText

  sendEmail :: SendGridApiKey -> SendGridEmail -> IO ()
  sendEmail apiKey email = do 
    let params = defaults & header "Authorization" .~ ["Bearer " `append` apiKey]
    res <- postWith params "http://api.sendgrid.com/api/mail.send.json" (toFormParams email)
    print $ view responseBody res
