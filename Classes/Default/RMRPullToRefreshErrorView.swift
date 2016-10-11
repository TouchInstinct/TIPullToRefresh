//
//  RMRPullToRefreshErrorView.swift
//  RMRPullToRefreshExample
//
//  Created by Merkulov Ilya on 17.04.16.
//  Copyright © 2016 Merkulov Ilya. All rights reserved.
//

import UIKit

class RMRPullToRefreshErrorView: RMRPullToRefreshBaseMessageView {
    
    override func messageText() -> String? {
        return "Ошибка"
    }
    
    override func messageBackgroundColor() -> UIColor {
        return UIColor(red: 234.0/255.0,
                       green: 33.0/255.0,
                       blue: 45.0/255.0,
                       alpha: 1.0)
    }
}
