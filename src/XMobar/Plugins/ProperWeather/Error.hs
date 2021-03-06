{-# LANGUAGE StandaloneDeriving #-}
module XMobar.Plugins.ProperWeather.Error
  ( PwErr(..)
  ) where

data PwErr where
  PwOpenWeatherMapErr ::Text -> PwErr
  PwException ::Exception e => e -> PwErr

deriving instance Show PwErr
