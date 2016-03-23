//
//  PeakListViewController.swift
//  Mountains
//
//  Created by Roman Hauptvogel on 21/03/16.
//  Copyright © 2016 Roman Hauptvogel. All rights reserved.
//

import UIKit

class PeakListViewController: UITableViewController {
    
    @IBOutlet weak var peakListTableView: UITableView!
    private var peaks = [Peak]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        peakListTableView?.delegate = self;
        
        self.peaks = MountainsService.getPeaks()!

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.peakListTableView?.reloadData();
    }
    
    // MARK: - UITableViewDelegate and UITableViewDataSource
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellReuseIdentifier = "PeakListTableViewCell"
        
        let peak = self.peaks[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier(cellReuseIdentifier)
        
        /* Set cell defaults */
        cell!.textLabel!.text = "\(peak.name)"
        cell!.imageView!.image = UIImage(named: "pinIco")
        cell!.imageView!.contentMode = UIViewContentMode.ScaleAspectFit
        
        return cell!
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.peaks.count
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 40
    }
}
