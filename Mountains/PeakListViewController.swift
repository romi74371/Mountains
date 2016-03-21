//
//  PeakListViewController.swift
//  Mountains
//
//  Created by Roman Hauptvogel on 21/03/16.
//  Copyright © 2016 Roman Hauptvogel. All rights reserved.
//

import UIKit
import CoreData

class PeakListViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var peakListTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        peakListTableView?.delegate = self;
        
        do {
            try fetchedPeakResultsController.performFetch()
        } catch {}
        
        fetchedPeakResultsController.delegate = self

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
    
    // MARK: - UITableViewDelegate and UITableViewDataSource
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellReuseIdentifier = "PeakListTableViewCell"
        
        let peak = (fetchedPeakResultsController.fetchedObjects as! [Peak])[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier(cellReuseIdentifier)
        
        /* Set cell defaults */
        cell!.textLabel!.text = "\(peak.name) \(peak.elevation!) m"
        cell!.imageView!.image = UIImage(named: "pinIco")
        cell!.imageView!.contentMode = UIViewContentMode.ScaleAspectFit
        
        return cell!
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (fetchedPeakResultsController.fetchedObjects as! [Peak]).count
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 40
    }
}
