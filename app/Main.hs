{-# LANGUAGE ApplicativeDo #-}
module Main
  ( main
  ) where

import qualified Data.Text                     as T
import qualified "optparse-applicative" Options.Applicative
                                               as A
import           Prelude
import qualified XMobar.Plugins.ProperWeather  as Pw

main :: IO ()
main = A.execParser runPwP >>= \case
  ConfFile fp ->
    readFile fp >>= either (failure . T.pack) runPw . readEither . T.unpack
  ConfPw pw -> runPw pw
 where
  runPw = Pw.pWeather >=> either failure disp
  failure err = putStrLn @Text (show err) >> exitFailure
  disp pw = putStrLn (Pw.displayWeather pw) >> exitSuccess

runPwP :: A.ParserInfo Conf
runPwP = A.info
  (confP <**> A.helper)
  (A.fullDesc <> A.progDesc "Get proper weather" <> A.header "ProperWeather")

-- | Configuration 

confP :: A.Parser Conf
confP = (ConfFile <$> confFileP) <|> (ConfPw <$> pwP)

data Conf = ConfFile FilePath | ConfPw Pw.PWeather
          deriving (Eq, Show)

confFileP :: A.Parser FilePath
confFileP = A.strOption
  (A.long "conf-file" <> A.short 'C' <> A.help "Path to configuration file")

pwP :: A.Parser Pw.PWeather
pwP = do
  _pwApiKey <- apiKeyP
  _pwLat    <- latP
  _pwLon    <- lonP
  pure Pw.PwLatLon { _pwAlias = "Executable", _pwRate = Pw.Rate 0, .. }
 where
  -- aliasP  = A.strOption (A.long "alias" <> A.help "Alias, doesn't make sense in executable mode.")
  apiKeyP = Pw.ApiKey <$> A.option
    A.auto
    (A.long "api-key" <> A.short 'K' <> A.help "OpenWeatherMap API key")
  latP = Pw.Lat <$> A.option
    A.auto
    (  A.long "lat"
    <> A.short 'A'
    <> A.help "Latitude"
    <> A.value 50.89301
    <> A.showDefault
    )
  lonP = Pw.Lon <$> A.option
    A.auto
    (  A.long "lon"
    <> A.short 'O'
    <> A.help "Longitude"
    <> A.value 3.42305
    <> A.showDefault
    )

