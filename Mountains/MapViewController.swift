//
//  MapViewController.swift
//  Mountains
//
//  Created by Roman Hauptvogel on 23/01/16.
//  Copyright © 2016 Roman Hauptvogel. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import CoreData

class MapViewController: UIViewController, MKMapViewDelegate, NSFetchedResultsControllerDelegate, CLLocationManagerDelegate, ARDataSource {
    
    var peaks: [Peak] = []
    
    // Map region keys for NSUserDefaults
    let MapSavedRegionExists = "map.savedRegionExists"
    let MapCenterLatitudeKey = "map.center.latitude"
    let MapCenterLongitudeKey = "map.center.longitude"
    let MapSpanLatitudeDeltaKey = "map.span.latitudeDelta"
    let MapSpanLongitudeDeltaKey = "map.span.longitudeDelta"
    
    var locationManager: CLLocationManager!

    @IBOutlet var mapView: MKMapView!
    
    @IBAction func itemTouchUp(sender: AnyObject) {
        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("MountainsARViewController") as! MountainsARViewController
        controller.peaks = self.peaks
        self.navigationController!.pushViewController(controller, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.startUpdatingLocation()
        
        self.mapView.delegate = self
        self.mapView.showsUserLocation = true
        self.mapView.mapType = MKMapType(rawValue: 0)!
        self.mapView.userTrackingMode = MKUserTrackingMode(rawValue: 2)!
        
        do {
            try fetchedPeakResultsController.performFetch()
        } catch {}
        
        fetchedPeakResultsController.delegate = self
        
        // Load previous map state
        loadPersistedMapViewRegion()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        OSMClient.sharedInstance().getPeaks(self.locationManager.location!) { (success, peaks, errorString) in
            if (success == true) {
                print("Finding peaks done!")
                self.peaks = peaks!
                self.mapView.addAnnotations(peaks!)
            } else {
                print("Finding peaks error!")
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Core Data Convenience. This will be useful for fetching. And for adding and saving objects as well.
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    // lazy fetchedResultsController property
    lazy var fetchedPeakResultsController: NSFetchedResultsController = {
        
        let fetchRequest = NSFetchRequest(entityName: "Peak")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "latitude", ascending: true)]
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
            managedObjectContext: self.sharedContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        return fetchedResultsController
        
    }()

    // MARK: - MKMapViewDelegate
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            //let controller = self.storyboard!.instantiateViewControllerWithIdentifier("AlbumViewController") as! AlbumViewController
            //let annotation = view.annotation as! Peak
            //controller.pin = annotation
            //self.navigationController!.pushViewController(controller, animated: true)
            
        }
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView,
        didChangeDragState newState: MKAnnotationViewDragState, fromOldState oldState: MKAnnotationViewDragState) {
            
            if newState == MKAnnotationViewDragState.Ending {
                CoreDataStackManager.sharedInstance().saveContext()
            }
    }
    
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        persistMapViewRegion(mapView.region)
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "peak"
        
        let pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            //pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            //pinView!.canShowCallout = true
            //pinView!.draggable = true
            //pinView!.pinTintColor = MKPinAnnotationView.greenPinColor()
            //pinView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    // MARK: CLLocationManagerDelegate
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        print("locations = \(locValue.latitude) \(locValue.longitude)")
        
        //mapView.setRegion(MKCoordinateRegionMake(CLLocationCoordinate2DMake(locValue.latitude, locValue.longitude), MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)), animated: true)
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        mapView.showsUserLocation = (status == .AuthorizedAlways)
    }
    
    // MARK: NSUserDefaults
    
    // Saves a region to NSUserDefaults
    func persistMapViewRegion(region: MKCoordinateRegion) {
        let userDetaults = NSUserDefaults.standardUserDefaults()
        
        userDetaults.setDouble(region.center.latitude, forKey: MapCenterLatitudeKey)
        userDetaults.setDouble(region.center.longitude, forKey: MapCenterLongitudeKey)
        userDetaults.setDouble(region.span.latitudeDelta, forKey: MapSpanLatitudeDeltaKey)
        userDetaults.setDouble(region.span.longitudeDelta, forKey: MapSpanLongitudeDeltaKey)
        userDetaults.setBool(true, forKey: MapSavedRegionExists)
    }
    
    // Load the saved region if exists in NSUserData
    func loadPersistedMapViewRegion() {
        let userDetaults = NSUserDefaults.standardUserDefaults()
        
        let savedRegionExists = userDetaults.boolForKey(MapSavedRegionExists)
        
        if (savedRegionExists) {
            let latitude = userDetaults.doubleForKey(MapCenterLatitudeKey)
            let longitude = userDetaults.doubleForKey(MapCenterLongitudeKey)
            let latitudeDelta = userDetaults.doubleForKey(MapSpanLatitudeDeltaKey)
            let longitudeDelta = userDetaults.doubleForKey(MapSpanLongitudeDeltaKey)
            
            mapView.region.center = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            mapView.region.span = MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
        }
        
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

