//
//  PullToRefreshView.swift
//  BushelRefresh
//
//  Created by Alex (Work) on 6/18/20.
//

import UIKit

public protocol PullToRefreshView: UIView {
    //State
    var state: RefreshState { get set }
    var position: RefreshPostion { get set }
    var refreshAction: RefreshAction { get set }
    var delegate: PullToRefreshDelegate? { get set }
    
    //Actions
    func trigger()
    func startAnimating()
    func stopAnimating()
}

public protocol PullToRefreshDelegate: UIScrollView {
    func becameStopped(view: PullToRefreshView) //TODO: Naming
    func becameCommitted(view: PullToRefreshView)
    func becameLoading(view: PullToRefreshView)
}

//Default Implementation
class DefaultPullToRefreshView: UIView, PullToRefreshView {
    
    //
    // MARK: State
    //
    weak var delegate: PullToRefreshDelegate?
    
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
        
        delegate?.becameStopped(view: self)
    }
    
    func layoutStateCommitted() {
        self.label.text = triggeredTitle
        
        self.arrowImageView.isHidden = false
        self.setArrowOrientation(isStopped: false, animated: true)
        
        self.activityIndicator.isHidden = true
        self.activityIndicator.stopAnimating()
        
        delegate?.becameCommitted(view: self)
    }
    
    func layoutStateLoading() {
        self.label.text = loadingTitle
        
        self.arrowImageView.isHidden = true
        self.setArrowOrientation(isStopped: true, animated: false)
        
        self.activityIndicator.isHidden = false
        self.activityIndicator.startAnimating()
        
        delegate?.becameLoading(view: self)
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
    }
    
    func stopAnimating() {
        self.state = .stopped
    }
    
}
