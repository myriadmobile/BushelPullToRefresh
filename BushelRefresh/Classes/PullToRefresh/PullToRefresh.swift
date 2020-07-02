//
//  PullToRefresh.swift
//  BushelRefresh
//
//  Created by Alex (Work) on 6/18/20.
//

import UIKit

//
// MARK: PullToRefresh Container Protocol
// This is the core set of rules that refresh cotnainers must meet. This allows us to keep the library customizable, but clean.
//
public typealias RefreshAction = () -> Void

public protocol PullToRefreshContainer: UIView {
    
    var scrollView: UIScrollView { get set }
    var refreshView: PullToRefreshView { get set }
    var originalInset: CGFloat { get set }
    
    //Initialization
    init(scrollView: UIScrollView, refreshAction: @escaping RefreshAction, viewType: PullToRefreshView.Type)
    func setupScrollViewConstraints()
    
    //State
    var refreshAction: RefreshAction { get set }
    
}

//
// MARK: PullToRefresh Containers
// These are default implementations to allow for top and bottom alignment. You can subclass or write your own implementation to meet your needs.
//
public class PullToRefreshTopContainer: UIView, PullToRefreshContainer {
    
    public var scrollView: UIScrollView
    public var refreshView: PullToRefreshView
    public var refreshAction: RefreshAction
    
    public var originalInset: CGFloat
    
    var contentOffsetObserver: NSKeyValueObservation?
    var refreshStateObserver: NSKeyValueObservation?
    
    //
    // MARK: Initialization
    //
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required public init(scrollView: UIScrollView, refreshAction: @escaping RefreshAction, viewType: PullToRefreshView.Type) {
        self.scrollView = scrollView
        self.refreshView = viewType.createView()
        self.refreshAction = refreshAction
        self.originalInset = scrollView.contentInset.top //TODO: How to handle inset?
        
        super.init(frame: .zero) //The frame doesn't matter as we are depending on constraints
        
        setupRefreshView()
        setupObservers()
    }
    
    //
    // MARK: Setup
    //
    public func setupScrollViewConstraints() {
        translatesAutoresizingMaskIntoConstraints = false
        
        //NOTE: We need to use a width constraint because a trailing constraint could be ambiguous
        let leadingConstraint = NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: scrollView, attribute: .leading, multiplier: 1, constant: 0)
        let widthConstraint = NSLayoutConstraint(item: self, attribute: .width, relatedBy: .equal, toItem: scrollView, attribute: .width, multiplier: 1, constant: 0)
        let verticalConstraint = NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .lessThanOrEqual, toItem: scrollView, attribute: .top, multiplier: 1, constant: 0)
        scrollView.addConstraints([leadingConstraint, widthConstraint, verticalConstraint])
    }
    
    func setupRefreshView() {
        refreshView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(refreshView)
        
        let leadingConstraint = NSLayoutConstraint(item: refreshView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 0)
        let trailingConstraint = NSLayoutConstraint(item: refreshView, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: 0)
        let topConstraint = NSLayoutConstraint(item: refreshView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0)
        let bottomConstraint = NSLayoutConstraint(item: refreshView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0)
        
        self.addConstraints([leadingConstraint, trailingConstraint, topConstraint, bottomConstraint])
    }
    
    func setupObservers() {
        contentOffsetObserver = scrollView.observe(\.contentOffset) { [weak self] (scrollView, change) in
            guard self?.isHidden == false else { return }
            self?.scrollViewDidScroll(contentOffset: scrollView.contentOffset)
        }
        
//        refreshStateObserver = refreshView.observe(\.state) { [weak self] (scrollView, change) in
//            //TODO: State KVO for insets
//        }
    }
    
    
    //
    // MARK: Scrolling Behavior
    //
    var loadingThreshold: CGFloat {
        return self.frame.origin.y - originalInset
    }
    
    func scrollViewDidScroll(contentOffset: CGPoint) {
        switch refreshView.state {
        case .loading:
            break
        case .committed:
            if !scrollView.isDragging {
                refreshView.state = .loading
            }
            else if contentOffset.y >= loadingThreshold {
                refreshView.state = .stopped
            }
        case .stopped:
            if contentOffset.y < loadingThreshold && scrollView.isDragging {
                refreshView.state = .committed
            }
        }
    }
        
    //
    // MARK: Layout
    //
    func layoutStateStopped() {
        //Insets
        UIView.animate(withDuration: 0.3, delay: 0, options: [.allowUserInteraction], animations: {
             self.scrollView.contentInset.top = self.originalInset
        })
    }
    
    func layoutStateCommitted() {
        //Insets
        UIView.animate(withDuration: 0.3, delay: 0, options: [.allowUserInteraction], animations: {
            self.scrollView.contentInset.top = self.originalInset
        })
    }
    
    func layoutStateLoading() {
        //Insets
        UIView.animate(withDuration: 0.3, delay: 0, options: [.allowUserInteraction], animations: {
            self.scrollView.contentInset.top = self.originalInset + self.frame.height
            self.scrollView.setContentOffset(CGPoint(x: 0, y: self.loadingThreshold), animated: true)
        })
//        var offset: CGFloat
//        offset = CGFloat(max(scrollView.contentOffset.y * -1, 0.0))
//        offset = CGFloat(min(offset, originalInset + bounds.size.height))
//        scrollView.contentInset.top = offset
    }
    
}
