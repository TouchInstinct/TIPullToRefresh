//
//  RMRPullToRefreshView.swift
//  RMRPullToRefresh
//
//  Created by Merkulov Ilya on 03.04.16.
//  Copyright © 2016 Merkulov Ilya. All rights reserved.
//

import UIKit

public class RMRPullToRefreshView: UIView, RMRPullToRefreshViewProtocol {
    
    var pullToRefreshIsLoading = false
    
    // Begin Loading
    public func prepareForLoadingAnimation(startProgress: CGFloat) {}
    public func beginLoadingAnimation() {}
    
    // End Loading
    public func willEndLoadingAnimation() {}
    public func didEndLoadingAnimation(hidden: Bool) {}
    
    // Dragging
    public func didChangeDraggingProgress(progress: CGFloat) {}
}
