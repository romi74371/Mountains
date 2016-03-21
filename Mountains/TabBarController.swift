//
//  TabBarController.swift
//  Mountains
//
//  Created by Roman Hauptvogel on 21/03/16.
//  Copyright © 2016 Roman Hauptvogel. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {
    
    var appDelegate: AppDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    }
    
    @IBAction func itemTouchUp(sender: AnyObject) {
        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("MountainsARViewController") as! MountainsARViewController
        self.navigationController!.pushViewController(controller, animated: true)
    }
}
