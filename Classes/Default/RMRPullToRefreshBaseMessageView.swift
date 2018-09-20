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
        label.textColor = UIColor.white
        label.textAlignment = .center
        label.text = messageText()
        messageView.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        for attribute in [NSLayoutConstraint.Attribute.top, NSLayoutConstraint.Attribute.right, NSLayoutConstraint.Attribute.left, NSLayoutConstraint.Attribute.bottom] {
            messageView.addConstraint(NSLayoutConstraint(item: label,
                                                    attribute: attribute,
                                                    relatedBy: NSLayoutConstraint.Relation.equal,
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
                                                  attribute: NSLayoutConstraint.Attribute.height,
                                                  relatedBy: NSLayoutConstraint.Relation.equal,
                                                  toItem: nil,
                                                  attribute: NSLayoutConstraint.Attribute.notAnAttribute,
                                                  multiplier: 1,
                                                  constant: 30)
        
        let widthConstraint = NSLayoutConstraint(item: messageView,
                                                 attribute: NSLayoutConstraint.Attribute.width,
                                                 relatedBy: NSLayoutConstraint.Relation.equal,
                                                 toItem: nil,
                                                 attribute: NSLayoutConstraint.Attribute.notAnAttribute,
                                                 multiplier: 1,
                                                 constant: 150)
        
        messageView.addConstraints([heightConstraint, widthConstraint])
        
        let verticalConstraint = NSLayoutConstraint(item: messageView,
                                                    attribute: .centerY,
                                                    relatedBy: NSLayoutConstraint.Relation.equal,
                                                    toItem: self,
                                                    attribute: .centerY,
                                                    multiplier: 1,
                                                    constant: 0)
        
        let leftConstraint = NSLayoutConstraint(item: messageView,
                                                attribute: .left,
                                                relatedBy: NSLayoutConstraint.Relation.equal,
                                                toItem: self,
                                                attribute: .right,
                                                multiplier: 1,
                                                constant: 0)
        
        addConstraints([verticalConstraint, leftConstraint])
        
        messageViewLeftConstaint = leftConstraint
    }
    
    func messageBackgroundColor() -> UIColor {
        return UIColor.white
    }
    
    func messageText() -> String? {
        return nil
    }
    
    // MARK: - RMRPullToRefreshViewProtocol
    
    override func beginLoadingAnimation() {
        super.beginLoadingAnimation()
        if self.logoHorizontalConstraint?.constant != 0.0 {
            self.logoHorizontalConstraint?.constant = 0.0
        }
        if self.messageViewLeftConstaint?.constant != 0.0 {
            self.messageViewLeftConstaint?.constant = 0.0
        }
        UIView.animate(withDuration: 0.4, animations: {[weak self] in
            self?.layoutIfNeeded()
        })         
    }
    
    override func willEndLoadingAnimation() {
        self.logoHorizontalConstraint?.constant = -self.bounds.width/2.0 + self.logoImageView.bounds.width
        self.messageViewLeftConstaint?.constant = -messageView.bounds.width - 10.0
        UIView.animate(withDuration: 0.4, animations: {[weak self] in
            self?.layoutIfNeeded()
        }) 
    }
    
    override func didEndLoadingAnimation(_ hidden: Bool) {
        super.didEndLoadingAnimation(hidden)
        if hidden {
            self.logoHorizontalConstraint?.constant = 0.0
            self.messageViewLeftConstaint?.constant = 0.0
        }
    }
}
