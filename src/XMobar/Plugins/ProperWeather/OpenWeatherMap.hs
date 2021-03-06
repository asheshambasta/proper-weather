module XMobar.Plugins.ProperWeather.OpenWeatherMap
  ( ApiKey(..)
  ) where

import qualified GHC.Show                       ( Show(..) )

newtype ApiKey = ApiKey { _unApiKey :: Text }
               deriving Eq

instance Show ApiKey where
  show _ = "ApiKey"



