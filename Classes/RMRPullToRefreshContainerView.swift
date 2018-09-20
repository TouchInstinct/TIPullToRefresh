//
//  RMRPullToRefreshContainerView.swift
//  RMRPullToRefresh
//
//  Created by Merkulov Ilya on 19.03.16.
//  Copyright © 2016 Merkulov Ilya. All rights reserved.
//

import UIKit

open class RMRPullToRefreshContainerView: UIView {

    var currentView: RMRPullToRefreshView?
    
    var storage = [String: RMRPullToRefreshView]()

    open func configureView(_ view:RMRPullToRefreshView, state:RMRPullToRefreshState, result:RMRPullToRefreshResultType) {
        let key = storageKey(state, result:result)
        self.storage[key] = view
    }
    
    func updateView(_ state: RMRPullToRefreshState, result: RMRPullToRefreshResultType) {

        clear()
        if let view = obtainView(state, result: result) {
            view.translatesAutoresizingMaskIntoConstraints = false
            addSubview(view)
            addConstraint(constraint(self, subview: view, attribute: NSLayoutConstraint.Attribute.left))
            addConstraint(constraint(self, subview: view, attribute: NSLayoutConstraint.Attribute.top))
            addConstraint(constraint(self, subview: view, attribute: NSLayoutConstraint.Attribute.right))
            addConstraint(constraint(self, subview: view, attribute: NSLayoutConstraint.Attribute.bottom))
            view.layoutIfNeeded()
            self.currentView = view
        }
    }
    
    func dragging(_ progress: CGFloat) {
        if let view = self.currentView {
            view.didChangeDraggingProgress(progress)
        }
    }
    
    func startLoadingAnimation(_ startProgress: CGFloat) {
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
    
    func stopAllAnimations(_ hidden: Bool) {
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
    
    func obtainView(_ state: RMRPullToRefreshState, result: RMRPullToRefreshResultType) -> RMRPullToRefreshView? {
        let key = storageKey(state, result:result)
        return self.storage[key]
    }
    
    func storageKey(_ state: RMRPullToRefreshState, result: RMRPullToRefreshResultType) -> String {
        return String(state.rawValue) + "_" + String(result.rawValue)
    }
    
    
    // MARK: - Constraint
    
    func constraint(_ superview: UIView, subview: UIView, attribute: NSLayoutConstraint.Attribute) -> NSLayoutConstraint {
        return NSLayoutConstraint(item: subview, attribute: attribute, relatedBy: NSLayoutConstraint.Relation.equal, toItem: superview, attribute: attribute, multiplier: 1, constant: 0)
    }
}
