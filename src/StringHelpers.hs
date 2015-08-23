module StringHelpers(byteStringToText, byteStringToString) where
  import           Data.ByteString (ByteString)
  import           Data.Text
  import qualified Data.ByteString.Char8 as BCH

  byteStringToText :: ByteString -> Text
  byteStringToText = pack . BCH.unpack

  byteStringToString :: ByteString -> String
  byteStringToString = BCH.unpack

