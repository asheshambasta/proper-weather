module XMobar.Plugins.ProperWeather.OpenWeatherMap.Weather
  ( Current(..)
  , OneCall(..)
  , displayOneCall
  , displayDesc
  ) where

import           Data.Aeson
import qualified Data.Text                     as T

data WeatherDescription = WeatherDescription
  { _wdIcon :: Maybe Text
  , _wdDesc :: Maybe Text
  , _wdMain :: Maybe Text
  , _wdId   :: Maybe Integer
  }
  deriving (Eq, Show)

instance FromJSON WeatherDescription where
  parseJSON = withObject "Owm/Weather/WeatherDescription" $ \o -> do
    _wdIcon <- o .:? "icon"
    _wdDesc <- o .:? "description"
    _wdMain <- o .:? "main"
    _wdId   <- o .:? "id"
    pure WeatherDescription { .. }

-- | Minimal type for current weather data 
data Current = Current
  { _cTemp         :: Double
  , _cFeelsLike    :: Double
  , _cWeatherDescs :: [WeatherDescription]
  }
  deriving (Eq, Show)

instance FromJSON Current where
  parseJSON = withObject "Owm/Weather/Current"
    $ \o -> Current <$> o .: "temp" <*> o .: "feels_like" <*> o .: "weather"

-- | Simplistic wrapper over one-call's response, currently we only deal with the @current@ field. 
newtype OneCall = OneCall Current
                deriving (Eq, Show)

instance FromJSON OneCall where
  parseJSON =
    withObject "Owm/Weather/OneCall" $ \o -> OneCall <$> o .: "current"

displayOneCall :: OneCall -> Text
displayOneCall (OneCall Current {..}) = T.intercalate
  " | "
  [showTemp _cTemp, showTemp _cFeelsLike, descs]
 where
  showTemp = (<> "C") . show
  descs    = T.intercalate "|" $ displayDesc <$> _cWeatherDescs

displayDesc :: WeatherDescription -> Text
displayDesc WeatherDescription {..} =
  fromMaybe "" _wdMain <> "/" <> fromMaybe "" _wdDesc
