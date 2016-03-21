## Mountains

Application "Mountains" is used to visualize the mountains (peaks) in current location.
There are two types of views to show current location
- on the map
- in the augmented reality

## How does it work

At the beginning application will find out the current location of the user.
The current location is used to load peaks from the open street map (OSM). Number of the peaks are limited only to the surrounding of the current location.
Loaded peaks are shown on the map. User has possibility to display the peaks in the augmented reality by pressing ARView button located in the top right corner.

## Features
- Peaks - Peaks are loaded from the Open Street Map (OSM) server. Data are exchanged in JSON format.
- Persistence - Loaded peaks are persisted in the device. When application will start up at first are peaks loaded from the device. If current location is different from persisted one than the peaks are loaded from the OSM server. For persistence is used CoreData framework.
- Location service - For location service is used CoreLocation framework
- Augmented Reality - For augmented reality is used external library provided by Danijel Huis and can be located here https://github.com/DanijelHuis/HDAugmentedReality.git

## Requirements
- it is required (due to augmented reality) to run application on a device with backside camera
- it is required to grand access to the phone's location
