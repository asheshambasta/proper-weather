{-# LANGUAGE
    GeneralizedNewtypeDeriving
  , DeriveFunctor 
#-}
module XMobar.Plugins.ProperWeather.OpenWeatherMap
  ( ApiKey(..)
  , OwmConf(..)
  , OwmT(..)
  -- * Api calls 
  , oneCall
  -- * Re-exports
  , module Err
  , module W
  ) where

import qualified Data.Text.Encoding            as TE
import qualified GHC.Show                       ( Show(..) )
import           Network.HTTP.Simple           as HS
import           XMobar.Plugins.ProperWeather.Coords
import           XMobar.Plugins.ProperWeather.Error
                                               as Err
import           XMobar.Plugins.ProperWeather.OpenWeatherMap.Weather
                                               as W

-- | Configuration for OpenWeatherMap.org (Owm)
data OwmConf = OwmConf
  { _owmApiKey :: ApiKey     -- ^ API key 
  , _owmLat    :: Lat
  , _owmLon    :: Lon
  }

newtype OwmT a = OwmT { runOwmT :: ReaderT OwmConf (ExceptT Err.PwErr IO) a }
                deriving (Functor, Applicative, Monad, MonadIO, MonadReader OwmConf, MonadError Err.PwErr)

-- | The API Key for making calls to Owm
newtype ApiKey = ApiKey { _unApiKey :: Text }
               deriving (Eq, IsString) via Text

-- | The ApiKey is never "shown"
instance Show ApiKey where
  show _ = "ApiKey"

-- | Make an API call to the <https://openweathermap.org/api/one-call-api one-call-api> 
oneCall
  :: (MonadIO m, MonadReader OwmConf m, MonadError Err.PwErr m) => m W.OneCall
oneCall = do
  conf@OwmConf {..} <- ask
  HS.httpJSONEither (oneCallReq conf)
    >>= either (throwError . PwException) pure
    .   HS.getResponseBody

-- | Generate the one-call request
oneCallReq :: OwmConf -> HS.Request
oneCallReq conf@OwmConf { _owmLat = Lat lat, _owmLon = Lon lon } =
  HS.addToRequestQueryString params
    . HS.setRequestPath "/data/2.5/onecall"
    $ owmReq conf
  where params = [("lat", Just $ show lat), ("lon", Just $ show lon)]

-- | Generate the request with the basics to the Owm api 
owmReq :: OwmConf -> HS.Request
owmReq OwmConf { _owmApiKey = ApiKey k } =
  HS.setRequestHost "api.openweathermap.org"
    . HS.setRequestSecure True
    . HS.setRequestQueryString params
    $ HS.defaultRequest
  where params = [("appid", Just $ TE.encodeUtf8 k), ("units", Just "metric")]

