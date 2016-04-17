//
//  RMRPullToRefreshViewFactory.swift
//  RMRPullToRefresh
//
//  Created by Merkulov Ilya on 19.03.16.
//  Copyright © 2016 Merkulov Ilya. All rights reserved.
//

import UIKit

public class RMRPullToRefreshViewFactory: NSObject {

    class func create(result: RMRPullToRefreshResultType) -> RMRPullToRefreshView? {
        switch result {
        case .Success:
            return RMRPullToRefreshSuccessView(result: result)
        case .NoUpdates:
            return RMRPullToRefreshNoUpdatesView(result: result)
        case .Error:
            return RMRPullToRefreshErrorView(result: result)
        }
        
    }
}
