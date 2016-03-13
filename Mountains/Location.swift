//
//  Location.swift
//  Mountains
//
//  Created by Roman Hauptvogel on 13/03/16.
//  Copyright © 2016 Roman Hauptvogel. All rights reserved.
//

import CoreData
import CoreLocation

@objc(Location)

class Location : NSManagedObject {
    
    struct Keys {
        static let Latitude = "lat"
        static let Longitude = "lon"
    }
    
    @NSManaged var latitude: Double
    @NSManaged var longitude: Double
    @NSManaged var peaks: [Peak]?
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        let entity =  NSEntityDescription.entityForName("Location", inManagedObjectContext: context)!
        
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        latitude = dictionary[Keys.Latitude] as! Double
        longitude = dictionary[Keys.Longitude] as! Double
    }
    
    init(location: CLLocation, peaks: [Peak], context: NSManagedObjectContext) {
        let entity =  NSEntityDescription.entityForName("Location", inManagedObjectContext: context)!
        
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        self.latitude = location.coordinate.latitude
        self.longitude = location.coordinate.longitude
        
    }
    
    lazy var sharedContext: NSManagedObjectContext! = {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }()
    
    func equal(location: CLLocation) -> Bool {
        
        let distance = location.distanceFromLocation(CLLocation(latitude: self.latitude, longitude: self.longitude))
        
        if (distance < OSMClient.Constants.LOCATION_OFFSET) {
            return true
        } else {
            return false
        }
    }
    
    // Delete all location's peaks
    func deletePeaks() {
        if let peaks = self.peaks {
            for peak in peaks {
                deletePeak(peak)
            }
        }
        //pendingDownloads = Int(FlickrClient.Constants.PER_PAGE)
    }
    
    // Delete one location peak
    func deletePeak(peak: Peak) {
        peak.location = nil
        sharedContext.deleteObject(peak)
    }
}

