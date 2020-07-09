//
//  UIScrollView+Refresh.swift
//  BushelRefresh
//
//  Created by Alex (Work) on 7/8/20.
//

import UIKit

//
// MARK: Refresh Protocol
// This is a top level set of rules that scrollviews must implement.
//
public protocol Refresh {
    
    //View
    func refreshContainer(for id: String) -> RefreshContainer?
    func refreshView(for id: String) -> RefreshView?
    
    //Actions
    func addRefresh(id: String, containerType: RefreshContainer.Type, viewType: RefreshView.Type, action: @escaping RefreshAction)
    func removeRefresh(id: String)
    
}

//
// MARK: ScrollView Implementation
// This is the implementations that will apply to all scrollviews and their subtypes (ex: tableviews).
//
extension UIScrollView: Refresh {
    
    //
    // MARK: State
    //
    public func refreshContainer(for id: String) -> RefreshContainer? {
        let containers = self.subviews.compactMap({ $0 as? RefreshContainer })
        return containers.first(where: { $0.id == id })
    }
    
    public func refreshView(for id: String) -> RefreshView? {
        let container = refreshContainer(for: id)
        guard container?.isHidden == false else { return nil } //Don't return if hidden; hidden implies a temporary disable
        return container?.refreshView
    }

    //
    // MARK: Actions
    //
    public func addRefresh(id: String, containerType: RefreshContainer.Type, viewType: RefreshView.Type, action: @escaping RefreshAction) {
        //Remove existing PTR (if it exists)
        removeRefresh(id: id)

        //Add our new PTR view
        let view = containerType.init(id: id, scrollView: self, refreshAction: action, viewType: viewType)
        self.addSubview(view)

        //Add the constraints
        view.setupScrollViewConstraints()
    }

    public func removeRefresh(id: String) {
        let container = refreshContainer(for: id)
        container?.removeFromSuperview()
    }

}
