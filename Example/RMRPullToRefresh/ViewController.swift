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

final class ViewController: UIViewController {

    // MARK: - Public properties
    
    var exampleType: ExampleType = .beelineBottom
    
    // MARK: - Private properites
    
    private var pullToRefresh: RMRPullToRefresh?
    private let formatter = DateFormatter()
    private var items: [String] = []
    private var count = 2
    private var result = RMRPullToRefreshResultType.success
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - IBActions
    
    @IBAction func settings(_ sender: AnyObject) {
        let alertController = UIAlertController(title: "Result type", message: nil, preferredStyle: .actionSheet)
        
        let successAction = UIAlertAction(title: "Success", style: .default) { _ in
            self.result = .noUpdates
        }
        alertController.addAction(successAction)
        
        let noUpdatesAction = UIAlertAction(title: "No updates", style: .default) { _ in
            self.result = .noUpdates
        }
        alertController.addAction(noUpdatesAction)
        
        let errorAction = UIAlertAction(title: "Error", style: .default) { _ in
            self.result = .error
        }
        alertController.addAction(errorAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        someConfiguring()
        loadData()
        
        configurePullToRefresh()
    }
    
    // MARK: - Pull to Refresh
    
    private func configurePullToRefresh() {
        pullToRefresh = RMRPullToRefresh(scrollView: tableView, position: position()) { [weak self] in
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 5, execute: {
                if self?.result == .success {
                    self?.loadMore()
                }
                if let result = self?.result {
                    self?.pullToRefresh?.stopLoading(result)
                }
            })
        }
        
        switch exampleType {
        case .perekrestokTop, .perekrestokBottom:
            perekrestok()
        case .beelineTop, .beelineBottom:
            beeline()
        case .redmadrobotTop, .redmadrobotBottom:
            redmadrobot()
        }
        
        pullToRefresh?.setHideDelay(5.0, result: .success)
        pullToRefresh?.hideWhenError = false
    }
    
    // MARK: - Build example values
    
    private func perekrestok() {
        if let pullToRefreshView = PerekrestokView.XIB_VIEW() {
            pullToRefresh?.configureView(pullToRefreshView, state: .dragging, result: .success)
            pullToRefresh?.configureView(pullToRefreshView, state: .loading, result: .success)
        }
        pullToRefresh?.height = 90.0
        pullToRefresh?.backgroundColor = UIColor(
            red: 16.0/255.0,
            green: 192.0/255.0,
            blue: 119.0/255.0,
            alpha: 1.0)
    }
    
    private func beeline() {
        if let pullToRefreshView = BeelineView.XIB_VIEW() {
            pullToRefresh?.configureView(pullToRefreshView, state: .dragging, result: .success)
            pullToRefresh?.configureView(pullToRefreshView, state: .loading, result: .success)
        }
        pullToRefresh?.height = 90.0
        pullToRefresh?.backgroundColor = UIColor.white
    }
    
    private func redmadrobot() {
        pullToRefresh?.setupDefaultSettings()
    }
    
    private func position() -> RMRPullToRefreshPosition {
        if exampleType == .perekrestokTop || exampleType == .beelineTop || exampleType == .redmadrobotTop {
            return .top
        }
        return .bottom
    }
    
    // MARK: - Configure
    
    private func someConfiguring() {
        formatter.dateStyle = DateFormatter.Style.long
        formatter.timeStyle = .medium
    }
    
    // MARK: - Test data
    
    private func loadData() {
        for _ in 0...count {
            items.append(formatter.string(from: Date()))
        }
    }
    
    private func loadMore() {
        for _ in 0...20 {
            self.items.append(formatter.string(from: Date(timeIntervalSinceNow: 20)))
        }
        self.tableView.reloadData()
    }
}

// MARK: - UITableViewDataSource
extension ViewController: UITableViewDataSource {
    
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
