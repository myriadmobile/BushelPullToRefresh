//
//  DefaultPullToRefreshView.swift
//  BushelRefresh
//
//  Created by Alex (Work) on 7/1/20.
//

import UIKit

//
// MARK: PullToRefresh View Protocol
// This is the core set of rules that refresh views must meet. This allows us to keep the library customizable, but clean.
//
public enum RefreshState {
    case stopped
    case committed
    case loading
}

public protocol RefreshDelegate {
    func didStop()
    func didCommit()
    func didBeginLoading()
}

public protocol PullToRefreshView: UIView {
    
    //Initialization
    static func createView() -> PullToRefreshView
    
    //State
    var delegate: RefreshDelegate? { get set }
    var state: RefreshState { get set }
    
    //Actions
    func startAnimating()
    func stopAnimating()
    
}

//r
// MARK: PullToRefresh View
// This is a default implementation that resembles the behavior of SVPullToRefresh. You can subclass or write your own implementation to meet your needs.
//
public class DefaultPullToRefreshView: UIView, PullToRefreshView {
    
    //
    // MARK: UI
    //
    var stoppedTitle = "Pull to refresh..."
    var triggeredTitle = "Release to refresh..."
    var loadingTitle = "Loading..."
    
    @IBOutlet var label: UILabel!
    @IBOutlet var arrowImageView: UIImageView!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    //
    // MARK: Initialization
    //
    public static func createView() -> PullToRefreshView {
        let view = UINib(nibName: "DefaultPullToRefreshView", bundle: Bundle.current()).instantiate(withOwner: nil, options: nil)[0] as! DefaultPullToRefreshView
        
        //Style
        view.label.textColor = .darkGray
        view.setArrowColor(.gray)
        view.arrowImageView.image = UIImage(named: "Arrow", in: Bundle.resource(), compatibleWith: nil)
        view.activityIndicator.activityIndicatorViewStyle = .gray
        
        return view
    }
    
    //
    // MARK: State
    //
    public var delegate: RefreshDelegate?
    
    var lastSetState: RefreshState? //TODO: Is there a better way?
    public var state: RefreshState = .stopped {
        didSet {
            //NOTE: Only update the layout if the state changes. This mitigates the risk of abnormal layout issues (like duplicated or stuttering animations).
            guard state != lastSetState else { return }
            lastSetState = state
            
            //Update UI for the new state
            switch state {
            case .stopped:
                layoutStateStopped()
                delegate?.didStop()
            case .committed:
                layoutStateCommitted()
                delegate?.didCommit()
            case .loading:
                layoutStateLoading()
                delegate?.didBeginLoading()
            }
        }
    }
    
    //
    // MARK: Layout
    //
    func layoutStateStopped() {
        //Text
        self.label.text = stoppedTitle
        
        //Arrow
        self.arrowImageView.isHidden = false
        self.setArrowOrientation(isStopped: true, animated: true)
        
        //Activity Indicator
        self.activityIndicator.isHidden = true
        self.activityIndicator.stopAnimating()
    }
    
    func layoutStateCommitted() {
        //Text
        self.label.text = triggeredTitle
        
        //Arrow
        self.arrowImageView.isHidden = false
        self.setArrowOrientation(isStopped: false, animated: true)
        
        //Activity Indicator
        self.activityIndicator.isHidden = true
        self.activityIndicator.stopAnimating()
    }
    
    func layoutStateLoading() {
        //Text
        self.label.text = loadingTitle
        
        //Arrow
        self.arrowImageView.isHidden = true
        self.setArrowOrientation(isStopped: true, animated: false)
        
        //Activity Indicator
        self.activityIndicator.isHidden = false
        self.activityIndicator.startAnimating()
    }
    
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
    // MARK: Actions
    //
    public func startAnimating() {
        self.state = .loading
    }
    
    public func stopAnimating() {
        self.state = .stopped
    }
    
}
