{-|
Module: XMobar.Plugins.ProperWeather
Description: Get weather from OpenWeatherMap.org based on lat-lon coordinates. 
-}
module XMobar.Plugins.ProperWeather
  ( module WM
  , module Coords
  , PWeather(..)
  , pWeather
  , owmConf
  ) where

import qualified Data.Text                     as T
import           XMobar.Plugins.ProperWeather.Coords
                                               as Coords
import           XMobar.Plugins.ProperWeather.OpenWeatherMap
                                               as WM
import           Xmobar                        as XM
                                         hiding ( Rate )

newtype Rate = Rate Int deriving (Eq, Show, Num, Ord, Real, Enum, Integral) via Int

-- | Coordinates based weather.  
data PWeather = PwLatLon
  { _pwAlias  :: Text
  , _pwApiKey :: WM.ApiKey
  , _pwLat    :: Lat
  , _pwLon    :: Lon
  , _pwRate   :: Rate
  }
  deriving (Eq, Show)

-- | Run a `PWeather` configuration to get the weather data. 
pWeather :: MonadIO m => PWeather -> m (Either PwErr WM.Weather)
pWeather pw = liftIO runOwm
 where
  runOwm = runExceptT . (`runReaderT` conf) . runOwmT $ oneCall
  conf   = owmConf pw

instance XM.Exec PWeather where

  run   = pWeather >=> pure . either show (T.unpack . displayWeather)

  alias = T.unpack . _pwAlias

  rate PwLatLon { _pwRate = Rate r } = r

-- | Generate a configuration value from `PWeather` 
owmConf :: PWeather -> OwmConf
owmConf PwLatLon {..} =
  OwmConf { _owmApiKey = _pwApiKey, _owmLat = _pwLat, _owmLon = _pwLon }

