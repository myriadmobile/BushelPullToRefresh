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





public protocol PullToRefresh: class {
    //View
    var pullToRefreshView: PullToRefreshView { get set }
    var showsPullToRefresh: Bool { get set }
    
    //Actions
    func addPullToRefesh(action: @escaping RefreshAction)
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
        //Clear any existing PTR views
        let pullToRefreshViews = self.subviews.filter({ $0 is PullToRefreshView }) //TODO: What if infinite scrolling is in the same position as PTR?
        pullToRefreshViews.forEach({ $0.removeFromSuperview() })

        //Add our new PTR view
        self.addSubview(pullToRefreshView)
        
        //Setup the PTR state
        //NOTE: This must be done AFTER adding it to the subview as our computed var retrieves the PTR subview. We do this because extensions cannot hold normal vars.
        pullToRefreshView.accessibilityIdentifier = "PullToRefreshView" //TODO: Better place to do this?
        pullToRefreshView.isAccessibilityElement = true
        pullToRefreshView.refreshAction = action
        pullToRefreshView.scrollView = self
        pullToRefreshView.originalInset = self.contentInset.top //TODO: I'd love to remove these and determine the insets mathmatically
        
        //Add the constraints
        pullToRefreshView.setupConstraints()
        
        //Observers
        pullToRefreshView.registerObservers()
    }
    
    public func triggerPullToRefresh() {
        self.pullToRefreshView.trigger()
    }
    
}
