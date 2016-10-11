//
//  RMRPullToRefreshViewProtocol.swift
//  RMRPullToRefreshViewProtocol
//
//  Created by Merkulov Ilya on 19.03.16.
//  Copyright © 2016 Merkulov Ilya. All rights reserved.
//

import UIKit

public protocol RMRPullToRefreshViewProtocol {
   
    // Begin Loading
    func prepareForLoadingAnimation(_ startProgress: CGFloat)
    func beginLoadingAnimation()
    
    // End Loading
    func willEndLoadingAnimation()
    func didEndLoadingAnimation(_ hidden: Bool)
    
    // Dragging
    func didChangeDraggingProgress(_ progress: CGFloat)
}
