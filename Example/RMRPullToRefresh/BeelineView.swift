//
//  BeelineView.swift
//  RMRPullToRefresh
//
//  Created by Merkulov Ilya on 10.04.16.
//  Copyright © 2016 Merkulov Ilya. All rights reserved.
//

import UIKit
import RMRPullToRefresh

enum AnimationStage: Int {
    case stage1 // big medium small
    case stage2 // big medium
    case stage3 // big
    case stage4 //
    case stage5 // big
    case stage6 // big medium
    
    static var count: Int { return AnimationStage.stage6.hashValue + 1}
}

class BeelineView: RMRPullToRefreshView {

    @IBOutlet var bigIcons: [UIImageView]!
    @IBOutlet var mediumIcons: [UIImageView]!
    @IBOutlet var smallIcons: [UIImageView]!
    
    var animationIsCanceled = false
    var animationStage: AnimationStage?
    
    class func XIB_VIEW() -> BeelineView? {
        let subviewArray = Bundle.main.loadNibNamed("BeelineView", owner: self, options: nil)
        return subviewArray?.first as? BeelineView
    }

    // MARK: - Private
    
    func hideBigIcons(_ hide: Bool) {
        for iV in bigIcons { iV.isHidden = hide }
    }
    
    func hideMediumIcons(_ hide: Bool) {
        for iV in mediumIcons { iV.isHidden = hide }
    }
    
    func hideSmallIcons(_ hide: Bool) {
        for iV in smallIcons { iV.isHidden = hide }
    }
    
    @objc func executeAnimation() {
        
        if animationIsCanceled {
            return
        }
        
        hideBigIcons(animationStage == .stage4)
        hideMediumIcons(animationStage == .stage3 || animationStage == .stage4 || animationStage == .stage5)
        hideSmallIcons(animationStage != .stage1)
        
        if let stage = animationStage {
            animationStage = AnimationStage(rawValue: (stage.rawValue+1)%AnimationStage.count)
        }
        
        perform(#selector(executeAnimation), with: nil, afterDelay: 0.4)
    }
    
    // MARK: - RMRPullToRefreshViewProtocol
    
    override func didChangeDraggingProgress(_ progress: CGFloat) {
        hideBigIcons(progress < 0.33)
        hideMediumIcons(progress < 0.66)
        hideSmallIcons(progress < 0.99)
    }
    
    override func beginLoadingAnimation() {
        animationIsCanceled = false
        animationStage = .stage1
        executeAnimation()
    }
    
    override func didEndLoadingAnimation(_ hidden: Bool) {
        animationIsCanceled = true
    }
}
