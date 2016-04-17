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
    case Stage1 // big medium small
    case Stage2 // big medium
    case Stage3 // big
    case Stage4 //
    case Stage5 // big
    case Stage6 // big medium
    
    static var count: Int { return AnimationStage.Stage6.hashValue + 1}
}

class BeelineView: RMRPullToRefreshView {

    @IBOutlet var bigIcons: [UIImageView]!
    @IBOutlet var mediumIcons: [UIImageView]!
    @IBOutlet var smallIcons: [UIImageView]!
    
    var animationIsCanceled = false
    var animationStage: AnimationStage?
    
    class func XIB_VIEW() -> BeelineView? {
        let subviewArray = NSBundle.mainBundle().loadNibNamed("BeelineView", owner: self, options: nil)
        return subviewArray.first as? BeelineView
    }

    // MARK: - Private
    
    func hideBigIcons(hide: Bool) {
        for iV in bigIcons { iV.hidden = hide }
    }
    
    func hideMediumIcons(hide: Bool) {
        for iV in mediumIcons { iV.hidden = hide }
    }
    
    func hideSmallIcons(hide: Bool) {
        for iV in smallIcons { iV.hidden = hide }
    }
    
    @objc func executeAnimation() {
        
        if animationIsCanceled {
            return
        }
        
        hideBigIcons(animationStage == .Stage4)
        hideMediumIcons(animationStage == .Stage3 || animationStage == .Stage4 || animationStage == .Stage5)
        hideSmallIcons(animationStage != .Stage1)
        
        if let stage = animationStage {
            animationStage = AnimationStage(rawValue: (stage.rawValue+1)%AnimationStage.count)
        }
        
        performSelector(#selector(executeAnimation), withObject: nil, afterDelay: 0.4)
    }
    
    // MARK: - RMRPullToRefreshViewProtocol
    
    override func didChangeDraggingProgress(progress: CGFloat) {
        hideBigIcons(progress < 0.33)
        hideMediumIcons(progress < 0.66)
        hideSmallIcons(progress < 0.99)
    }
    
    override func beginLoadingAnimation() {
        animationIsCanceled = false
        animationStage = .Stage1
        executeAnimation()
    }
    
    override func didEndLoadingAnimation(hidden: Bool) {
        animationIsCanceled = true
    }
}
