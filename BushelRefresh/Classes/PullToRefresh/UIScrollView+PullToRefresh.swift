//
//  UIScrollView+PullToRefresh.swift
//  BushelRefresh
//
//  Created by Alex (Work) on 7/1/20.
//

import UIKit

//
// MARK: PullToRefresh Protocol
// This is a top level set of rules that scrollviews must implement. This extends the specifies how we are to interact with PullToRefresh.
//
public protocol PullToRefresh {
    
    //View
    var pullToRefreshContainer: PullToRefreshContainer? { get }
    var pullToRefreshView: PullToRefreshView? { get }
    
    //Actions
    func addPullToRefresh(containerType: PullToRefreshContainer.Type, viewType: PullToRefreshView.Type, action: @escaping RefreshAction)
    func removePullToRefresh()
    
}

//
// MARK: ScrollView Implementation
// This is the implementations that will apply to all scrollviews and their subtypes (ex: tableviews).
//
extension UIScrollView: PullToRefresh {
    
    //
    // MARK: State
    //
    public var pullToRefreshContainer: PullToRefreshContainer? {
        return self.subviews.compactMap({ $0 as? PullToRefreshContainer }).first
    }
    
    public var pullToRefreshView: PullToRefreshView? {
        return self.pullToRefreshContainer?.refreshView
    }
    
    //
    // MARK: Actions
    //
    public func addPullToRefresh(containerType: PullToRefreshContainer.Type = PullToRefreshTopContainer.self, viewType: PullToRefreshView.Type = DefaultPullToRefreshView.self, action: @escaping RefreshAction) {
        //Remove existing PTR (if it exists)
        removePullToRefresh()

        //Add our new PTR view
        let view = containerType.init(scrollView: self, refreshAction: action, viewType: viewType)
        self.addSubview(view)

        //Setup the PTR state
        view.refreshAction = action
        view.originalInset = self.contentInset.top

        //Add the constraints
        view.setupScrollViewConstraints()
    }
    
    public func removePullToRefresh() {
        self.pullToRefreshContainer?.removeFromSuperview()
    }
    
}
