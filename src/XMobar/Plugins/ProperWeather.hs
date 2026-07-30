{-|
Module: XMobar.Plugins.ProperWeather
Description: Get weather from Open-Meteo based on lat-lon coordinates.

Exposes an executable driven config; xmobar consumes its output via @Run Com@.
-}
module XMobar.Plugins.ProperWeather
  ( module WM
  , module Coords
  , PWeather(..)
  , pWeather
  , meteoConf
  ) where

import           XMobar.Plugins.ProperWeather.Coords
                                               as Coords
import           XMobar.Plugins.ProperWeather.OpenMeteo
                                               as WM

-- | Coordinates based weather configuration.
data PWeather = PwLatLon
  { _pwLat :: Lat
  , _pwLon :: Lon
  }
  deriving (Eq, Show, Read)

-- | Run a `PWeather` configuration to get the weather data.
pWeather :: MonadIO m => PWeather -> m (Either PwErr WM.Forecast)
pWeather pw = liftIO runMeteo
 where
  runMeteo = runExceptT . (`runReaderT` conf) . runMeteoT $ forecast
  conf     = meteoConf pw

-- | Generate a configuration value from `PWeather`.
meteoConf :: PWeather -> MeteoConf
meteoConf PwLatLon {..} = MeteoConf { _mcLat = _pwLat, _mcLon = _pwLon }
