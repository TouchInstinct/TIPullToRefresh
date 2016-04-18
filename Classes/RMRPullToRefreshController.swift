//
//  RMRPullToRefreshController.swift
//  RMRPullToRefresh
//
//  Created by Merkulov Ilya on 19.03.16.
//  Copyright © 2016 Merkulov Ilya. All rights reserved.
//

import UIKit

public class RMRPullToRefreshController: NSObject {

    // MARK: - Vars
    
    weak var scrollView: UIScrollView?
    
    let containerView = RMRPullToRefreshContainerView()
    
    let backgroundView = UIView(frame: CGRectZero)
    var backgroundViewHeightConstraint: NSLayoutConstraint?
    var backgroundViewTopConstraint: NSLayoutConstraint?
    
    var stopped = true
    var subscribing = false
    
    var actionHandler: (() -> Void)!
    
    var height = CGFloat(0.0)
    var originalTopInset = CGFloat(0.0)
    var originalBottomInset = CGFloat(0.0)
    
    var state = RMRPullToRefreshState.Stopped
    var result = RMRPullToRefreshResultType.Success
    var position: RMRPullToRefreshPosition?
    
    var changingContentInset = false
    var contentSizeWhenStartLoading: CGSize?
    
    var hideDelayValues = [RMRPullToRefreshResultType: NSTimeInterval]()
    
    public var hideWhenError: Bool = true
    
    // MARK: - Init
    
    init(scrollView: UIScrollView, position:RMRPullToRefreshPosition, actionHandler: () -> Void) {

        super.init()        
        self.scrollView = scrollView
        self.actionHandler = actionHandler
        self.position = position
        
        self.configureBackgroundView(self.backgroundView)
        self.configureHeight()
        
        self.containerView.backgroundColor = UIColor.clearColor()
        
        self.subscribeOnScrollViewEvents()
    }
    
    deinit {
        self.unsubscribeFromScrollViewEvents()
    }
    
    private func configureBackgroundView(backgroundView: UIView) {
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        scrollView?.addSubview(backgroundView)
        addBackgroundViewConstraints(backgroundView)
    }
    
    private func addBackgroundViewConstraints(backgroundView: UIView) {
        // Constraints
        self.backgroundViewHeightConstraint = NSLayoutConstraint(item: backgroundView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 0)
        backgroundView.addConstraint(self.backgroundViewHeightConstraint!)
        
        scrollView?.addConstraint(NSLayoutConstraint(item: backgroundView, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: scrollView, attribute: NSLayoutAttribute.Width, multiplier: 1, constant: 0))
        
        if position == .Top {
            scrollView?.addConstraint(NSLayoutConstraint(item: backgroundView, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: scrollView, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 0))
        } else if position == .Bottom, let scrollView = self.scrollView {
            let constant = max(scrollView.contentSize.height, CGRectGetHeight(scrollView.bounds))
            self.backgroundViewTopConstraint = NSLayoutConstraint(item: backgroundView, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: scrollView, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: constant)
            scrollView.addConstraint(self.backgroundViewTopConstraint!)
        }
    }
    
    private func configureHeight() {
        
        if let scrollView = self.scrollView {
            self.originalTopInset = scrollView.contentInset.top
            self.originalBottomInset = scrollView.contentInset.bottom
        }
        configureHeight(RMRPullToRefreshConstants.DefaultHeight)
    }
    
    // MARK: - Public
    
    public func configureView(view:RMRPullToRefreshView, result:RMRPullToRefreshResultType) {
        configureView(view, state: .Loading, result: result)
        configureView(view, state: .Dragging, result: result)
        configureView(view, state: .Stopped, result: result)
    }
    
    public func configureView(view:RMRPullToRefreshView, state:RMRPullToRefreshState, result:RMRPullToRefreshResultType) {
        containerView.configureView(view, state: state, result: result)
    }
    
    public func configureHeight(height: CGFloat) {
        self.height = height
        updateContainerFrame()
    }
    
    public func configureBackgroundColor(color: UIColor) {
        self.backgroundView.backgroundColor = color
    }
    
    public func setupDefaultSettings() {
        setupDefaultSettings(.Success, hideDelay: 0.0)
        setupDefaultSettings(.NoUpdates, hideDelay: 2.0)
        setupDefaultSettings(.Error, hideDelay: 2.0)
        configureBackgroundColor(UIColor.whiteColor())
        updateContainerView(self.state)
    }
    
    public func startLoading() {
        startLoading(0.0)
    }
    
    public func stopLoading(result:RMRPullToRefreshResultType) {
        
        self.result = result
        self.state = .Stopped
        updateContainerView(self.state)
        containerView.prepareForStopAnimations()
        
        var delay = hideDelay(result)
        var afterDelay = 0.4
        
        if result == .Error && !hideWhenError {
            delay = 0.0
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), { [weak self] in
            if self?.shouldHideWhenStopLoading() == true {
                self?.resetContentInset()
                if let position = self?.position {
                    switch (position) {
                        case .Top:
                            self?.scrollToTop(true)
                        case .Bottom:
                            self?.scrollToBottom(true)
                    }
                }
                self?.contentSizeWhenStartLoading = nil
                self?.performSelector(#selector(self?.resetBackgroundViewHeightConstraint), withObject: nil, afterDelay: afterDelay)
            }
            self?.performSelector(#selector(self?.stopAllAnimations), withObject: nil, afterDelay: afterDelay)
        })
    }
    
    public func setHideDelay(delay: NSTimeInterval, result: RMRPullToRefreshResultType) {
        self.hideDelayValues[result] = delay
    }
    
    // MARK: - Private
    
    func setupDefaultSettings(result:RMRPullToRefreshResultType, hideDelay: NSTimeInterval) {
        if let view = RMRPullToRefreshViewFactory.create(result) {
            configureView(view, result: result)
            setHideDelay(hideDelay, result: result)
        }
    }
    
    func scrollToTop(animated: Bool) {
        if let scrollView = self.scrollView {
            if scrollView.contentOffset.y < -originalTopInset {
                let offset = CGPointMake(scrollView.contentOffset.x, -self.originalTopInset)
                scrollView.setContentOffset(offset, animated: true)
            }
        }
    }
    
    func scrollToBottom(animated: Bool) {
        if let scrollView = self.scrollView {
            var offset = scrollView.contentOffset
            if let contentSize = self.contentSizeWhenStartLoading {
                offset.y = contentSize.height - CGRectGetHeight(scrollView.bounds) + scrollView.contentInset.bottom
                if state == .Stopped {
                    if scrollView.contentOffset.y < offset.y {
                        return
                    } else if scrollView.contentOffset.y > offset.y {
                        offset.y += height
                    }
                }
            } else {
                offset.y = scrollView.contentSize.height - CGRectGetHeight(scrollView.bounds) + scrollView.contentInset.bottom
            }
            scrollView.setContentOffset(offset, animated: animated)
        }
    }
    
    func startLoading(startProgress: CGFloat) {
        stopped = false
        contentSizeWhenStartLoading = scrollView?.contentSize
        state = .Loading
        updateContainerView(state)
        actionHandler()
        
        containerView.startLoadingAnimation(startProgress)
    }
    
    @objc private func stopAllAnimations() {
        if shouldHideWhenStopLoading() {
            stopped = true
        }
        containerView.stopAllAnimations(shouldHideWhenStopLoading())
    }
    
    @objc private func forceStopAllAnimations() {
        stopped = true
        containerView.stopAllAnimations(true)
    }
    
    @objc private func resetBackgroundViewHeightConstraint() {
        backgroundViewHeightConstraint?.constant = 0
    }
    
    private func scrollViewDidChangePanState(scrollView: UIScrollView, panState: UIGestureRecognizerState) {
        if panState == .Ended || panState == .Cancelled || panState == .Failed {
            
            if state == .Loading || (shouldHideWhenStopLoading() && !stopped) {
                return
            }
            
            var y: CGFloat = 0.0
            if position == .Top {
                y = -scrollView.contentOffset.y
            } else if position == .Bottom {
                y = -(scrollView.contentSize.height - (scrollView.contentOffset.y + CGRectGetHeight(scrollView.bounds) + originalBottomInset));
            }
            
            if y >= height {
                startLoading(y/height)
                // inset
                var inset = scrollView.contentInset
                if position == .Top {
                    inset.top = originalTopInset+height
                } else if position == .Bottom {
                    inset.bottom = originalBottomInset+height
                }
                setContentInset(inset, animated: true)
            } else {
                state = .Stopped
                updateContainerView(state)
            }
        }
    }
    
    private func scrollViewDidChangeContentSize(scrollView: UIScrollView, contentSize: CGSize) {
        updateContainerFrame()
        if position == .Bottom {
            self.backgroundViewTopConstraint?.constant = max(scrollView.contentSize.height, CGRectGetHeight(scrollView.bounds))
            if changingContentInset {
                scrollToBottom(true)
            }
        }
    }
    
    private func scrollViewDidScroll(scrollView: UIScrollView, contentOffset: CGPoint) {
        if !stopped {
            return
        }
        if scrollView.dragging && state == .Stopped {
            state = .Dragging
            updateContainerView(state)
        }        
        var y: CGFloat = 0.0
        
        if position == .Top {
            y = -(contentOffset.y)
        } else if position == .Bottom {
            y = -(scrollView.contentSize.height - (contentOffset.y + CGRectGetHeight(scrollView.bounds) + originalBottomInset))
        }
        if y > 0 {
            if state == .Dragging {
                containerView.dragging(y/height)
            }
            configureBackgroundHeightConstraint(y, contentInset: scrollView.contentInset)
        }
    }
    
    private func configureBackgroundHeightConstraint(contentOffsetY: CGFloat, contentInset: UIEdgeInsets) {
        var constant = CGFloat(-1.0)
        if position == .Top {
            constant = contentOffsetY + contentInset.top
        } else {
            constant = contentOffsetY + contentInset.bottom
        }
        if constant > 0 && constant > backgroundViewHeightConstraint?.constant {
            backgroundViewHeightConstraint?.constant = constant
        }
    }
    
    func updateContainerView(state: RMRPullToRefreshState) {
        containerView.updateView(state, result: self.result)
    }
    
    func updateContainerFrame() {
        if let scrollView = self.scrollView, let position = self.position {
            var frame = CGRectZero
            switch (position) {
            case .Top:
                frame = CGRectMake(0, -height, CGRectGetWidth(scrollView.bounds), height)
            case .Bottom:
                let y = max(scrollView.contentSize.height, CGRectGetHeight(scrollView.bounds))
                frame = CGRectMake(0, y, CGRectGetWidth(scrollView.bounds), height)
            }
            
            self.containerView.frame = frame
        }
    }
    
    func resetContentInset() {
        if let scrollView = scrollView, let position = self.position {
            var inset = scrollView.contentInset
            switch (position) {
                case .Top:
                    inset.top = originalTopInset
                case .Bottom:
                    inset.bottom = originalBottomInset
            }
            setContentInset(inset, animated: true)
        }
    }
    
    func setContentInset(contentInset: UIEdgeInsets, animated: Bool) {
        changingContentInset = true
        UIView.animateWithDuration(0.3,
            delay: 0.0,
            options: UIViewAnimationOptions.BeginFromCurrentState,
            animations: {  [weak self]() -> Void in
                self?.scrollView?.contentInset = contentInset
            }, completion: {  [weak self](finished) -> Void in
                self?.changingContentInset = false
        })
    }
    
    func checkContentSize(scrollView: UIScrollView) -> Bool{
        let height = CGRectGetHeight(scrollView.bounds)
        if scrollView.contentSize.height < height {
            scrollView.contentSize = CGSizeMake(scrollView.contentSize.width, height)
            return false
        }
        return true
    }
    
    func shouldHideWhenStopLoading() -> Bool{
        return (result != .Error) || (result == .Error && hideWhenError)
    }
    
    func hideDelay(result: RMRPullToRefreshResultType) -> NSTimeInterval {
        if let delay = hideDelayValues[result] {
            return delay
        }
        return 0.0
    }
    
    // MARK: - KVO

    public func subscribeOnScrollViewEvents() {
        if !subscribing, let scrollView = self.scrollView {
            scrollView.addObserver(self, forKeyPath: RMRPullToRefreshConstants.KeyPaths.ContentOffset, options: .New, context: nil)
            scrollView.addObserver(self, forKeyPath: RMRPullToRefreshConstants.KeyPaths.ContentSize, options: .New, context: nil)
            scrollView.addObserver(self, forKeyPath: RMRPullToRefreshConstants.KeyPaths.PanState, options: .New, context: nil)
            subscribing = true
        }
    }
    
    public func unsubscribeFromScrollViewEvents() {
        if subscribing, let scrollView = self.containerView.superview {
            scrollView.removeObserver(self, forKeyPath: RMRPullToRefreshConstants.KeyPaths.ContentOffset)
            scrollView.removeObserver(self, forKeyPath: RMRPullToRefreshConstants.KeyPaths.ContentSize)
            scrollView.removeObserver(self, forKeyPath: RMRPullToRefreshConstants.KeyPaths.PanState)
            subscribing = false
        }
    }
    
    override public func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if keyPath == RMRPullToRefreshConstants.KeyPaths.ContentOffset {
            if let newContentOffset = change?[NSKeyValueChangeNewKey]?.CGPointValue, scrollView = self.scrollView {
                scrollViewDidScroll(scrollView, contentOffset:newContentOffset)
            }
        } else if keyPath == RMRPullToRefreshConstants.KeyPaths.ContentSize {
            if let newContentSize = change?[NSKeyValueChangeNewKey]?.CGSizeValue(), scrollView = self.scrollView {
                if checkContentSize(scrollView) {
                    scrollViewDidChangeContentSize(scrollView, contentSize: newContentSize)
                }
            }
        } else if keyPath == RMRPullToRefreshConstants.KeyPaths.PanState {
            if let rawValue = change?[NSKeyValueChangeNewKey] as? Int {
                if let state = UIGestureRecognizerState(rawValue: rawValue), scrollView = self.scrollView {
                    scrollViewDidChangePanState(scrollView, panState: state)
                }
            }
        }
    }
    
}