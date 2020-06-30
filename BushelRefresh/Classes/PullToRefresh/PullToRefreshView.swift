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
    var originalInset: CGFloat! { get set }
    
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
    
    //ScrollView
    var scrollView: UIScrollView!
    var originalInset: CGFloat!
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
    
    var loadingThreshold: CGFloat {
        return self.frame.origin.y - originalInset
    }
    
    func scrollViewDidScroll(contentOffset: CGPoint) {
        switch state {
        case .loading:
            //TODO: This math seems funky
            var offset: CGFloat
            offset = CGFloat(max(scrollView.contentOffset.y * -1, 0.0))
            offset = CGFloat(min(offset, originalInset + bounds.size.height))
            scrollView.contentInset.top = offset
        case .committed:
            if !scrollView.isDragging { self.trigger() }
            else if contentOffset.y >= loadingThreshold { self.state = .stopped }
        case .stopped:
            if contentOffset.y < loadingThreshold && scrollView.isDragging { self.state = .committed }
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
        let shouldPointUp = !isStopped
        
        //Calculate the rotation
        let degrees: CGFloat = shouldPointUp ? 0 : 180
        let radians = degrees * .pi / 180

        //Animate to the new orientation
        let animationDuration = animated ? 0.2 : 0
        UIView.animate(withDuration: animationDuration, delay: 0, options: [.allowUserInteraction], animations: {
            self.arrowImageView.layer.transform = CATransform3DMakeRotation(radians, 0, 0, 1);
        })
    }
    
    //
    // MARK: Initialization
    //
    class func instanceFromNib() -> DefaultPullToRefreshView {
        let bundle = Bundle(for: self)
        let view = UINib(nibName: "DefaultPullToRefreshView", bundle: bundle).instantiate(withOwner: nil, options: nil)[0] as! DefaultPullToRefreshView
        view.style()
        return view
    }
    
    func style() {
        let bundle = Bundle(for: DefaultPullToRefreshView.self)
        let bundleURL = bundle.resourceURL?.appendingPathComponent("BushelRefresh.bundle")
        let resourceBundle = Bundle(url: bundleURL!) //TODO: Make this a static
        
        self.label.textColor = .darkGray
        self.setArrowColor(.gray)
        self.arrowImageView.image = UIImage(named: "Arrow", in: resourceBundle, compatibleWith: nil) //TODO: Bundle
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
