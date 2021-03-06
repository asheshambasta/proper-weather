module XMobar.Plugins.ProperWeather.OpenWeatherMap.Weather
  ( Current(..)
  , OneCall(..)
  ) where

import           Data.Aeson

-- | Minimal type for current weather data 
data Current = Current
  { _cTemp      :: Double
  , _cFeelsLike :: Double
  }
  deriving (Eq, Show)

instance FromJSON Current where
  parseJSON = withObject "Owm/Weather/Current"
    $ \o -> Current <$> o .: "temp" <*> o .: "feels_like"

-- | Simplistic wrapper over one-call's response, currently we only deal with the @current@ field. 
newtype OneCall = OneCall Current
                deriving (Eq, Show)

instance FromJSON OneCall where
  parseJSON =
    withObject "Owm/Weather/OneCall" $ \o -> OneCall <$> o .: "current"
