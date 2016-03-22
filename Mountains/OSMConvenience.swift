//
//  OSMConvenience.swift
//  Mountains
//
//  Created by Roman Hauptvogel on 24/01/16.
//  Copyright © 2016 Roman Hauptvogel. All rights reserved.
//

import Foundation
import CoreData
import CoreLocation

extension OSMClient {
    
    // Mark: - Core Data Context
    
    var sharedContext: NSManagedObjectContext{
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    // MARK: - GET Convenience Methods
    
    func getPeaks(location: CLLocation, completionHandler: (success: Bool, peaks: [Peak]?, errorString: String?) -> Void) {
        
        // arguments for OSM client to download peaks in particular area
        let methodArguments = [
            //37,865105 / -119,540518
            //49,235611 / 18,727111
            //"data": "[out:json];node(49.15,18.67,49.26,18.85)[natural=peak];out;"
            "data": "[out:json];node(\(location.coordinate.latitude-OSMClient.Constants.LOCATION_HALF_WIDTH),\(location.coordinate.longitude-OSMClient.Constants.LOCATION_HALF_HEIGHT),\(location.coordinate.latitude+OSMClient.Constants.LOCATION_HALF_WIDTH),\(location.coordinate.longitude+OSMClient.Constants.LOCATION_HALF_HEIGHT))[natural=peak];out;"
        ]
        
        taskForGETMethod("", parameters: methodArguments) { data, error in
            if let _ = error {
                completionHandler(success: false, peaks: nil, errorString: "Get Peaks Failed.")
            } else {
                //print(data)
                if let elements = data!.valueForKey("elements") as? [[String: AnyObject]] {
                    var peaks = [Peak]()
                    for item in elements {
                        peaks.append(Peak(dictionary: item, context: self.sharedContext))
                    }
                    completionHandler(success: true, peaks: peaks, errorString: nil)
                }
            }
        }
    }
    
    func createBoundingBoxString(latitude: Double, longitude: Double) -> String {
        let bottom_left_lon = max(longitude - Constants.BOUNDING_BOX_HALF_WIDTH, Constants.LON_MIN)
        let bottom_left_lat = max(latitude - Constants.BOUNDING_BOX_HALF_HEIGHT, Constants.LAT_MIN)
        let top_right_lon = min(longitude + Constants.BOUNDING_BOX_HALF_WIDTH, Constants.LON_MAX)
        let top_right_lat = min(latitude + Constants.BOUNDING_BOX_HALF_HEIGHT, Constants.LAT_MAX)
        
        return "\(bottom_left_lon),\(bottom_left_lat),\(top_right_lon),\(top_right_lat)"
    }
}

