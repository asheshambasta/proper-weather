{-# LANGUAGE
    GeneralizedNewtypeDeriving
  , DeriveFunctor
#-}
module XMobar.Plugins.ProperWeather.OpenMeteo
  ( MeteoConf(..)
  , MeteoT(..)
  -- * Api calls
  , forecast
  -- * Re-exports
  , module Err
  , module W
  ) where

import           Network.HTTP.Simple           as HS
import           XMobar.Plugins.ProperWeather.Coords
import           XMobar.Plugins.ProperWeather.Error
                                               as Err
import           XMobar.Plugins.ProperWeather.OpenMeteo.Weather
                                               as W

-- | Configuration for <https://open-meteo.com Open-Meteo>. No API key is
-- required.
data MeteoConf = MeteoConf
  { _mcLat :: Lat
  , _mcLon :: Lon
  }

newtype MeteoT a = MeteoT { runMeteoT :: ReaderT MeteoConf (ExceptT Err.PwErr IO) a }
                 deriving (Functor, Applicative, Monad, MonadIO, MonadReader MeteoConf, MonadError Err.PwErr)

-- | Fetch the current weather from the <https://open-meteo.com/en/docs forecast API>.
forecast
  :: (MonadIO m, MonadReader MeteoConf m, MonadError Err.PwErr m) => m W.Forecast
forecast = do
  conf <- ask
  HS.httpJSONEither (forecastReq conf)
    >>= either (throwError . PwException) pure
    .   HS.getResponseBody

-- | Generate the forecast request for the given coordinates.
forecastReq :: MeteoConf -> HS.Request
forecastReq MeteoConf { _mcLat, _mcLon} =
  HS.setRequestHost "api.open-meteo.com"
    . HS.setRequestSecure True
    . HS.setRequestPort 443
    . HS.setRequestPath "/v1/forecast"
    . HS.setRequestQueryString params
    $ HS.defaultRequest
 where
  params =
    [ ("latitude" , Just . encodeUtf8 $ showC _mcLat)
    , ("longitude", Just . encodeUtf8 $ showC _mcLon)
    , ("current"  , Just "temperature_2m,apparent_temperature,weather_code,is_day")
    ]
