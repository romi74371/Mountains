## Mountains

Application "Mountains" is used to visualize the mountains (peaks) in current location.
There are following types of views to show peaks in current location
- on the map
- in the list
- in the augmented reality

## How does it work

At the beginning application will find out the current location of the user.
The current location is used to load peaks from the open street map (OSM). Number of the peaks are limited only to the surrounding of the current location.
Loaded peaks are shown on the map. User has possibility to display the peaks in the augmented reality by pressing ARView button located in the top right corner.

## Features
- Peaks - Peaks are loaded from the Open Street Map (OSM) server. Data are exchanged in JSON format. The area which is used for downloading peaks is current lattitude +/- 0.05 and longitude +/- 0.1 (This numbers are hard coded in application as constants). To test it out following page can be used: http://overpass-turbo.eu with following query: node(49.15,18.67,49.26,18.85)[natural=peak];out;  
- Persistence - Loaded peaks are persisted in the device. When application will start up at first are peaks loaded from the device. If current location is different from persisted one than the peaks are loaded from the OSM server. For persistence is used CoreData framework.
- Location service - For location service is used CoreLocation framework
- Change of current location - If the device is moved 100m from current location, then the peaks are reloaded from server
- Map or List view - loaded peaks are displayed either on map view or list view. Particullar view can be choosen on tab bar on the botton of the screen.
- Slider functionality - there is slider located on the map view. Slider add offset to the search area. Offset can be setup from -0.09 to 0.09 value. 
- Augmented Reality - For augmented reality is used external library provided by Danijel Huis and can be located here https://github.com/DanijelHuis/HDAugmentedReality.git

## Requirements
- it is required (due to augmented reality) to run application on a device with backside camera
- it is required to grand access to the phone's location
