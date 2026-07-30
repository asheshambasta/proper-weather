module XMobar.Plugins.ProperWeather.Coords
  ( Lat(..)
  , Lon(..)
  , Coordinate(..)
  ) where

newtype Lat = Lat Double deriving (Eq, Show, Read, Num, Fractional) via Double
newtype Lon = Lon Double deriving (Eq, Show, Read, Num, Fractional) via Double

class Coordinate c where
  showC :: c -> Text

instance Coordinate Lat where
  showC (Lat c) = show c

instance Coordinate Lon where
  showC (Lon c) = show c
