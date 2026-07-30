module XMobar.Plugins.ProperWeather.OpenMeteo.Weather
  ( Forecast(..)
  , Current(..)
  , Celsius(..)
  , WmoCode(..)
  , DayNight(..)
  , Condition(..)
  , Intensity(..)
  , wmoCondition
  , conditionSymbol
  , conditionDesc
  , displayForecast
  ) where

import           Data.Aeson
import qualified Data.Text                     as T

-- | A temperature in degrees Celsius. Open-Meteo returns metric units by default.
newtype Celsius = Celsius Double
                deriving (Eq, Show, Num, Fractional, FromJSON) via Double

-- | A <https://open-meteo.com/en/docs WMO weather interpretation code>.
newtype WmoCode = WmoCode Int
                deriving (Eq, Show, FromJSON) via Int

-- | Whether the observation is during the day or the night, decoded from
-- Open-Meteo's @is_day@ flag (@1@ = day, @0@ = night).
data DayNight = Day | Night
  deriving (Eq, Show)

instance FromJSON DayNight where
  parseJSON = fmap toDayNight . parseJSON @Int
   where
    toDayNight 1 = Day
    toDayNight _ = Night

-- | Precipitation intensity, used to qualify a `Condition`.
data Intensity = Slight | Moderate | Heavy
  deriving (Eq, Show)

-- | The weather condition, derived from a `WmoCode`.
data Condition
  = ClearSky
  | MainlyClear
  | PartlyCloudy
  | Overcast
  | Fog
  | Drizzle Intensity
  | FreezingDrizzle
  | Rain Intensity
  | FreezingRain
  | SnowFall Intensity
  | SnowGrains
  | RainShowers Intensity
  | SnowShowers Intensity
  | Thunderstorm
  | ThunderstormWithHail
  | UnknownCondition WmoCode
  deriving (Eq, Show)

-- | Interpret a `WmoCode` as a `Condition`. Unrecognised codes map to
-- `UnknownCondition`, preserving the original code.
wmoCondition :: WmoCode -> Condition
wmoCondition = \case
  WmoCode 0     -> ClearSky
  WmoCode 1     -> MainlyClear
  WmoCode 2     -> PartlyCloudy
  WmoCode 3     -> Overcast
  WmoCode 45    -> Fog
  WmoCode 48    -> Fog
  WmoCode 51    -> Drizzle Slight
  WmoCode 53    -> Drizzle Moderate
  WmoCode 55    -> Drizzle Heavy
  WmoCode 56    -> FreezingDrizzle
  WmoCode 57    -> FreezingDrizzle
  WmoCode 61    -> Rain Slight
  WmoCode 63    -> Rain Moderate
  WmoCode 65    -> Rain Heavy
  WmoCode 66    -> FreezingRain
  WmoCode 67    -> FreezingRain
  WmoCode 71    -> SnowFall Slight
  WmoCode 73    -> SnowFall Moderate
  WmoCode 75    -> SnowFall Heavy
  WmoCode 77    -> SnowGrains
  WmoCode 80    -> RainShowers Slight
  WmoCode 81    -> RainShowers Moderate
  WmoCode 82    -> RainShowers Heavy
  WmoCode 85    -> SnowShowers Slight
  WmoCode 86    -> SnowShowers Heavy
  WmoCode 95    -> Thunderstorm
  WmoCode 96    -> ThunderstormWithHail
  WmoCode 99    -> ThunderstormWithHail
  other         -> UnknownCondition other

-- | The Unicode symbol for a `Condition`. The clear/partly-cloudy symbols
-- depend on whether it is `Day` or `Night`.
conditionSymbol :: DayNight -> Condition -> Text
conditionSymbol dn = \case
  ClearSky             -> dayNight "☼" "☽"
  MainlyClear          -> dayNight "☼" "☽"
  PartlyCloudy         -> dayNight "☼☁" "☁"
  Overcast             -> "☁"
  Fog                  -> "▒"
  Drizzle _            -> "☂"
  FreezingDrizzle      -> "☂"
  Rain _               -> "☂"
  FreezingRain         -> "☂"
  SnowFall _           -> "✻"
  SnowGrains           -> "✻"
  RainShowers _        -> "☂"
  SnowShowers _        -> "✻"
  Thunderstorm         -> "ϟ"
  ThunderstormWithHail -> "ϟ"
  UnknownCondition _   -> "?"
 where
  dayNight d n = case dn of
    Day   -> d
    Night -> n

-- | A human-readable description of a `Condition`.
conditionDesc :: Condition -> Text
conditionDesc = \case
  ClearSky                     -> "Clear sky"
  MainlyClear                  -> "Mainly clear"
  PartlyCloudy                 -> "Partly cloudy"
  Overcast                     -> "Overcast"
  Fog                          -> "Fog"
  Drizzle i                    -> intensityDesc i <> " drizzle"
  FreezingDrizzle              -> "Freezing drizzle"
  Rain i                       -> intensityDesc i <> " rain"
  FreezingRain                 -> "Freezing rain"
  SnowFall i                   -> intensityDesc i <> " snow fall"
  SnowGrains                   -> "Snow grains"
  RainShowers i                -> intensityDesc i <> " rain showers"
  SnowShowers i                -> intensityDesc i <> " snow showers"
  Thunderstorm                 -> "Thunderstorm"
  ThunderstormWithHail         -> "Thunderstorm with hail"
  UnknownCondition (WmoCode c) -> "Unknown (WMO " <> show c <> ")"
 where
  intensityDesc = \case
    Slight   -> "Slight"
    Moderate -> "Moderate"
    Heavy    -> "Heavy"

-- | Minimal type for current weather data.
data Current = Current
  { _cTemp         :: Celsius
  , _cApparentTemp :: Celsius
  , _cWeatherCode  :: WmoCode
  , _cDayNight     :: DayNight
  }
  deriving (Eq, Show)

instance FromJSON Current where
  parseJSON = withObject "OpenMeteo/Weather/Current" $ \o -> do
    _cTemp         <- o .: "temperature_2m"
    _cApparentTemp <- o .: "apparent_temperature"
    _cWeatherCode  <- o .: "weather_code"
    _cDayNight     <- o .: "is_day"
    pure Current { .. }

-- | Simplistic wrapper over the forecast response; we only deal with the
-- @current@ field.
newtype Forecast = Forecast Current
                 deriving (Eq, Show)

instance FromJSON Forecast where
  parseJSON =
    withObject "OpenMeteo/Weather/Forecast" $ \o -> Forecast <$> o .: "current"

displayCurrent :: Current -> Text
displayCurrent Current {..} = T.intercalate
  ", "
  [showTemp _cTemp, "FL: " <> showTemp _cApparentTemp, desc]
 where
  showTemp (Celsius t) = show (round @Double @Integer t) <> "℃"
  condition            = wmoCondition _cWeatherCode
  desc = conditionSymbol _cDayNight condition <> " " <> conditionDesc condition

-- | Display the weather properly.
displayForecast :: Forecast -> Text
displayForecast (Forecast c) = displayCurrent c
