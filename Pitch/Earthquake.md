Earthquake
========================================================
author: Andrew Braddick
date: 14 June 2016 
autosize: true

A Shiny app to get you started exploring the data about the earthquakes that have struck the Canterbury region of New Zealand since 2010

<br>
Part of the Data Science Specialisation from Coursera

History of Canterbury Earthquakes
========================================================
left: 70%
- The Canterbury region is on the east coast of New Zealand's South Island
- Historically the region was not earthquake prone, but experienced a major earthquake in September 2010
- This has had a major social and economic impact on the people of Canterbury and the rest of New Zealand 
- What can we learn by examining earthquake data?

***
<font size=4>

```r
library(ggplot2)
library(ggmap)
map <- get_map(location=c(lon = 172.5, lat = -43.5), zoom = 9)
ggmap(map, extent = 'normal') + 
  geom_point(aes(x = 172.5, y = -43.5))
```

![plot of chunk unnamed-chunk-1](Earthquake-figure/unnamed-chunk-1-1.png)
</font> 

Canterbury Earthquake Analysis
========================================================
- Earthquakes in New Zealand are recorded by [GNS Science](http://www.geonet.org.nz/) who make this data publically available
- My Earthquake app uses R and Shiny to do some elementary analysis on the GNS Science data looking at:
  - What are the trends in seismic activity in Canterbury ?  
  - Can you calculate the amount of energy released by these earthquakes?  
  - Can you find the previously hidden fault line?
  - Can you predict future earthquakes?  
- The app has some interactive controls to let you explore on your own  
- And perhaps it will prompt ideas future analysis
Sourcing the Data
========================================================

- Sample R code to get the data
<font size=4>


```r
URL_base_1 <- "http://wfs.geonet.org.nz/geonet/ows?service=WFS&version=1.0.0"
URL_base_2 <- "&request=GetFeature&typeName=geonet:quake_search_v1"
URL_fmt <- "&maxFeatures=5&outputFormat=csv"
URL_mag <- "&cql_filter=magnitude>3.0"
eq_url <- paste0(URL_base_1, URL_base_2, URL_fmt, URL_mag)
eq_nz <- read.csv(eq_url)
str(eq_nz)
```
</font>

- The URL uses [query terms](http://info.geonet.org.nz/display/appdata/Advanced+Queries) to refine the range of data requested
- Data structure (on right) is defined in a [data catalogue](http://info.geonet.org.nz/display/appdata/Catalogue+Output) is provided by GNS 

***
<font size=4>

```
'data.frame':	5 obs. of  23 variables:
 $ FID                  : Factor w/ 5 levels "quake_search_v1.2016p451328",..: 5 4 3 2 1
 $ publicid             : Factor w/ 5 levels "2016p451328",..: 5 4 3 2 1
 $ eventtype            : Factor w/ 2 levels "","earthquake": 2 1 1 2 1
 $ origintime           : Factor w/ 5 levels "2016-06-15T23:47:42.803",..: 5 4 3 2 1
 $ modificationtime     : Factor w/ 5 levels "2016-06-15T23:50:51.369",..: 5 3 2 4 1
 $ latitude             : num  -40.2 -35.3 -37.8 -44.3 -39.6
 $ longitude            : num  175 179 178 168 174
 $ depth                : num  18.1 133.3 73.4 5 172.8
 $ magnitude            : num  3.41 3.33 3.14 3.25 3.17
 $ evaluationmethod     : Factor w/ 2 levels "LOCSAT","NonLinLoc": 1 2 2 1 2
 $ evaluationstatus     : Factor w/ 2 levels "","confirmed": 2 1 1 2 1
 $ evaluationmode       : Factor w/ 2 levels "automatic","manual": 2 1 1 2 1
 $ earthmodel           : Factor w/ 3 levels "iasp91","iaspei91",..: 1 2 3 1 3
 $ depthtype            : Factor w/ 2 levels "","operator assigned": 1 1 1 2 1
 $ originerror          : num  0.637 0.403 2.11 0.745 1.586
 $ usedphasecount       : int  32 16 77 16 106
 $ usedstationcount     : int  25 16 77 9 106
 $ minimumdistance      : num  0.14 2.421 0.183 0.375 0.158
 $ azimuthalgap         : num  128.4 313.5 158.2 217.1 64.7
 $ magnitudetype        : Factor w/ 1 level "M": 1 1 1 1 1
 $ magnitudeuncertainty : logi  NA NA NA NA NA
 $ magnitudestationcount: int  19 9 49 7 63
 $ origin_geom          : Factor w/ 5 levels "POINT (167.9105988 -44.29812622)",..: 3 5 4 1 2
```
</font>
Have a Play with the Earthquake App
========================================================
- If you'd like to have a play with the Earthquake app, go to:  

  https://nanchangcj6.shinyapps.io/Earthquake/

- To read the documentation, select the 'about' tab in the app

- Don't forget to play with the interactive controls

- Thank you for your interest
<br><br><br>
<font size=4>
With acknowledgment the GeoNet project and its sponsors EQC, GNS Science and LINZ, for making the data available
</font> 
