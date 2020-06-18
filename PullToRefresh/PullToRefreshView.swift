//
//  PullToRefreshView.swift
//  BushelRefresh
//
//  Created by Alex (Work) on 6/18/20.
//

import UIKit

enum PullToRefreshPostion {
    case top
    case bottom
}

enum PullToRefreshState {
    case stopped
    case triggered
    case loading
    case all //TODO: When is this used?
}

protocol PullToRefreshView: UIView {
    //State
    var state: PullToRefreshState { get set }
    var position: PullToRefreshState { get set }
    
    //Actions
    func startAnimating()
    func stopAnimating()
}

//Default Implementation
class DefaultPullToRefreshView: UIView, PullToRefreshView {
    
    //State
    var state: PullToRefreshState {
       get {
           //TODO:
       }
       set {
           //TODO:
       }
   }
    
    var position: PullToRefreshState {
       get {
           //TODO:
       }
       set {
           //TODO:
       }
   }
    
    //Actions
    func startAnimating() {
        //TODO:
    }
    
    func stopAnimating() {
        //TODO:
    }
    
}
