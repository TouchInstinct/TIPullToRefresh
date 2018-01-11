//
//  RMRPullToRefresh.swift
//  RMRPullToRefresh
//
//  Created by Merkulov Ilya on 03.04.16.
//  Copyright © 2016 Merkulov Ilya. All rights reserved.
//

import UIKit

open class RMRPullToRefresh: NSObject {

    private var сontroller: RMRPullToRefreshController?
    
    open var height : CGFloat = RMRPullToRefreshConstants.DefaultHeight {
        didSet {
            сontroller?.configureHeight(height)
        }
    }
    
    open var backgroundColor : UIColor = RMRPullToRefreshConstants.DefaultBackgroundColor {
        didSet {
            сontroller?.configureBackgroundColor(backgroundColor)
        }
    }
    
    open var hideWhenError: Bool = true {
        didSet {
            сontroller?.hideWhenError = hideWhenError
        }
    }
    
    public init(
        scrollView: UIScrollView,
        position:RMRPullToRefreshPosition,
        actionHandler: @escaping () -> Void)
    {
        super.init()
        
        let controller = RMRPullToRefreshController(
            scrollView: scrollView,
            position: position,
            actionHandler: actionHandler)
        
        scrollView.addSubview(controller.containerView)
        self.сontroller = controller
    }
    
    open func configureView(_ view :RMRPullToRefreshView, state:RMRPullToRefreshState, result:RMRPullToRefreshResultType) {
        сontroller?.configureView(view, state: state, result: result)
    }
    
    open func configureView(_ view :RMRPullToRefreshView, result:RMRPullToRefreshResultType) {
        сontroller?.configureView(view, result: result)
    }
    
    open func setupDefaultSettings() {
        сontroller?.setupDefaultSettings()
    }

    open func startLoading() {
        сontroller?.startLoading()
    }
    
    open func stopLoading() {
        stopLoading(.success)
    }
    
    open func stopLoading(_ result:RMRPullToRefreshResultType) {
        сontroller?.stopLoading(result)
    }
    
    open func setHideDelay(_ delay: TimeInterval, result: RMRPullToRefreshResultType) {
        сontroller?.setHideDelay(delay, result: result)
    }
    
    open var state: RMRPullToRefreshState {
        return сontroller?.state ?? .stopped
    }
}
