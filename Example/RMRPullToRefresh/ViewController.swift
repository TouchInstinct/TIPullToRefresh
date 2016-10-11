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
    case perekrestokTop
    case perekrestokBottom
    case beelineTop
    case beelineBottom
    case redmadrobotTop
    case redmadrobotBottom
}

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var exampleType: ExampleType = .beelineBottom
    
    var pullToRefresh: RMRPullToRefresh?
    
    let formatter = DateFormatter()
    
    var items: [String] = []
    var count = 2
    
    var result = RMRPullToRefreshResultType.success
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        someConfiguring()
        loadData()
        
        configurePullToRefresh()
    }
    
    // MARK: - Pull to Refresh
    
    func configurePullToRefresh() {
        
        pullToRefresh = RMRPullToRefresh(scrollView: tableView, position: position()) { [weak self] _ in
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(5.0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {
                if self?.result == .success {
                    self?.loadMore()
                }
                if let result = self?.result {
                    self?.pullToRefresh?.stopLoading(result)
                }
            })
        }
        
        if exampleType == .perekrestokTop || exampleType == .perekrestokBottom {
            perekrestok()
        } else if exampleType == .beelineTop || exampleType == .beelineBottom {
            beeline()
        } else if exampleType == .redmadrobotTop || exampleType == .redmadrobotBottom {
            redmadrobot()
        }
        
        pullToRefresh?.setHideDelay(5.0, result: .success)
        
        pullToRefresh?.hideWhenError = false
    }
    
    // MARK: - Build example values
    
    func perekrestok() {
        
        if let pullToRefreshView = PerekrestokView.XIB_VIEW() {
            pullToRefresh?.configureView(pullToRefreshView, state: .dragging, result: .success)
            pullToRefresh?.configureView(pullToRefreshView, state: .loading, result: .success)
        }
        pullToRefresh?.height = 90.0
        pullToRefresh?.backgroundColor = UIColor(red: 16.0/255.0,
                                                 green: 192.0/255.0,
                                                 blue: 119.0/255.0,
                                                 alpha: 1.0)
    }
    
    func beeline() {
        
        if let pullToRefreshView = BeelineView.XIB_VIEW() {
            pullToRefresh?.configureView(pullToRefreshView, state: .dragging, result: .success)
            pullToRefresh?.configureView(pullToRefreshView, state: .loading, result: .success)
        }
        pullToRefresh?.height = 90.0
        pullToRefresh?.backgroundColor = UIColor.white
    }
    
    func redmadrobot() {
        pullToRefresh?.setupDefaultSettings()
    }
    
    func position() -> RMRPullToRefreshPosition {
        if exampleType == .perekrestokTop || exampleType == .beelineTop || exampleType == .redmadrobotTop {
            return .top
        }
        return .bottom
    }
    
    // MARK: - Configure
    
    func someConfiguring() {
        formatter.dateStyle = DateFormatter.Style.long
        formatter.timeStyle = .medium
    }
    
    // MARK: - Action
    
    
    @IBAction func settings(_ sender: AnyObject) {
        UIActionSheet(title: "Result type", delegate: self, cancelButtonTitle: nil, destructiveButtonTitle: nil, otherButtonTitles: ".Success", ".NoUpdates", ".Error").show(in: self.view)
    }
    
    // MARK: - UIActionSheetDelegate
    
    func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int) {
        switch buttonIndex {
        case 0:
            self.result = .success
        case 1:
            self.result = .noUpdates
        case 2:
            self.result = .error
        default:
            break;
        }
    }
    
    // MARK: - Test data
    
    func loadData() {
        for _ in 0...count {
            items.append(formatter.string(from: Date()))
        }
    }
    
    func loadMore() {
        for _ in 0...20 {
            self.items.append(formatter.string(from: Date(timeIntervalSinceNow: 20)))
        }
        self.tableView.reloadData()
    }
    
    // MARK: - TableView
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = items[(indexPath as NSIndexPath).row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
}

