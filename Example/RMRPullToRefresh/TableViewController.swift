//
//  TableViewController.swift
//  RMRPullToRefresh
//
//  Created by Merkulov Ilya on 10.04.16.
//  Copyright © 2016 Merkulov Ilya. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController {

    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        
        if let identifier = segue.identifier, let controller = segue.destinationViewController as? ViewController {
            switch identifier {
            case "perekrestok_top":
                controller.exampleType = .PerekrestokTop
            case "perekrestok_bottom":
                controller.exampleType = .PerekrestokBottom
            case "beeline_top":
                controller.exampleType = .BeelineTop
            case "beeline_bottom":
                controller.exampleType = .BeelineBottom
            case "redmadrobot_top":
                controller.exampleType = .RedmadrobotTop
            case "redmadrobot_bottom":
                controller.exampleType = .RedmadrobotBottom
            default:
                break
            }
        }
    }
}
