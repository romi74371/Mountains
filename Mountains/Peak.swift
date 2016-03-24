//
//  Peak.swift
//  Mountains
//
//  Created by Roman Hauptvogel on 30/01/16.
//  Copyright © 2016 Roman Hauptvogel. All rights reserved.
//

import UIKit
import CoreData
import MapKit

@objc(Peak)

class Peak : NSManagedObject, MKAnnotation {
    
    struct Keys {
        static let Latitude = "lat"
        static let Longitude = "lon"
        static let Tags = "tags"
        static let Name = "name"
        static let Elevation = "ele"
    }
    
    @NSManaged var latitude: Double
    @NSManaged var longitude: Double
    @NSManaged var name: String
    @NSManaged var elevation: NSNumber?
    @NSManaged var location: Location?
    
    var title: String?
    var subtitle: String?
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        self.title = self.name
        self.subtitle = self.elevation?.stringValue
    }
    
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        let entity =  NSEntityDescription.entityForName("Peak", inManagedObjectContext: context)!
        
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        latitude = dictionary[Keys.Latitude] as! Double
        longitude = dictionary[Keys.Longitude] as! Double
        if let tags = dictionary[Keys.Tags] as? [String: AnyObject] {
            if let name = tags[Keys.Name] as? String {
                self.name = name
            }
        }
        //name = dictionary[Keys.Tags]![Keys.Name] as! String
        if let ele = (dictionary[Keys.Tags]![Keys.Elevation] as? String) {
            self.elevation = Int(ele)
        }
        
        self.title = self.name
        self.subtitle = self.elevation?.stringValue
    }
    
    lazy var sharedContext: NSManagedObjectContext! = {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }()
    
    // MARK - MKAnnotation
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    func setCoordinate(newCoordinate: CLLocationCoordinate2D) {
        willChangeValueForKey("coordinate")
        self.latitude = newCoordinate.latitude
        self.longitude = newCoordinate.longitude
        didChangeValueForKey("coordinate")
    }
    
}

