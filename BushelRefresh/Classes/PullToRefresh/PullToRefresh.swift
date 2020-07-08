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
    var refreshAction: RefreshAction { get set }
    
    //Initialization
    init(scrollView: UIScrollView, refreshAction: @escaping RefreshAction, viewType: PullToRefreshView.Type)
    func setupScrollViewConstraints()
    
}

//
// MARK: PullToRefresh Containers
// These are default implementations to allow for top and bottom alignment. You can subclass or write your own implementation to meet your needs.
//
public class PullToRefreshTopContainer: UIView, PullToRefreshContainer, RefreshDelegate {
    
    public var scrollView: UIScrollView
    public var refreshView: PullToRefreshView
    public var refreshAction: RefreshAction
    
    lazy var verticalConstraint = NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: scrollView, attribute: .top, multiplier: 1, constant: 0)
    var originalInset: CGFloat { didSet { updateVerticalConstraint() } }
    
    var contentOffsetObserver: NSKeyValueObservation?
    var contentInsetObserver: NSKeyValueObservation?
    
    //
    // MARK: Initialization
    //
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required public init(scrollView: UIScrollView, refreshAction: @escaping RefreshAction, viewType: PullToRefreshView.Type) {
        //Set required properties
        self.scrollView = scrollView
        self.refreshView = viewType.createView()
        self.refreshAction = refreshAction
        self.originalInset = scrollView.contentInset.top
        
        //Init view; frame doesn't matter
        super.init(frame: .zero)
        self.translatesAutoresizingMaskIntoConstraints = false
        
        //Set up that is dependent on self
        self.setupRefreshView()
        self.setupObservers()
        self.refreshView.delegate = self
        self.refreshView.refreshLayout()
    }
    
    //
    // MARK: Setup
    //
    public func setupScrollViewConstraints() {
        translatesAutoresizingMaskIntoConstraints = false
        
        //NOTE: We need to use a width constraint because a trailing constraint could be ambiguous
        let leadingConstraint = NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: scrollView, attribute: .leading, multiplier: 1, constant: 0)
        let widthConstraint = NSLayoutConstraint(item: self, attribute: .width, relatedBy: .equal, toItem: scrollView, attribute: .width, multiplier: 1, constant: 0)
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
        
        contentInsetObserver = scrollView.observe(\.contentInset) { [weak self] (scrollView, change) in
            guard self?.isHidden == false else { return }
            self?.originalInset = scrollView.contentInset.top
        }
    }
    
    func updateVerticalConstraint() {
        verticalConstraint.constant = -self.originalInset
    }
    
    //
    // MARK: Scrolling Behavior
    //
    var loadingThreshold: CGFloat {
        return self.frame.height
    }
    
    func scrollViewDidScroll(contentOffset: CGPoint) {
        switch refreshView.state {
        case .loading:
            break
        case .committed:
            if !scrollView.isDragging {
                refreshAction()
                refreshView.state = .loading
            }
            else if contentOffset.y >= -loadingThreshold {
                refreshView.state = .stopped
            }
        case .stopped:
            if contentOffset.y < -loadingThreshold && scrollView.isDragging {
                refreshView.state = .committed
            }
        }
    }
        
    //
    // MARK: Layout
    //
    public func didStop() {
        UIView.animate(withDuration: 0.3, delay: 0, options: [.allowUserInteraction], animations: {
             self.scrollView.contentInset.top = self.originalInset
        })
    }
    
    public func didCommit() {
        UIView.animate(withDuration: 0.3, delay: 0, options: [.allowUserInteraction], animations: {
            self.scrollView.contentInset.top = self.originalInset
        })
    }
    
    public func didBeginLoading() {
        UIView.animate(withDuration: 0.3, delay: 0, options: [.allowUserInteraction], animations: {
            let originalInset = self.originalInset
            self.scrollView.contentInset.top = originalInset + self.frame.height
            
            //Adjust so loading indicator is shown
            self.scrollView.setContentOffset(CGPoint(x: 0, y: -self.scrollView.contentInset.top), animated: true)
            
            //Addresses an issue where KVO will change the original inset to the LOADING inset value
            self.originalInset = originalInset
        })
    }
    
}

public class PullToRefreshBottomContainer: UIView, PullToRefreshContainer, RefreshDelegate {
    
    public var scrollView: UIScrollView
    public var refreshView: PullToRefreshView
    public var refreshAction: RefreshAction
    
    lazy var verticalConstraint = NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: scrollView, attribute: .top, multiplier: 1, constant: 0)
    var originalInset: CGFloat { didSet { updateVerticalConstraint() } }
    
    var contentOffsetObserver: NSKeyValueObservation?
    var contentInsetObserver: NSKeyValueObservation?
    var contentSizeObserver: NSKeyValueObservation?
    
    //
    // MARK: Initialization
    //
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required public init(scrollView: UIScrollView, refreshAction: @escaping RefreshAction, viewType: PullToRefreshView.Type) {
        //Set required properties
        self.scrollView = scrollView
        self.refreshView = viewType.createView()
        self.refreshAction = refreshAction
        self.originalInset = scrollView.contentInset.bottom
        
        //Init view; frame doesn't matter
        super.init(frame: .zero)
        self.translatesAutoresizingMaskIntoConstraints = false
        
        //Set up that is dependent on self
        self.setupRefreshView()
        self.setupObservers()
        self.refreshView.delegate = self
        self.refreshView.refreshLayout()
    }
    
    //
    // MARK: Setup
    //
    public func setupScrollViewConstraints() {
        translatesAutoresizingMaskIntoConstraints = false
        
        //NOTE: We need to use a width constraint because a trailing constraint could be ambiguous
        let leadingConstraint = NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: scrollView, attribute: .leading, multiplier: 1, constant: 0)
        let widthConstraint = NSLayoutConstraint(item: self, attribute: .width, relatedBy: .equal, toItem: scrollView, attribute: .width, multiplier: 1, constant: 0)
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
        
        contentInsetObserver = scrollView.observe(\.contentInset) { [weak self] (scrollView, change) in
            guard self?.isHidden == false else { return }
            self?.originalInset = scrollView.contentInset.bottom
        }
        
        contentSizeObserver = scrollView.observe(\.contentSize) { [weak self] (scrollView, change) in
            guard self?.isHidden == false else { return }
            self?.updateVerticalConstraint()
        }
    }
    
    func updateVerticalConstraint() {
        verticalConstraint.constant = self.originalInset + scrollView.contentSize.height + refreshView.frame.height
    }
    
    //
    // MARK: Scrolling Behavior
    //
    var loadingThreshold: CGFloat {
        return self.frame.height
    }
    
    func scrollViewDidScroll(contentOffset: CGPoint) {
        switch refreshView.state {
        case .loading:
            break
        case .committed:
            if !scrollView.isDragging {
                refreshAction()
                refreshView.state = .loading
            }
            else if contentOffset.y - scrollView.contentSize.height + scrollView.frame.height - scrollView.contentInset.bottom <= loadingThreshold {
                refreshView.state = .stopped
            }
        case .stopped:
            if contentOffset.y - scrollView.contentSize.height + scrollView.frame.height - scrollView.contentInset.bottom > loadingThreshold && scrollView.isDragging {
                refreshView.state = .committed
            }
        }
    }
        
    //
    // MARK: Layout
    //
    public func didStop() {
        UIView.animate(withDuration: 0.3, delay: 0, options: [.allowUserInteraction], animations: {
             self.scrollView.contentInset.bottom = self.originalInset
        })
    }
    
    public func didCommit() {
        UIView.animate(withDuration: 0.3, delay: 0, options: [.allowUserInteraction], animations: {
            self.scrollView.contentInset.bottom = self.originalInset
        })
    }
    
    public func didBeginLoading() {
        UIView.animate(withDuration: 0.3, delay: 0, options: [.allowUserInteraction], animations: {
            let originalInset = self.originalInset
            self.scrollView.contentInset.bottom = originalInset + self.frame.height
            
            //Adjust so loading indicator is shown
            let offset = self.scrollView.contentInset.bottom + self.scrollView.contentSize.height + self.scrollView.frame.height
            self.scrollView.setContentOffset(CGPoint(x: 0, y: offset), animated: true)
            
            //Addresses an issue where KVO will change the original inset to the LOADING inset value
            self.originalInset = originalInset
        })
    }
    
}
