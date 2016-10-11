//
//  PerekrestokView.swift
//  RMRPullToRefresh
//
//  Created by Merkulov Ilya on 24.03.16.
//  Copyright © 2016 Merkulov Ilya. All rights reserved.
//

import UIKit
import RMRPullToRefresh

class PerekrestokView: RMRPullToRefreshView {
    
    @IBOutlet weak var logoImageView: UIImageView!

    var fromValue: CGFloat = 0.0
    
    class func XIB_VIEW() -> PerekrestokView? {
        let subviewArray = Bundle.main.loadNibNamed("PerekrestokView", owner: self, options: nil)
        return subviewArray?.first as? PerekrestokView
    }
    
    // MARK: - Private
    
    func angle(_ progress: CGFloat) -> CGFloat  {
        return -CGFloat(M_PI)/progress
    }
    
    // MARK: - RMRPullToRefreshViewProtocol
    
    override func didChangeDraggingProgress(_ progress: CGFloat) {
        logoImageView.transform = CGAffineTransform(rotationAngle: angle(progress));
    }
    
    override func prepareForLoadingAnimation(_ startProgress: CGFloat) {
        fromValue = angle(startProgress)
    }
    
    override func beginLoadingAnimation() {
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.fromValue = fromValue
        rotationAnimation.byValue = 2*M_PI
        rotationAnimation.duration = 0.9
        rotationAnimation.repeatCount = HUGE
        
        self.logoImageView.layer.add(rotationAnimation, forKey: "transformAnimation")
    }
    
    override func didEndLoadingAnimation(_ hidden: Bool) {
        self.logoImageView.layer.removeAnimation(forKey: "transformAnimation")
    }
}
