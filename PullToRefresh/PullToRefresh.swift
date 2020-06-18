//
//  PullToRefresh.swift
//  BushelRefresh
//
//  Created by Alex (Work) on 6/18/20.
//

import UIKit

protocol PullToRefresh: class {
    //View
    var pullToRefreshView: PullToRefreshView { get set }
    func showsPullToRefresh()
    
    //Actions
    func addPullToRefesh(action: () -> Void)
    func addPullToRefesh(action: () -> Void, position: PullToRefreshPostion) //TODO: Maybe get rid of this? Depend on the position of the view instance.
    func triggerPullToRefresh()
}

extension UIScrollView: PullToRefresh {
    
    //View
    var pullToRefreshView: PullToRefreshView {
        get {
            //TODO:
        }
        set {
            //TODO:
        }
    }
    
    func showsPullToRefresh() {
        //TODO:
    }
    
    //Actions
    func addPullToRefesh(action: () -> Void) {
        //TODO:
    }
    
    func addPullToRefesh(action: () -> Void, position: PullToRefreshPostion) {
        //TODO:
    }
    
    func triggerPullToRefresh() {
        //TODO:
    }
    
}
