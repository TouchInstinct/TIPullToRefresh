//
//  RMRPullToRefreshConstants.swift
//  RMRPullToRefresh
//
//  Created by Merkulov Ilya on 19.03.16.
//  Copyright © 2016 Merkulov Ilya. All rights reserved.
//

import UIKit

public enum RMRPullToRefreshPosition: Int {
    case top
    case bottom
}

public enum RMRPullToRefreshState: Int {
    case stopped
    case dragging
    case loading
}

public enum RMRPullToRefreshResultType: Int {
    case success = 0
    case noUpdates
    case error
}

public struct RMRPullToRefreshConstants {
    
    static let DefaultHeight = CGFloat(90.0)
    static let DefaultBackgroundColor = UIColor.white
}
