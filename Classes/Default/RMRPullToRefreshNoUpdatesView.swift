//
//  RMRPullToRefreshNoUpdatesView.swift
//  RMRPullToRefreshExample
//
//  Created by Merkulov Ilya on 17.04.16.
//  Copyright © 2016 Merkulov Ilya. All rights reserved.
//

import UIKit

class RMRPullToRefreshNoUpdatesView: RMRPullToRefreshBaseMessageView {
    
    override func messageText() -> String? {
        return "Нет обновлений"
    }
    
    override func messageBackgroundColor() -> UIColor {
        return UIColor(red: 148.0/255.0,
                       green: 199.0/255.0,
                       blue: 111.0/255.0,
                       alpha: 1.0)
    }
}
