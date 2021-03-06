module XMobar.Plugins.ProperWeather.Coords
  ( Lat(..)
  , Lon(..)
  ) where

newtype Lat = Lat Double deriving (Eq, Show, Num) via Double
newtype Lon = Lon Double deriving (Eq, Show, Num) via Double
