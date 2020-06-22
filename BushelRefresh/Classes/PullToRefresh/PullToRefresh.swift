//
//  PullToRefresh.swift
//  BushelRefresh
//
//  Created by Alex (Work) on 6/18/20.
//

import UIKit

//TODO: Move these to a common class
public typealias RefreshAction = () -> Void

public enum RefreshState {
    case stopped
    case committed
    case loading
}

public enum RefreshPostion {
    case top
    case bottom
}











public protocol PullToRefresh: class {
    //View
    var pullToRefreshView: PullToRefreshView { get set }
    var showsPullToRefresh: Bool { get set }
    
    //Actions
    func addPullToRefesh(action: @escaping RefreshAction)
    func addPullToRefesh(action: @escaping RefreshAction, position: RefreshPostion)
    func triggerPullToRefresh()
}

//Primary layout and behavior
extension UIScrollView: PullToRefresh {
    
    //State
    public var pullToRefreshView: PullToRefreshView {
        get {
            guard let existingView = self.subviews.compactMap({ $0 as? PullToRefreshView}).first else { return DefaultPullToRefreshView.instanceFromNib() }
            return existingView
        }
        set {
            //TODO: Remove when set?
        }
    }
    
    public var showsPullToRefresh: Bool {
        get {
            return !self.pullToRefreshView.isHidden //TODO: Also check if it exists on the view?
        }
        set {
            self.pullToRefreshView.isHidden = !newValue
        }
    }
    
    //Actions
    public func addPullToRefesh(action: @escaping RefreshAction) {
        addPullToRefesh(action: action, position: .top)
    }
    
    public func addPullToRefesh(action: @escaping RefreshAction, position: RefreshPostion) {
        //Clear any existing PTR views
        let pullToRefreshViews = self.subviews.filter({ $0 is PullToRefreshView })
        pullToRefreshViews.forEach({ $0.removeFromSuperview() })

        //Add our new PTR view
        self.addSubview(pullToRefreshView) //TODO: Determine necessary size; perhaps do in a layout action?
        
        //Setup the PTR state
        //NOTE: This must be done AFTER adding it to the subview as our computed var retrieves the PTR subview. We do this because extensions cannot hold normal vars.
        pullToRefreshView.delegate = self
        pullToRefreshView.position = position
        pullToRefreshView.refreshAction = action
        
        //Add the constraints
        let leadingConstraint = NSLayoutConstraint(item: pullToRefreshView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 0)
        let trailingConstraint = NSLayoutConstraint(item: pullToRefreshView, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: 0)
        let bottomConstraint = NSLayoutConstraint(item: pullToRefreshView, attribute: .bottom, relatedBy: .lessThanOrEqual, toItem: self, attribute: .top, multiplier: 1, constant: 0)
        
        pullToRefreshView.translatesAutoresizingMaskIntoConstraints = false
        self.addConstraints([leadingConstraint, trailingConstraint, bottomConstraint])
    }
    
    public func triggerPullToRefresh() {
        self.pullToRefreshView.trigger()
    }
    
}

//Delegate
extension UIScrollView: PullToRefreshDelegate {
    
    public func becameStopped(view: PullToRefreshView) {
        //TODO:
    }
    
    public func becameCommitted(view: PullToRefreshView) {
        //TODO:
    }
    
    public func becameLoading(view: PullToRefreshView) {
        //TODO:
    }
    
}
