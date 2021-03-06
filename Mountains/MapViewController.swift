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
    
    // Map region keys for NSUserDefaults
    let MapSavedRegionExists = "map.savedRegionExists"
    let MapCenterLatitudeKey = "map.center.latitude"
    let MapCenterLongitudeKey = "map.center.longitude"
    let MapSpanLatitudeDeltaKey = "map.span.latitudeDelta"
    let MapSpanLongitudeDeltaKey = "map.span.longitudeDelta"
    
    var locationManager: CLLocationManager!
    var location: Location?

    @IBOutlet var mapView: MKMapView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var slider: UISlider!
    
    @IBAction func sliderTouchUpInside(sender: UISlider) {
        print(sender.value)
        
        activityIndicator.hidden = false
        activityIndicator.startAnimating()
        
        MountainsService.updatePeaksForLocation(location!, offset: slider.value, success: { (result) -> Void in
            if (result == true) {
                self.redraw();
            } else {
                dispatch_async(dispatch_get_main_queue(), {
                    let alertController = UIAlertController(title: "Alert", message:
                        "Error loading peaks!", preferredStyle: UIAlertControllerStyle.Alert)
                    alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
                    
                    self.presentViewController(alertController, animated: true, completion: nil)
                })
            }
            
            dispatch_async(dispatch_get_main_queue(), {
                self.activityIndicator.stopAnimating()
                self.activityIndicator.hidden = true
            })
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.mapType = MKMapType(rawValue: 0)!
        mapView.userTrackingMode = MKUserTrackingMode(rawValue: 2)!
        
        activityIndicator.hidden = true
        
        do {
            try fetchedPeakResultsController.performFetch()
        } catch {}
        
        fetchedPeakResultsController.delegate = self
        
        // Load previous map state
        loadPersistedMapViewRegion()
        
        // if location is persisted, load loacation
        if ((fetchedPeakResultsController.fetchedObjects as! [Peak]).count > 0) {
            location = (fetchedPeakResultsController.fetchedObjects as! [Peak])[0].location
            MountainsService.setPeaksForLocation(fetchedPeakResultsController.fetchedObjects as! [Peak])
        }
        
        self.redraw()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
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
        //if control == view.rightCalloutAccessoryView {
            //let controller = self.storyboard!.instantiateViewControllerWithIdentifier("AlbumViewController") as! AlbumViewController
            //let annotation = view.annotation as! Peak
            //controller.pin = annotation
            //self.navigationController!.pushViewController(controller, animated: true)
            
        //}
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
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.draggable = false
            pinView!.pinTintColor = MKPinAnnotationView.greenPinColor()
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
        
        let currentLocation = manager.location!
        if (location == nil) || (location?.equal(currentLocation) == false ) {
            activityIndicator.hidden = false
            activityIndicator.startAnimating()
            
            if (location == nil) {
                location = Location(location: currentLocation, peaks: [], context: self.sharedContext)
            } else {
                location?.changeLocation(currentLocation, peaks: [])
            }
            
            let zoomWidth = (OSMClient.Constants.LOCATION_HALF_WIDTH + Double(slider.value)) * 2
            let zoomHeigh = (OSMClient.Constants.LOCATION_HALF_HEIGHT + Double(slider.value)) * 2
            
            mapView.setRegion(MKCoordinateRegionMake(CLLocationCoordinate2DMake(locValue.latitude, locValue.longitude), MKCoordinateSpan(latitudeDelta: zoomWidth, longitudeDelta: zoomHeigh)), animated: true)
        
            MountainsService.updatePeaksForLocation(location!, offset: slider.value, success: { (result) -> Void in
                if (result == true) {
                    self.redraw();
                } else {
                    dispatch_async(dispatch_get_main_queue(), {
                        let alertController = UIAlertController(title: "Alert", message:
                            "Error loading peaks!", preferredStyle: UIAlertControllerStyle.Alert)
                        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
                        
                        self.presentViewController(alertController, animated: true, completion: nil)
                    })
                }
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.activityIndicator.stopAnimating()
                    self.activityIndicator.hidden = true
                })
            })
        }
    }

    private func redraw() {
        dispatch_async(dispatch_get_main_queue(), {
            self.mapView.removeAnnotations(self.mapView.annotations)
            
            self.mapView.addAnnotations(MountainsService.getPeaks()!)
        })
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

