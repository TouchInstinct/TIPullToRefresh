//
//  ViewController.swift
//  RMRPullToRefresh
//
//  Created by Merkulov Ilya on 19.03.16.
//  Copyright © 2016 Merkulov Ilya. All rights reserved.
//

import UIKit
import RMRPullToRefresh

public enum ExampleType: Int {
    case PerekrestokTop
    case PerekrestokBottom
    case BeelineTop
    case BeelineBottom
    case RedmadrobotTop
    case RedmadrobotBottom
}

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var exampleType: ExampleType = .BeelineBottom
    
    var pullToRefresh: RMRPullToRefresh?
    
    let formatter = NSDateFormatter()
    
    var items: [String] = []
    var count = 2
    
    var result = RMRPullToRefreshResultType.Success
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        someConfiguring()
        loadData()
        
        configurePullToRefresh()
    }
    
    // MARK: - Pull to Refresh
    
    func configurePullToRefresh() {
        
        pullToRefresh = RMRPullToRefresh(scrollView: tableView, position: position()) { [weak self] _ in
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(5.0 * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), {
                if self?.result == .Success {
                    self?.loadMore()
                }
                if let result = self?.result {
                    self?.pullToRefresh?.stopLoading(result)
                }
            })
        }
        
        if exampleType == .PerekrestokTop || exampleType == .PerekrestokBottom {
            perekrestok()
        } else if exampleType == .BeelineTop || exampleType == .BeelineBottom {
            beeline()
        } else if exampleType == .RedmadrobotTop || exampleType == .RedmadrobotBottom {
            redmadrobot()
        }
    }
    
    // MARK: - Build example values
    
    func perekrestok() {
        
        if let pullToRefreshView = PerekrestokView.XIB_VIEW() {
            pullToRefresh?.configureView(pullToRefreshView, state: .Dragging, result: .Success)
            pullToRefresh?.configureView(pullToRefreshView, state: .Loading, result: .Success)
        }
        pullToRefresh?.height = 90.0
        pullToRefresh?.backgroundColor = UIColor(red: 16.0/255.0,
                                                 green: 192.0/255.0,
                                                 blue: 119.0/255.0,
                                                 alpha: 1.0)
    }
    
    func beeline() {
        
        if let pullToRefreshView = BeelineView.XIB_VIEW() {
            pullToRefresh?.configureView(pullToRefreshView, state: .Dragging, result: .Success)
            pullToRefresh?.configureView(pullToRefreshView, state: .Loading, result: .Success)
        }
        pullToRefresh?.height = 90.0
        pullToRefresh?.backgroundColor = UIColor.whiteColor()
    }
    
    func redmadrobot() {
        pullToRefresh?.setupDefaultSettings()
    }
    
    func position() -> RMRPullToRefreshPosition {
        if exampleType == .PerekrestokTop || exampleType == .BeelineTop || exampleType == .RedmadrobotTop {
            return .Top
        }
        return .Bottom
    }
    
    // MARK: - Configure
    
    func someConfiguring() {
        formatter.dateStyle = NSDateFormatterStyle.LongStyle
        formatter.timeStyle = .MediumStyle
    }
    
    // MARK: - Action
    
    
    @IBAction func settings(sender: AnyObject) {
        UIActionSheet(title: "Result type", delegate: self, cancelButtonTitle: nil, destructiveButtonTitle: nil, otherButtonTitles: ".Success", ".NoUpdates", ".Error").showInView(self.view)
    }
    
    // MARK: - UIActionSheetDelegate
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        switch buttonIndex {
        case 0:
            self.result = .Success
        case 1:
            self.result = .NoUpdates
        case 2:
            self.result = .Error
        default:
            break;
        }
    }
    
    // MARK: - Test data
    
    func loadData() {
        for _ in 0...count {
            items.append(formatter.stringFromDate(NSDate()))
        }
    }
    
    func loadMore() {
        for _ in 0...20 {
            self.items.append(formatter.stringFromDate(NSDate(timeIntervalSinceNow: 20)))
        }
        self.tableView.reloadData()
    }
    
    // MARK: - TableView
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        cell.textLabel?.text = items[indexPath.row]
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1;
    }
}

