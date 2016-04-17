//
//  RMRPullToRefreshBaseMessageView.swift
//  RMRPullToRefreshExample
//
//  Created by Merkulov Ilya on 17.04.16.
//  Copyright © 2016 Merkulov Ilya. All rights reserved.
//

import UIKit

class RMRPullToRefreshBaseMessageView: RMRPullToRefreshBaseView {
    
    var messageView = UIView(frame: CGRect.zero)
    var messageViewLeftConstaint: NSLayoutConstraint?
    
    // MARK: - Init
    
    override init(result: RMRPullToRefreshResultType) {
        super.init(result: result)
        configure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private
    
    func configure() {
        configureMessageView()
        configureLabel()
    }
    
    func configureLabel() {
        let label = UILabel(frame: self.messageView.bounds)
        label.textColor = UIColor.whiteColor()
        label.textAlignment = .Center
        label.text = messageText()
        messageView.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        for attribute in [NSLayoutAttribute.Top, NSLayoutAttribute.Right, NSLayoutAttribute.Left, NSLayoutAttribute.Bottom] {
            messageView.addConstraint(NSLayoutConstraint(item: label,
                                                    attribute: attribute,
                                                    relatedBy: NSLayoutRelation.Equal,
                                                       toItem: messageView,
                                                    attribute: attribute,
                                                   multiplier: 1,
                                                     constant: 0))
        }
    }
    
    func configureMessageView() {
        messageView.backgroundColor = messageBackgroundColor()                                        
        messageView.layer.cornerRadius = 5.0
        messageView.clipsToBounds = true
        addSubview(messageView)
        messageView.translatesAutoresizingMaskIntoConstraints = false
        
        let heightConstraint = NSLayoutConstraint(item: messageView,
                                                  attribute: NSLayoutAttribute.Height,
                                                  relatedBy: NSLayoutRelation.Equal,
                                                  toItem: nil,
                                                  attribute: NSLayoutAttribute.NotAnAttribute,
                                                  multiplier: 1,
                                                  constant: 30)
        
        let widthConstraint = NSLayoutConstraint(item: messageView,
                                                 attribute: NSLayoutAttribute.Width,
                                                 relatedBy: NSLayoutRelation.Equal,
                                                 toItem: nil,
                                                 attribute: NSLayoutAttribute.NotAnAttribute,
                                                 multiplier: 1,
                                                 constant: 150)
        
        messageView.addConstraints([heightConstraint, widthConstraint])
        
        let verticalConstraint = NSLayoutConstraint(item: messageView,
                                                    attribute: .CenterY,
                                                    relatedBy: NSLayoutRelation.Equal,
                                                    toItem: self,
                                                    attribute: .CenterY,
                                                    multiplier: 1,
                                                    constant: 0)
        
        let leftConstraint = NSLayoutConstraint(item: messageView,
                                                attribute: .Left,
                                                relatedBy: NSLayoutRelation.Equal,
                                                toItem: self,
                                                attribute: .Right,
                                                multiplier: 1,
                                                constant: 0)
        
        addConstraints([verticalConstraint, leftConstraint])
        
        messageViewLeftConstaint = leftConstraint
    }
    
    func messageBackgroundColor() -> UIColor {
        return UIColor.whiteColor()
    }
    
    func messageText() -> String? {
        return nil
    }
    
    // MARK: - RMRPullToRefreshViewProtocol
    
    override func willEndLoadingAnimation() {
        self.logoHorizontalConstraint?.constant = -CGRectGetWidth(self.bounds)/2.0 + CGRectGetWidth(self.logoImageView.bounds)
        self.messageViewLeftConstaint?.constant = -CGRectGetWidth(messageView.bounds) - 10.0
        UIView.animateWithDuration(0.4) {[weak self] in
            self?.layoutIfNeeded()
        }
    }
    
    override func didEndLoadingAnimation(hidden: Bool) {
        super.didEndLoadingAnimation(hidden)
        if hidden {
            self.logoHorizontalConstraint?.constant = 0.0
            self.messageViewLeftConstaint?.constant = 0.0
        }
    }
}
