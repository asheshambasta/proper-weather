
# Table of Contents

1.  [ProperWeather](#orge104788)
    1.  [Current limitations](#orgf72d762)


<a id="orge104788"></a>

# ProperWeather

[Example screenshot (xmobar)](https://i.imgur.com/uo88i8f.png)  

ProperWeather lets you obtain basic weather information using [OpenWeatherMap](https://openweathermap.org).

Proper weather provides 2 ways of interacting with it:

1.  As an Xmobar plugin: <https://xmobar.org/#user-plugins>
2.  As an executable.

Currently, just getting weather using the lat-lon values are supported. 

As an executable, one can either pass all the arguments to it or use `-C` to refer to a configuration file. The configuration file is just a text blob form with a value `PWeather` can be read. 
Example: 

    PwLatLon { _pwAlias  = "<SomeAlias>"
              , _pwApiKey = "<YourApiKey>"
              , _pwLat    = 12.12
              , _pwLon    = 12.12
              , _pwRate   = 10
              }

At the time of writing, the Alias and rate values are not used in executable mode. 

One can also use the executable use `Com` from `xmobar` to execute arbitrary commands: 

    Run Com "proper-weather" ["-C", "/path/to/conf"] "SomeAlias" 3000 -- will refresh every 5 mins.


<a id="orgf72d762"></a>

## Current limitations

The plugin is quite basic at this point and I wrote this in anger. 

-   Only supports lat-lon values for weather data
-   The outputted weather data is pretty basic
    
        proper-weather -C ~/.proper-weatherrc                                130 ↵
        5.0℃, FL: 0.56℃, Clouds/overcast clouds
-   Cleanup required to overcome the need of alias and rate values for executable
    -   These values are not needed from the user, but dummy values are provided anyway.

