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
    func addPullToRefresh(type: RefreshView.Type, action: @escaping RefreshAction)
    func addInfiniteScrolling(type: RefreshView.Type, action: @escaping RefreshAction)
    
    // Remove
    func removePullToRefresh()
    func removeInfiniteScrolling()
}

extension UIScrollView: Refresh {

    
    private static let PullToRefreshId = "PullToRefreshId"
    private static let InfiniteScrollingId = "InfiniteScrollingId"
    
    // MARK: Accessors
    public var pullToRefreshView: RefreshView? {
        return refreshView(for: UIScrollView.PullToRefreshId)
    }
    
    public var infiniteScrollingView: RefreshView? {
        return refreshView(for: UIScrollView.InfiniteScrollingId)
    }
    
    public var pullToRefreshContainer: RefreshContainer? {
        return refreshContainer(for: UIScrollView.PullToRefreshId)
    }
    
    public var infiniteScrollingContainer: RefreshContainer? {
        return refreshContainer(for: UIScrollView.InfiniteScrollingId)
    }
    
    // MARK: Add
    public func addPullToRefresh(action: @escaping RefreshAction) {
        addPullToRefresh(type: DefaultPullToRefreshView.self, action: action)
    }
    
    public func addPullToRefresh(type: RefreshView.Type, action: @escaping RefreshAction) {
        setRefresh(id: UIScrollView.PullToRefreshId,
                   containerType: TopRefreshContainer.self,
                   viewType: type,
                   action: action)
    }
    
    public func addInfiniteScrolling(action: @escaping RefreshAction) {
        addInfiniteScrolling(type: DefaultInfiniteLoadingView.self, action: action)
    }
    
    public func addInfiniteScrolling(type: RefreshView.Type, action: @escaping RefreshAction) {
        setRefresh(id: UIScrollView.InfiniteScrollingId,
                   containerType: BottomRefreshContainer.self,
                   viewType: type,
                   action: action)
    }
    
    // MARK: Remove
    public func removePullToRefresh() {
        removeRefreshContainer(for: UIScrollView.PullToRefreshId)
    }
    
    public func removeInfiniteScrolling() {
        removeRefreshContainer(for: UIScrollView.InfiniteScrollingId)
    }
    
    // MARK: Helpers
    private func refreshView(for id: String) -> RefreshView? {
        let container = refreshContainer(for: id)
        return container?.refreshView
    }
    
    private func refreshContainer(for id: String) -> RefreshContainer? {
        let containers = self.subviews.compactMap({ $0 as? RefreshContainer })
        return containers.first(where: { $0.id == id })
    }
    
    private func setRefresh(id: String, containerType: RefreshContainer.Type, viewType: RefreshView.Type, action: @escaping RefreshAction) {
        removeRefreshContainer(for: id)
        addRefreshContainer(with: id, containerType: containerType, viewType: viewType, action: action)
        setupConstraintsForRefreshContainer(with: id)
    }
    
    private func removeRefreshContainer(for id: String) {
        let container = refreshContainer(for: id)
        container?.removeFromSuperview()
    }
    
    private func addRefreshContainer(with id: String, containerType: RefreshContainer.Type, viewType: RefreshView.Type, action: @escaping RefreshAction) {
        let view = containerType.init(id: id, scrollView: self, refreshAction: action, viewType: viewType)
        self.addSubview(view)
    }
    
    private func setupConstraintsForRefreshContainer(with id: String) {
        let container = refreshContainer(for: id)
        container?.setupScrollViewConstraints()
    }
    
}
