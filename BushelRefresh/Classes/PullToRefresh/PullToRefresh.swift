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
    case triggered
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
    func addPullToRefesh(action: RefreshAction)
    func addPullToRefesh(action: RefreshAction, position: RefreshPostion)
    func triggerPullToRefresh()
}

extension UIScrollView: PullToRefresh {
    
    //State
    public var pullToRefreshView: PullToRefreshView {
        get {
            return DefaultPullToRefreshView()
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
    
    open override func layoutIfNeeded() { //TODO: Maybe layout subviews?
        super.layoutIfNeeded()
        
//        //Only continue if we actually have a pullToRefreshView on our scrollview, otherwise there is no point in doing this math
//        guard self.subviews.contains(pullToRefreshView) else { return }
//
//        //Determine the ideal size of the refresh view
//        let maxSize = CGSize(width: self.bounds.size.width, height: CGFloat.greatestFiniteMagnitude)
//        let fitSize = pullToRefreshView.systemLayoutSizeFitting(maxSize)
//
//        //Determine the necessary y origin given the fit size
//        var yOrigin: CGFloat = 0
//
//        switch position {
//        case .top: yOrigin = -fitSize.height
//        case .bottom: yOrigin = self.contentSize.height
//        }
//
//        //Update the the view to be in the correct location
//        pullToRefreshView.frame = .init(x: 0, y: yOrigin, width: self.bounds.size.width, height: fitSize.height)
    }
    
    //Actions
    public func addPullToRefesh(action: RefreshAction) {
        addPullToRefesh(action: action, position: .top)
    }
    
    public func addPullToRefesh(action: RefreshAction, position: RefreshPostion) {
//        self.position = position
//
//        //Clear any existing PTR views
//        let pullToRefreshViews = self.subviews.filter({ $0 is PullToRefreshView })
//        pullToRefreshViews.forEach({ $0.removeFromSuperview() })
//
//        //Add our new PTR view
//        //TODO: Determine necessary size; perhaps do in a layout action?
//        //TODO: Maybe have the PTRV hold the action? It might be simpler. But - should the action change just because the view is changing? (E.g. replace the view replaces the action)
//        self.addSubview(pullToRefreshView)
//
//        //TODO:
    }
    
    public func triggerPullToRefresh() {
        self.pullToRefreshView.startAnimating()
    }
    
}
