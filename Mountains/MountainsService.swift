//
//  MountainsService.swift
//  Mountains
//
//  Created by Roman Hauptvogel on 23/03/16.
//  Copyright © 2016 Roman Hauptvogel. All rights reserved.
//

import Foundation
import CoreData
import CoreLocation

class MountainsService {
    
    class func sharedInstance() -> MountainsService {
        struct Static {
            static let instance = MountainsService()
        }
        
        return Static.instance
    }
    
    private var peaks:[Peak] = []
    
    private func updatePeaksForLocation(location: Location, success_callback: (result: Bool) -> Void) {
        OSMClient.sharedInstance().getPeaks(location.getLocation()) { (success, peaks, errorString) in
            if (success == true) {
                print("Finding peaks done!")
                
                self.peaks = peaks!
                for peak in peaks! {
                    peak.location = location
                }
                CoreDataStackManager.sharedInstance().saveContext()
                
                success_callback(result: true)
            } else {
                print("Finding peaks error!")
                success_callback(result: false)
            }
        }
    }
    
    class func getPeaks() -> [Peak]? {
        return MountainsService.sharedInstance().peaks
    }
    
    class func updatePeaksForLocation(location: Location, success: (result: Bool) -> Void) {
        MountainsService.sharedInstance().updatePeaksForLocation(location, success_callback:success)
    }
    
    class func setPeaksForLocation(peaks: [Peak]) {
        MountainsService.sharedInstance().peaks = peaks
    }
}