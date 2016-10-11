//
//  RMRPullToRefreshBaseView.swift
//  RMRPullToRefreshExample
//
//  Created by Merkulov Ilya on 12.04.16.
//  Copyright © 2016 Merkulov Ilya. All rights reserved.
//

import UIKit

let image1: String  = "redmadlogo-1"
let image2: String  = "redmadlogo-2"
let image3: String  = "redmadlogo-3"

class RMRPullToRefreshBaseView: RMRPullToRefreshView {

    let images = [UIImage(named: image1)!,
                  UIImage(named: image2)!,
                  UIImage(named: image3)!]
    
    let logoImageView = UIImageView(image: UIImage(named: image1))
    
    var logoHorizontalConstraint: NSLayoutConstraint?
    
    var result: RMRPullToRefreshResultType?
    
    var isConfigured: Bool = false
    var didRotateToTop: Bool = false
    var didRotateToBottom: Bool = false
    var animating: Bool = true
    
    init(result: RMRPullToRefreshResultType) {
        self.result = result
        super.init(frame: CGRect.zero)
        addSubview(logoImageView)
        configureConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private
    
    func configureConstraints() {
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        let heightConstraint = NSLayoutConstraint(item: logoImageView,
                                                  attribute: NSLayoutAttribute.height,
                                                  relatedBy: NSLayoutRelation.equal,
                                                  toItem: nil,
                                                  attribute: NSLayoutAttribute.notAnAttribute,
                                                  multiplier: 1,
                                                  constant: 50)
        
        let widthConstraint = NSLayoutConstraint(item: logoImageView,
                                                 attribute: NSLayoutAttribute.width,
                                                 relatedBy: NSLayoutRelation.equal,
                                                 toItem: nil,
                                                 attribute: NSLayoutAttribute.notAnAttribute,
                                                 multiplier: 1,
                                                 constant: 50)
        
        logoImageView.addConstraints([heightConstraint, widthConstraint])
        
        let verticalConstraint = NSLayoutConstraint(item: logoImageView,
                                                    attribute: .centerY,
                                                    relatedBy: NSLayoutRelation.equal,
                                                    toItem: self,
                                                    attribute: .centerY,
                                                    multiplier: 1,
                                                    constant: 0)
        
        let horizontalConstraint = NSLayoutConstraint(item: logoImageView,
                                                      attribute: .centerX,
                                                      relatedBy: NSLayoutRelation.equal,
                                                      toItem: self,
                                                      attribute: .centerX,
                                                      multiplier: 1,
                                                      constant: 0)
        
        addConstraints([verticalConstraint, horizontalConstraint])
        
        logoHorizontalConstraint = horizontalConstraint
    }
    
    func resetTransformIfNecessary() {
        if !isConfigured {
            logoImageView.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI))
            didRotateToBottom = true
            isConfigured = true
        }
    }
    
    func makeIncreasePulling(_ animated: Bool) {
        didRotateToTop = true
        didRotateToBottom = false
        let rotateTransform = logoImageView.transform.rotated(by: CGFloat(M_PI));
        if animated {
            UIView .animate(withDuration: 0.4, animations: { [weak self] in
                self?.logoImageView.transform = rotateTransform
            })
        } else {
            self.logoImageView.transform = rotateTransform
        }
    }
    
    func makeDecreasePulling(_ animated: Bool) {
        didRotateToBottom = true
        didRotateToTop = false
        let rotateTransform = logoImageView.transform.rotated(by: -CGFloat(M_PI));
        if animated {
            UIView .animate(withDuration: 0.4, animations: { [weak self] in
                self?.logoImageView.transform = rotateTransform
            })
        } else {
            self.logoImageView.transform = rotateTransform
        }
    }
    
    // MARK: - RMRPullToRefreshViewProtocol
    
    override func didChangeDraggingProgress(_ progress: CGFloat) {
        
        resetTransformIfNecessary()
        
        if progress >= 1.0 && !didRotateToTop && didRotateToBottom {
            makeIncreasePulling(animating)
            if !animating {
                animating = true
            }
        } else if progress < 1.0 && !didRotateToBottom && didRotateToTop{
            makeDecreasePulling(true)
        }
    }
    
    override func prepareForLoadingAnimation(_ startProgress: CGFloat) {
        if logoImageView.animationImages == nil {
            logoImageView.animationImages = images
            logoImageView.animationDuration = 0.8
            logoImageView.animationRepeatCount = 0
        }
    }
    
    override func beginLoadingAnimation() {
        logoImageView.startAnimating()
    }
    
    override func didEndLoadingAnimation(_ hidden: Bool) {
        logoImageView.stopAnimating()
        logoImageView.layer.removeAllAnimations()
        didRotateToTop = false
        isConfigured = !hidden
        animating = hidden
    }
}
