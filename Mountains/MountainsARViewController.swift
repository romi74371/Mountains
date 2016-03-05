//
//  AugmentedRealityViewController.swift
//  Mountains
//
//  Created by Roman Hauptvogel on 07/02/16.
//  Copyright © 2016 Roman Hauptvogel. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData

class MountainsARViewController: ARViewController, ARDataSource {
    
    var peaks: [Peak] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let result = ARViewController.createCaptureSession()
        if result.error != nil
        {
            let message = result.error?.userInfo["description"] as? String
            let alertView = UIAlertView(title: "Error", message: message, delegate: nil, cancelButtonTitle: "Close")
            alertView.show()
            return
        }
        
        self.debugEnabled = false
        self.dataSource = self
        self.maxDistance = 0
        self.maxVisibleAnnotations = 100
        self.maxVerticalLevel = 5
        self.trackingManager.userDistanceFilter = 25
        self.trackingManager.reloadDistanceFilter = 75
        self.setAnnotations(getAnnotations(self.peaks))
    }
    
    // MARK: ARDataSource
    
    // This method is called by ARViewController, make sure to set dataSource property.
    func ar(arViewController: ARViewController, viewForAnnotation: ARAnnotation) -> ARAnnotationView
    {
        // Annotation views should be lightweight views, try to avoid xibs and autolayout all together.
        let annotationView = MountainsAnnotationView()
        annotationView.frame = CGRect(x: 0,y: 0,width: 150,height: 50)
        return annotationView;
    }
    
    private func getAnnotations(peaks: [Peak]) -> Array<ARAnnotation>
    {
        var annotations: [ARAnnotation] = []
        
        for item in peaks {
            let annotation = ARAnnotation()
            annotation.location = CLLocation(latitude: item.latitude, longitude: item.longitude)
            annotation.title = item.title
            annotations.append(annotation)
        }
        
        return annotations
    }
    
}
