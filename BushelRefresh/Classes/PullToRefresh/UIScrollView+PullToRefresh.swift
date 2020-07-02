//
//  UIScrollView+PullToRefresh.swift
//  BushelRefresh
//
//  Created by Alex (Work) on 7/1/20.
//

import UIKit

//TODO: Shared
extension Bundle {
    
    static func current() -> Bundle {
        return Bundle(for: DefaultPullToRefreshView.self)
    }
    
    static func resource() -> Bundle? {
        guard let bundleURL = Bundle.current().resourceURL?.appendingPathComponent("BushelRefresh.bundle") else { return nil }
        return Bundle(url: bundleURL)
    }
    
}





public protocol PullToRefresh: class {
    
    //View
    var pullToRefreshContainer: PullToRefreshContainer? { get }
    var pullToRefreshView: PullToRefreshView? { get }
    var showsPullToRefresh: Bool { get set }
    
    //Actionsx
    func addPullToRefresh(action: @escaping RefreshAction, containerType: PullToRefreshContainer.Type, viewType: PullToRefreshView.Type)
    
}

//Primary layout and behavior
extension UIScrollView: PullToRefresh {
    
    //State
    public var pullToRefreshContainer: PullToRefreshContainer? {
        return self.subviews.compactMap({ $0 as? PullToRefreshContainer }).first
    }
    
    public var pullToRefreshView: PullToRefreshView? {
        return self.pullToRefreshContainer?.refreshView
    }
    
    public var showsPullToRefresh: Bool {
        get {
            return self.pullToRefreshContainer?.isHidden == false
        }
        set {
            self.pullToRefreshContainer?.isHidden = !newValue
        }
    }
    
    //Actions
    public func addPullToRefresh(action: @escaping RefreshAction, containerType: PullToRefreshContainer.Type = PullToRefreshTopContainer.self, viewType: PullToRefreshView.Type = DefaultPullToRefreshView.self) {
        //Remove existing PTR (if it exists)
        self.pullToRefreshContainer?.removeFromSuperview()

        //Add our new PTR view
        let view = containerType.init(scrollView: self, refreshAction: action, viewType: viewType)
        self.addSubview(view)

        //Setup the PTR state
        view.refreshAction = action
        view.originalInset = self.contentInset.top //TODO: I'd love to remove these and determine the insets mathmatically

        //Add the constraints
        view.setupScrollViewConstraints()
    }
    
}
