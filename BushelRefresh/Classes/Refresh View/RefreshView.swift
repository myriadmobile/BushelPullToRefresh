//
//  RefreshView.swift
//  BushelRefresh
//
//  Created by Alex (Work) on 7/8/20.
//

import UIKit

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

public protocol RefreshView: UIView {
    static func createView() -> RefreshView
    var delegate: RefreshDelegate? { get set }
    var state: RefreshState { get set } // Ideally we would use KVO instead of a delegate, but I ran into issues while attempting to implement it.
    func refreshLayout()
    func startAnimating()
    func stopAnimating()
}
