//
//  RefreshContainer.swift
//  BushelRefresh
//
//  Created by Alex (Work) on 7/8/20.
//

import UIKit

public typealias RefreshAction = () -> Void

public protocol RefreshContainer: UIView {
    var id: String { get }
    var scrollView: UIScrollView { get set }
    var refreshView: RefreshView { get set }
    var refreshAction: RefreshAction { get set }
    func setupScrollViewConstraints()
    init(id: String, scrollView: UIScrollView, refreshAction: @escaping RefreshAction, viewType: RefreshView.Type) // TODO:
}
