//
//  RMRPullToRefreshContainerView.swift
//  RMRPullToRefresh
//
//  Created by Merkulov Ilya on 19.03.16.
//  Copyright © 2016 Merkulov Ilya. All rights reserved.
//

import UIKit

public class RMRPullToRefreshContainerView: UIView {

    var currentView: RMRPullToRefreshView?
    
    var storage = [String: RMRPullToRefreshView]()

    public func configureView(view:RMRPullToRefreshView, state:RMRPullToRefreshState, result:RMRPullToRefreshResultType) {
        let key = storageKey(state, result:result)
        self.storage[key] = view
    }
    
    func updateView(state: RMRPullToRefreshState, result: RMRPullToRefreshResultType) {

        clear()
        if let view = obtainView(state, result: result) {
            view.translatesAutoresizingMaskIntoConstraints = false
            addSubview(view)
            addConstraint(constraint(self, subview: view, attribute: NSLayoutAttribute.Left))
            addConstraint(constraint(self, subview: view, attribute: NSLayoutAttribute.Top))
            addConstraint(constraint(self, subview: view, attribute: NSLayoutAttribute.Right))
            addConstraint(constraint(self, subview: view, attribute: NSLayoutAttribute.Bottom))
            view.layoutIfNeeded()
            self.currentView = view
        }
    }
    
    func dragging(progress: CGFloat) {
        if let view = self.currentView {
            view.didChangeDraggingProgress(progress)
        }
    }
    
    func startLoadingAnimation(startProgress: CGFloat) {
        if let view = self.currentView {
            if !view.pullToRefreshIsLoading {
                view.prepareForLoadingAnimation(startProgress)
                view.pullToRefreshIsLoading = true
                view.beginLoadingAnimation()
            }
        }
    }
    
    func prepareForStopAnimations() {
        if let view = self.currentView {
            view.willEndLoadingAnimation()
        }
    }
    
    func stopAllAnimations(hidden: Bool) {
        for view in storage.values {
            view.didEndLoadingAnimation(hidden)
            view.pullToRefreshIsLoading = false
        }
    }
    
    // MARK: - Private
    
    func clear() {
        for view in subviews {
            view.removeFromSuperview()
        }
        self.currentView = nil
    }
    
    func obtainView(state: RMRPullToRefreshState, result: RMRPullToRefreshResultType) -> RMRPullToRefreshView? {
        let key = storageKey(state, result:result)
        return self.storage[key]
    }
    
    func storageKey(state: RMRPullToRefreshState, result: RMRPullToRefreshResultType) -> String {
        return String(state.rawValue) + "_" + String(result.rawValue)
    }
    
    
    // MARK: - Constraint
    
    func constraint(superview: UIView, subview: UIView, attribute: NSLayoutAttribute) -> NSLayoutConstraint {
        return NSLayoutConstraint(item: subview, attribute: attribute, relatedBy: NSLayoutRelation.Equal, toItem: superview, attribute: attribute, multiplier: 1, constant: 0)
    }
}
