
# Table of Contents

1.  [ProperWeather](#orge104788)
    1.  [Current limitations](#orgf72d762)


<a id="orge104788"></a>

# ProperWeather

[Example screenshot (xmobar)](https://i.imgur.com/uo88i8f.png)  

ProperWeather lets you obtain basic weather information using [Open-Meteo](https://open-meteo.com). No API key is required.

Proper weather is used as an executable, whose output xmobar consumes via `Com`.

Currently, just getting weather using the lat-lon values are supported. 

As an executable, one can either pass all the arguments to it or use `-C` to refer to a configuration file. The configuration file is just a text blob form with a value `PWeather` can be read. 
Example: 

    PwLatLon { _pwLat = 12.12
             , _pwLon = 12.12
             }

One can also use the executable use `Com` from `xmobar` to execute arbitrary commands: 

    Run Com "proper-weather" ["-C", "/path/to/conf"] "SomeAlias" 3000 -- will refresh every 5 mins.


<a id="orgf72d762"></a>

## Current limitations

The plugin is quite basic at this point and I wrote this in anger. 

-   Only supports lat-lon values for weather data
-   The outputted weather data is pretty basic
    
        proper-weather -C ~/.proper-weatherrc                                130 ↵
        24℃, FL: 25℃, ☁ Overcast
