//
//  RMRPullToRefreshController.swift
//  RMRPullToRefresh
//
//  Created by Merkulov Ilya on 19.03.16.
//  Copyright © 2016 Merkulov Ilya. All rights reserved.
//

import UIKit
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


open class RMRPullToRefreshController {

    // MARK: - Vars
    
    weak var scrollView: UIScrollView?
    
    let containerView = RMRPullToRefreshContainerView()
    
    let backgroundView = UIView(frame: CGRect.zero)
    var backgroundViewHeightConstraint: NSLayoutConstraint?
    var backgroundViewTopConstraint: NSLayoutConstraint?
    
    var stopped = true
    var subscribing = false
    
    var actionHandler: (() -> Void)!
    
    var height = CGFloat(0.0)
    var originalTopInset = CGFloat(0.0)
    var originalBottomInset = CGFloat(0.0)
    
    var state = RMRPullToRefreshState.stopped
    var result = RMRPullToRefreshResultType.success
    var position: RMRPullToRefreshPosition?
    
    var changingContentInset = false
    var contentSizeWhenStartLoading: CGSize?
    
    var hideDelayValues = [RMRPullToRefreshResultType: TimeInterval]()
    
    open var hideWhenError: Bool = true
    
    // MARK: - Init
    
    init(scrollView: UIScrollView, position:RMRPullToRefreshPosition, actionHandler: @escaping () -> Void) {
 
        self.scrollView = scrollView
        self.actionHandler = actionHandler
        self.position = position
        
        self.configureBackgroundView(self.backgroundView)
        self.configureHeight()
        
        self.containerView.backgroundColor = UIColor.clear
        
        self.subscribeOnScrollViewEvents()
    }
    
    fileprivate func configureBackgroundView(_ backgroundView: UIView) {
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        scrollView?.addSubview(backgroundView)
        addBackgroundViewConstraints(backgroundView)
    }
    
    fileprivate func addBackgroundViewConstraints(_ backgroundView: UIView) {
        // Constraints
        self.backgroundViewHeightConstraint = NSLayoutConstraint(item: backgroundView, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 0)
        backgroundView.addConstraint(self.backgroundViewHeightConstraint!)
        
        scrollView?.addConstraint(NSLayoutConstraint(item: backgroundView, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: scrollView, attribute: NSLayoutConstraint.Attribute.width, multiplier: 1, constant: 0))
        
        if position == .top {
            scrollView?.addConstraint(NSLayoutConstraint(item: backgroundView, attribute: NSLayoutConstraint.Attribute.bottom, relatedBy: NSLayoutConstraint.Relation.equal, toItem: scrollView, attribute: NSLayoutConstraint.Attribute.top, multiplier: 1, constant: 0))
        } else if position == .bottom, let scrollView = self.scrollView {
            let constant = max(scrollView.contentSize.height, scrollView.bounds.height)
            self.backgroundViewTopConstraint = NSLayoutConstraint(item: backgroundView, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: scrollView, attribute: NSLayoutConstraint.Attribute.top, multiplier: 1, constant: constant)
            scrollView.addConstraint(self.backgroundViewTopConstraint!)
        }
    }
    
    fileprivate func configureHeight() {
        
        if let scrollView = self.scrollView {
            self.originalTopInset = scrollView.contentInset.top
            self.originalBottomInset = scrollView.contentInset.bottom
        }
        configureHeight(RMRPullToRefreshConstants.DefaultHeight)
    }
    
    // MARK: - Public
    
    open func configureView(_ view:RMRPullToRefreshView, result:RMRPullToRefreshResultType) {
        configureView(view, state: .loading, result: result)
        configureView(view, state: .dragging, result: result)
        configureView(view, state: .stopped, result: result)
    }
    
    open func configureView(_ view:RMRPullToRefreshView, state:RMRPullToRefreshState, result:RMRPullToRefreshResultType) {
        containerView.configureView(view, state: state, result: result)
    }
    
    open func configureHeight(_ height: CGFloat) {
        self.height = height
        updateContainerFrame()
    }
    
    open func configureBackgroundColor(_ color: UIColor) {
        self.backgroundView.backgroundColor = color
    }
    
    open func setupDefaultSettings() {
        setupDefaultSettings(.success, hideDelay: 0.0)
        setupDefaultSettings(.noUpdates, hideDelay: 2.0)
        setupDefaultSettings(.error, hideDelay: 2.0)
        configureBackgroundColor(UIColor.white)
        updateContainerView(self.state)
    }
    
    open func startLoading() {
        startLoading(0.0)
    }
    
    open func stopLoading(_ result:RMRPullToRefreshResultType) {
        
        self.result = result
        self.state = .stopped
        updateContainerView(self.state)
        containerView.prepareForStopAnimations()
        
        var delay = hideDelay(result)
        let afterDelay = 0.4
        
        if result == .error && !hideWhenError {
            delay = 0.0
        }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: { [weak self] in
            if self?.shouldHideWhenStopLoading() == true {
                self?.resetContentInset()
                if let position = self?.position {
                    switch (position) {
                        case .top:
                            self?.scrollToTop(true)
                        case .bottom:
                            self?.scrollToBottom(true)
                    }
                }
                self?.contentSizeWhenStartLoading = nil
                
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + afterDelay) {
                    self?.resetBackgroundViewHeightConstraint()
                }
            }
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + afterDelay) {
                self?.stopAllAnimations()
            }
        })
    }
    
    open func setHideDelay(_ delay: TimeInterval, result: RMRPullToRefreshResultType) {
        self.hideDelayValues[result] = delay
    }
    
    // MARK: - Private
    
    func setupDefaultSettings(_ result:RMRPullToRefreshResultType, hideDelay: TimeInterval) {
        if let view = RMRPullToRefreshViewFactory.create(result) {
            configureView(view, result: result)
            setHideDelay(hideDelay, result: result)
        }
    }
    
    func scrollToTop(_ animated: Bool) {
        if let scrollView = self.scrollView {
            if scrollView.contentOffset.y < -originalTopInset {
                let offset = CGPoint(x: scrollView.contentOffset.x, y: -self.originalTopInset)
                scrollView.setContentOffset(offset, animated: true)
            }
        }
    }
    
    func scrollToBottom(_ animated: Bool) {
        if let scrollView = self.scrollView {
            var offset = scrollView.contentOffset
            if let contentSize = self.contentSizeWhenStartLoading {
                offset.y = contentSize.height - scrollView.bounds.height + scrollView.contentInset.bottom
                if state == .stopped {
                    if scrollView.contentOffset.y < offset.y {
                        return
                    } else if scrollView.contentOffset.y > offset.y {
                        offset.y += height
                    }
                }
            } else {
                offset.y = scrollView.contentSize.height - scrollView.bounds.height + scrollView.contentInset.bottom
            }
            scrollView.setContentOffset(offset, animated: animated)
        }
    }
    
    func startLoading(_ startProgress: CGFloat) {
        stopped = false
        contentSizeWhenStartLoading = scrollView?.contentSize
        state = .loading
        updateContainerView(state)
        actionHandler()
        
        containerView.startLoadingAnimation(startProgress)
    }
    
    @objc fileprivate func stopAllAnimations() {
        if shouldHideWhenStopLoading() {
            stopped = true
        }
        containerView.stopAllAnimations(shouldHideWhenStopLoading())
    }
    
    @objc fileprivate func forceStopAllAnimations() {
        stopped = true
        containerView.stopAllAnimations(true)
    }
    
    @objc fileprivate func resetBackgroundViewHeightConstraint() {
        backgroundViewHeightConstraint?.constant = 0
    }
    
    fileprivate func scrollViewDidChangePanState(_ scrollView: UIScrollView, panState: UIGestureRecognizer.State) {
        if panState == .ended || panState == .cancelled || panState == .failed {
            
            if state == .loading || (shouldHideWhenStopLoading() && !stopped) {
                return
            }
            
            var y: CGFloat = 0.0
            if position == .top {
                y = -scrollView.contentOffset.y
            } else if position == .bottom {
                y = -(scrollView.contentSize.height - (scrollView.contentOffset.y + scrollView.bounds.height + originalBottomInset));
            }
            
            if y >= height {
                startLoading(y/height)
                // inset
                var inset = scrollView.contentInset
                if position == .top {
                    inset.top = originalTopInset+height
                } else if position == .bottom {
                    inset.bottom = originalBottomInset+height
                }
                setContentInset(inset, animated: true)
            } else {
                state = .stopped
                updateContainerView(state)
            }
        }
    }
    
    fileprivate func scrollViewDidChangeContentSize(_ scrollView: UIScrollView, contentSize: CGSize) {
        updateContainerFrame()
        if position == .bottom {
            self.backgroundViewTopConstraint?.constant = max(scrollView.contentSize.height, scrollView.bounds.height)
            if changingContentInset {
                scrollToBottom(true)
            }
        }
    }
    
    fileprivate func scrollViewDidScroll(_ scrollView: UIScrollView, contentOffset: CGPoint) {
        
        if state == .loading {
            if scrollView.contentOffset.y >= 0  {
                scrollView.contentInset = UIEdgeInsets.zero
            } else {
                scrollView.contentInset = UIEdgeInsets.init(top: min(-scrollView.contentOffset.y, originalTopInset+height),left: 0,bottom: 0,right: 0)
            }
        }
        
        if !stopped {
            return
        }
        if scrollView.isDragging && state == .stopped {
            state = .dragging
            updateContainerView(state)
        }        
        var y: CGFloat = 0.0
        
        if position == .top {
            y = -(contentOffset.y)
        } else if position == .bottom {
            y = -(scrollView.contentSize.height - (contentOffset.y + scrollView.bounds.height + originalBottomInset))
        }
        if y > 0 {
            if state == .dragging {
                containerView.dragging(y/height)
            }
            configureBackgroundHeightConstraint(y, contentInset: scrollView.contentInset)
        }
    }
    
    fileprivate func configureBackgroundHeightConstraint(_ contentOffsetY: CGFloat, contentInset: UIEdgeInsets) {
        var constant = CGFloat(-1.0)
        if position == .top {
            constant = contentOffsetY + contentInset.top
        } else {
            constant = contentOffsetY + contentInset.bottom
        }
        if constant > 0 && constant > backgroundViewHeightConstraint?.constant {
            backgroundViewHeightConstraint?.constant = constant
        }
    }
    
    func updateContainerView(_ state: RMRPullToRefreshState) {
        containerView.updateView(state, result: self.result)
    }
    
    func updateContainerFrame() {
        if let scrollView = self.scrollView, let position = self.position {
            var frame = CGRect.zero
            switch (position) {
            case .top:
                frame = CGRect(x: 0, y: -height, width: scrollView.bounds.width, height: height)
            case .bottom:
                let y = max(scrollView.contentSize.height, scrollView.bounds.height)
                frame = CGRect(x: 0, y: y, width: scrollView.bounds.width, height: height)
            }
            
            self.containerView.frame = frame
        }
    }
    
    func resetContentInset() {
        if let scrollView = scrollView, let position = self.position {
            var inset = scrollView.contentInset
            switch (position) {
                case .top:
                    inset.top = originalTopInset
                case .bottom:
                    inset.bottom = originalBottomInset
            }
            setContentInset(inset, animated: true)
        }
    }
    
    func setContentInset(_ contentInset: UIEdgeInsets, animated: Bool) {
        changingContentInset = true
        UIView.animate(withDuration: 0.3,
            delay: 0.0,
            options: UIView.AnimationOptions.beginFromCurrentState,
            animations: {  [weak self]() -> Void in
                self?.scrollView?.contentInset = contentInset
            }, completion: {  [weak self](finished) -> Void in
                self?.changingContentInset = false
        })
    }
    
    func checkContentSize(_ scrollView: UIScrollView) -> Bool{
        let height = scrollView.bounds.height
        if scrollView.contentSize.height < height {
            scrollView.contentSize = CGSize(width: scrollView.contentSize.width, height: height)
            return false
        }
        return true
    }
    
    func shouldHideWhenStopLoading() -> Bool{
        return (result != .error) || (result == .error && hideWhenError)
    }
    
    func hideDelay(_ result: RMRPullToRefreshResultType) -> TimeInterval {
        if let delay = hideDelayValues[result] {
            return delay
        }
        return 0.0
    }
    
    // MARK: - KVO
    
    var contentOffsetObservation: NSKeyValueObservation?
    var contentSizeObservation: NSKeyValueObservation?

    open func subscribeOnScrollViewEvents() {
        guard let scrollView = self.scrollView else { return }
        
        contentOffsetObservation = scrollView.observe(\.contentOffset, options: .new) { [weak self] scrollView, changes in
            guard let newContentOffset = changes.newValue else { return }
            self?.scrollViewDidScroll(scrollView, contentOffset: newContentOffset)
        }
        
        contentSizeObservation = scrollView.observe(\.contentSize, options: .new) { [weak self] scrollView, changes in
            guard let newContentSize = changes.newValue else { return }
            self?.scrollViewDidChangeContentSize(scrollView, contentSize: newContentSize)
        }
        
        self.scrollView?.panGestureRecognizer.addTarget(self, action: #selector(onPanGesture))
    }
    
    @objc func onPanGesture(gesture: UIPanGestureRecognizer) {
        guard let scrollView = self.scrollView else { return }
        scrollViewDidChangePanState(scrollView, panState: gesture.state)
    }
    
    open func unsubscribeFromScrollViewEvents() {
        contentOffsetObservation = nil
        contentSizeObservation = nil
    }
    
}
