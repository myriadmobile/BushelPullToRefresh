//
//  UIScrollView+Refresh.swift
//  BushelRefresh
//
//  Created by Alex Larson on 7/8/20.
//

import UIKit

public protocol Refresh {
    // Accessors
    var pullToRefreshView: RefreshView? { get }
    var infiniteScrollingView: RefreshView? { get }
    var pullToRefreshContainer: RefreshContainer? { get }
    var infiniteScrollingContainer: RefreshContainer? { get }
    
    // Add
    func addPullToRefresh(action: @escaping RefreshAction)
    func addInfiniteScrolling(action: @escaping RefreshAction)
    func addPullToRefresh(refreshView: RefreshView, action: @escaping RefreshAction)
    func addInfiniteScrolling(refreshView: RefreshView, action: @escaping RefreshAction)
    
    // Remove
    func removePullToRefresh()
    func removeInfiniteScrolling()
}

extension UIScrollView: Refresh {
    
    private static let PullToRefreshId = "PullToRefreshId"
    private static let InfiniteScrollingId = "InfiniteScrollingId"
    
    // MARK: Accessors
    public var pullToRefreshView: RefreshView? {
        return pullToRefreshContainer?.refreshView
    }
    
    public var infiniteScrollingView: RefreshView? {
        return infiniteScrollingContainer?.refreshView
    }
    
    public var pullToRefreshContainer: RefreshContainer? {
        return refreshContainer(for: UIScrollView.PullToRefreshId)
    }
    
    public var infiniteScrollingContainer: RefreshContainer? {
        return refreshContainer(for: UIScrollView.InfiniteScrollingId)
    }
    
    private func refreshContainer(for id: String) -> RefreshContainer? {
        let containers = self.subviews.compactMap({ $0 as? RefreshContainer })
        return containers.first(where: { $0.id == id })
    }
    
    // MARK: Add
    public func addPullToRefresh(action: @escaping RefreshAction) {
        let refreshView = DefaultPullToRefreshView.createView()
        addPullToRefresh(refreshView: refreshView, action: action)
    }
    
    public func addPullToRefresh(refreshView: RefreshView, action: @escaping RefreshAction) {
        let container = createPullToRefreshContainer(refreshView: refreshView, action: action)
        setRefresh(container: container)
    }
    
    private func createPullToRefreshContainer(refreshView: RefreshView, action: @escaping RefreshAction) -> TopRefreshContainer {
        return TopRefreshContainer(id: UIScrollView.PullToRefreshId,
                                   scrollView: self,
                                   refreshAction: action,
                                   refreshView: refreshView)
    }
    
    public func addInfiniteScrolling(action: @escaping RefreshAction) {
        let refreshView = DefaultInfiniteLoadingView.createView()
        addInfiniteScrolling(refreshView: refreshView, action: action)
    }
        
    public func addInfiniteScrolling(refreshView: RefreshView, action: @escaping RefreshAction) {
        let container = createInfiniteScrollingContainer(refreshView: refreshView, action: action)
        setRefresh(container: container)
    }
    
    private func createInfiniteScrollingContainer(refreshView: RefreshView, action: @escaping RefreshAction) -> BottomRefreshContainer {
        return BottomRefreshContainer(id: UIScrollView.InfiniteScrollingId,
                                      scrollView: self,
                                      refreshAction: action,
                                      refreshView: refreshView)
    }
    
    private func setRefresh(container: RefreshContainer) {
        removeRefreshContainer(for: container.id)
        addSubview(container)
        container.addConstraints()
    }
    
    // MARK: Remove
    public func removePullToRefresh() {
        removeRefreshContainer(for: UIScrollView.PullToRefreshId)
    }
    
    public func removeInfiniteScrolling() {
        removeRefreshContainer(for: UIScrollView.InfiniteScrollingId)
    }
    
    private func removeRefreshContainer(for id: String) {
        let container = refreshContainer(for: id)
        container?.removeFromSuperview()
    }
        
}
