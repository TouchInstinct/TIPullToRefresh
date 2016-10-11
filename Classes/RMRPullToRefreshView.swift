//
//  RMRPullToRefreshView.swift
//  RMRPullToRefresh
//
//  Created by Merkulov Ilya on 03.04.16.
//  Copyright © 2016 Merkulov Ilya. All rights reserved.
//

import UIKit

open class RMRPullToRefreshView: UIView, RMRPullToRefreshViewProtocol {
    
    var pullToRefreshIsLoading = false
    
    // Begin Loading
    open func prepareForLoadingAnimation(_ startProgress: CGFloat) {}
    open func beginLoadingAnimation() {}
    
    // End Loading
    open func willEndLoadingAnimation() {}
    open func didEndLoadingAnimation(_ hidden: Bool) {}
    
    // Dragging
    open func didChangeDraggingProgress(_ progress: CGFloat) {}
}
