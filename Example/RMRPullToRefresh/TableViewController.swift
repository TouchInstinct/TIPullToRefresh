//
//  TableViewController.swift
//  RMRPullToRefresh
//
//  Created by Merkulov Ilya on 10.04.16.
//  Copyright © 2016 Merkulov Ilya. All rights reserved.
//

import UIKit

final class TableViewController: UITableViewController {

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if let identifier = segue.identifier, let controller = segue.destination as? ViewController {
            switch identifier {
            case "perekrestok_top":
                controller.exampleType = .perekrestokTop
            case "perekrestok_bottom":
                controller.exampleType = .perekrestokBottom
            case "beeline_top":
                controller.exampleType = .beelineTop
            case "beeline_bottom":
                controller.exampleType = .beelineBottom
            case "redmadrobot_top":
                controller.exampleType = .redmadrobotTop
            case "redmadrobot_bottom":
                controller.exampleType = .redmadrobotBottom
            default:
                break
            }
        }
    }
}
