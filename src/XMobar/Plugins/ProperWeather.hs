{-|
Module: XMobar.Plugins.ProperWeather
Description: Get weather from OpenWeatherMap.org based on lat-lon coordinates. 
-}
module XMobar.Plugins.ProperWeather
  ( module WM
  , Lat(..)
  , Lon(..)
  ) where

import qualified Data.Text                     as T
import           XMobar.Plugins.ProperWeather.OpenWeatherMap
                                               as WM
import           Xmobar                        as XM
                                         hiding ( Rate )

newtype Lat = Lat Double deriving (Eq, Show, Num) via Double
newtype Lon = Lon Double deriving (Eq, Show, Num) via Double
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

instance XM.Exec PWeather where

  run PwLatLon {..} = undefined

  alias = T.unpack . _pwAlias
  rate PwLatLon { _pwRate = Rate r } = r
