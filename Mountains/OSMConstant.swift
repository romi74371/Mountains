//
//  OSMConstant.swift
//  Mountains
//
//  Created by Roman Hauptvogel on 24/01/16.
//  Copyright © 2016 Roman Hauptvogel. All rights reserved.
//

import Foundation

extension OSMClient {
    
    // MARK: - Constants
    struct Constants {
        
        //static let ApiKey : String = "38e2abb2f73bb7ac6847676afe597207"
        
        static let BaseURL : String = "http://overpass-api.de/api/interpreter"
        
        static let BOUNDING_BOX_HALF_WIDTH = 0.1
        static let BOUNDING_BOX_HALF_HEIGHT = 0.1
        static let LAT_MIN = -90.0
        static let LAT_MAX = 90.0
        static let LON_MIN = -180.0
        static let LON_MAX = 180.0
        
        static let LOCATION_HALF_WIDTH = 0.1
        static let LOCATION_HALF_HEIGHT = 0.1
        
        static let LOCATION_OFFSET = 100.0
        
        //static let EXTRAS = "url_m"
        //static let SAFE_SEARCH = "1"
        //static let DATA_FORMAT = "json"
        //static let NO_JSON_CALLBACK = "1"
        //static let PER_PAGE = "21"
    }
    
    // MARK: - Methods
    struct Methods {
        
        //static let search = "flickr.photos.search"
    }
    
    // MARK: - URL Keys
    struct URLKeys {
        
        //static let UserID = "id"
        
    }
    
    // MARK: - Parameter Keys
    struct ParameterKeys {
        //static let ApiKey = "api_key"
        //static let Format = "format"
        //static let Extras = "extras"
        //static let Latitude = "lat"
        //static let Longitude = "lon"
        //static let Method = "method"
        //static let NoJSONCallback = "nojsoncallback"
        //static let Page = "page"
        //static let PerPage = "per_page"
    }
    
    // MARK: - JSON Body Keys
    struct JSONBodyKeys {
        //static let Udacity = "udacity"
        //static let Username = "username"
        //static let Password = "password"
    }
    
    // MARK: - JSON Response Keys
    struct JSONResponseKeys {
        //static let Account = "account"
        //static let Registered = "registered"
        //static let Key = "key"
        //static let User = "user"
        //static let FirstName = "first_name"
        //static let LastName = "last_name"
        //static let Status = "status"
        //static let Error = "error"
    }
}