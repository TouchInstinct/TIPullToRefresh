//
//  RMRPullToRefreshViewFactory.swift
//  RMRPullToRefresh
//
//  Created by Merkulov Ilya on 19.03.16.
//  Copyright © 2016 Merkulov Ilya. All rights reserved.
//

import UIKit

open class RMRPullToRefreshViewFactory: NSObject {

    class func create(_ result: RMRPullToRefreshResultType) -> RMRPullToRefreshView? {
        switch result {
        case .success:
            return RMRPullToRefreshSuccessView(result: result)
        case .noUpdates:
            return RMRPullToRefreshNoUpdatesView(result: result)
        case .error:
            return RMRPullToRefreshErrorView(result: result)
        }
        
    }
}
