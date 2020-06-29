//
//  PullToRefreshView.swift
//  BushelRefresh
//
//  Created by Alex (Work) on 6/18/20.
//

import UIKit

//NOTE: This is a top PTR view. Creating a bottom PTR will require subclassing or creating a new view.

public protocol PullToRefreshView: UIView {
    //Copied from SVPTR
    var scrollView: UIScrollView! { get set }
    var originalTopInset: CGFloat? { get set }
    var originalBottomInset: CGFloat? { get set }
    
    func registerObservers()
    func setupConstraints()
    
    //State
    var state: RefreshState { get set }
    var refreshAction: RefreshAction { get set }
    
    //Actions
    func trigger()
    func startAnimating()
    func stopAnimating()
}

//Default Implementation
class DefaultPullToRefreshView: UIView, PullToRefreshView {
    
    var scrollView: UIScrollView!
    var originalTopInset: CGFloat?
    var originalBottomInset: CGFloat?
    
    var contentOffsetObserver: NSKeyValueObservation?
    
    func registerObservers() {
        contentOffsetObserver = scrollView?.observe(\.contentOffset) { [weak self] (scrollView, change) in
            guard self?.isHidden == false else { return }
            self?.scrollViewDidScroll(contentOffset: scrollView.contentOffset)
        }
    }
    
    func setupConstraints() {
        translatesAutoresizingMaskIntoConstraints = false
        
        //NOTE: We need to use a width constraint because a trailing constraint could be ambiguous
        let leadingConstraint = NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: scrollView, attribute: .leading, multiplier: 1, constant: 0)
        let widthConstraint = NSLayoutConstraint(item: self, attribute: .width, relatedBy: .equal, toItem: scrollView, attribute: .width, multiplier: 1, constant: 0)
        let verticalConstraint = NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .lessThanOrEqual, toItem: scrollView, attribute: .top, multiplier: 1, constant: 0)
        scrollView.addConstraints([leadingConstraint, widthConstraint, verticalConstraint])
    }
    
//    func deregisterObservers() {
//        contentOffsetObserver = nil
//        contentSizeObserver = nil
//        frameObserver = nil
//
//        resetScrollViewContentInset()
//    }
//
//    func resetScrollViewContentInset() {
//        guard var currentInsets = self.scrollView?.contentInset else { return }
//
//        switch position {
//        case .top:
//            currentInsets.top = self.originalTopInset ?? 0
//        case .bottom:
//            currentInsets.bottom = self.originalBottomInset ?? 0
//            currentInsets.top = self.originalTopInset ?? 0
//
//            self.setScrollViewContentInset(contentInset: currentInsets)
//        }
//    }
//
//    func setScrollViewInsetForLoading() {
//        guard let scrollView = scrollView else { return }
//        let offset = max(scrollView.contentOffset.y * -1, 0)
//        var currentInsets = scrollView.contentInset
//
//        switch position {
//        case .top:
//            currentInsets.top = min(offset, self.originalTopInset ?? 0 + self.bounds.size.height)
//        case .bottom:
//            currentInsets.bottom = min(offset, self.originalBottomInset ?? 0 + self.bounds.size.height)
//
//            self.setScrollViewContentInset(contentInset: currentInsets)
//        }
//    }
//
//    func setScrollViewContentInset(contentInset: UIEdgeInsets) {
//        UIView.animate(withDuration: 0.3, delay: 0, options: [.allowUserInteraction, .beginFromCurrentState], animations: {
//            self.scrollView?.contentInset = contentInset
//        }, completion: nil)
//    }
    
    var loadingThreshold: CGFloat {
        switch position {
        case .top:
            return self.frame.origin.y - (self.originalTopInset ?? 0);
        case .bottom:
            return max(scrollView.contentSize.height - scrollView.bounds.size.height, 0.0) + self.bounds.size.height + (self.originalBottomInset ?? 0)
        }
    }
    
    func scrollViewDidScroll(contentOffset: CGPoint) {
        if self.state != .loading {
            if(!scrollView.isDragging && self.state == .committed) {
                self.trigger()
//                self.state = .loading //TODO: TRIGGER!
            }
            else if(contentOffset.y < loadingThreshold && scrollView.isDragging && self.state == .stopped && self.position == .top) {
                self.state = .committed
            }
            else if(contentOffset.y >= loadingThreshold && self.state != .stopped && self.position == .top) {
                self.state = .stopped
            }
            else if(contentOffset.y > loadingThreshold && scrollView.isDragging && self.state == .stopped && self.position == .bottom) {
                self.state = .committed
            }
            else if(contentOffset.y <= loadingThreshold && self.state != .stopped && self.position == .bottom) {
                self.state = .stopped
            }
                
        } else {
            var offset: CGFloat
            var contentInset: UIEdgeInsets
            switch position {
            case .top:
                    offset = CGFloat(max(scrollView.contentOffset.y * -1, 0.0))
                    offset = CGFloat(min(offset, (originalTopInset ?? 0) + bounds.size.height))
                    contentInset = scrollView.contentInset
                    scrollView.contentInset = UIEdgeInsets(top: offset, left: contentInset.left, bottom: contentInset.bottom, right: contentInset.right)
            case .bottom:
                    if scrollView.contentSize.height >= scrollView.bounds.size.height {
                        offset = CGFloat(max(scrollView.contentSize.height - scrollView.bounds.size.height + bounds.size.height, 0.0))
                        offset = CGFloat(min(offset, (originalBottomInset ?? 0) + bounds.size.height))
                        contentInset = scrollView.contentInset
                        scrollView.contentInset = UIEdgeInsets(top: contentInset.top, left: contentInset.left, bottom: offset, right: contentInset.right)
                }
            }
        }
    }
    
    //
    // MARK: State
    //    
    var state: RefreshState = .stopped {
        willSet {
            guard state != newValue else { return }
            
            //Update UI for the new state
            switch newValue {
            case .stopped: layoutStateStopped()
            case .committed: layoutStateCommitted()
            case .loading: layoutStateLoading()
            }
        }
    }
    
    var position: RefreshPostion = .top {
        didSet {
            //TODO: Tell the scrollview to update based on the new position and state
        }
    }
    
    var refreshAction: RefreshAction = {}
    
    //
    // MARK: UI
    //
    var stoppedTitle = "Pull to refresh..."
    var triggeredTitle = "Release to refresh..."
    var loadingTitle = "Loading..."
    
    @IBOutlet var label: UILabel!
    @IBOutlet var arrowImageView: UIImageView!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    func setArrowColor(_ color: UIColor) {
        arrowImageView.image = arrowImageView.image?.withRenderingMode(.alwaysTemplate)
        arrowImageView.tintColor = color
    }
    
    func setArrowOrientation(isStopped: Bool, animated: Bool) {
        //Determine the orientation based on the refresh view position
        var shouldPointUp = true
        
        switch position {
        case .top:
            shouldPointUp = !isStopped
        case .bottom:
            shouldPointUp = isStopped
        }
        
        //Calculate the rotation
        let degrees: CGFloat = shouldPointUp ? 0 : 180
        let radians = degrees * .pi / 180

        //Animate to the new orientation
        let animationDuration = animated ? 0 : 0.2
        UIView.animate(withDuration: animationDuration, delay: 0, options: [.allowUserInteraction], animations: {
            self.arrowImageView.layer.transform = CATransform3DMakeRotation(radians, 0, 0, 1);
        })
    }
    
    //
    // MARK: Initialization
    //
    class func instanceFromNib() -> DefaultPullToRefreshView {
        let bundle = Bundle.init(for: self)
        let view = UINib(nibName: "DefaultPullToRefreshView", bundle: bundle).instantiate(withOwner: nil, options: nil)[0] as! DefaultPullToRefreshView
        view.style()
        return view
    }
    
    func style() {
        self.label.textColor = .darkGray
        self.setArrowColor(.gray)
        self.activityIndicator.activityIndicatorViewStyle = .gray
    }
    
    //
    // MARK: Layout
    //
    func layoutStateStopped() {
        self.label.text = stoppedTitle
        
        self.arrowImageView.isHidden = false
        self.setArrowOrientation(isStopped: true, animated: true)
        
        self.activityIndicator.isHidden = true
        self.activityIndicator.stopAnimating()
    }
    
    func layoutStateCommitted() {
        self.label.text = triggeredTitle
        
        self.arrowImageView.isHidden = false
        self.setArrowOrientation(isStopped: false, animated: true)
        
        self.activityIndicator.isHidden = true
        self.activityIndicator.stopAnimating()
    }
    
    func layoutStateLoading() {
        self.label.text = loadingTitle
        
        self.arrowImageView.isHidden = true
        self.setArrowOrientation(isStopped: true, animated: false)
        
        self.activityIndicator.isHidden = false
        self.activityIndicator.startAnimating()
    }

    //
    // MARK: Actions
    //
    func trigger() {
        refreshAction()
        self.state = .loading
    }
    
    func startAnimating() {
        self.state = .loading
        
        //TODO: OFFSET
    }
    
    func stopAnimating() {
        self.state = .stopped
        
        //TODO: Offset
    }
    
}
