//
//  TopRefreshContainer.swift
//  BushelRefresh
//
//  Created by Alex Larson on 7/15/21.
//

import UIKit

public class TopRefreshContainer: UIView, RefreshContainer {
        
    public var id: String
    public var scrollView: UIScrollView
    public var refreshView: RefreshView
    public var refreshAction: RefreshAction
    
    //Custom State
    lazy var verticalConstraint = NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: scrollView, attribute: .top, multiplier: 1, constant: 0)
    var originalInset: CGFloat { didSet { updateVerticalConstraint() } }
    
    var contentOffsetObserver: NSKeyValueObservation?
    var contentInsetObserver: NSKeyValueObservation?
    
    // MARK: Initialization
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required public init(id: String, scrollView: UIScrollView, refreshAction: @escaping RefreshAction, viewType: RefreshView.Type) {
        self.id = id
        self.scrollView = scrollView
        self.refreshView = viewType.createView()
        self.refreshAction = refreshAction
        self.originalInset = scrollView.contentInset.top
        
        //Init view; frame doesn't matter
        super.init(frame: .zero)
        
        //Setup
        self.setupObservers()
        self.addSubview(refreshView)
        self.setupRefreshViewConstraints()
        self.refreshView.delegate = self
        self.refreshView.refreshLayout()
    }
    
    // MARK: Setup
    public func setupScrollViewConstraints() {
        translatesAutoresizingMaskIntoConstraints = false
        
        //NOTE: We need to use a width constraint because a trailing constraint could be ambiguous in a scrollview
        let leadingConstraint = NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: scrollView, attribute: .leading, multiplier: 1, constant: 0)
        let widthConstraint = NSLayoutConstraint(item: self, attribute: .width, relatedBy: .equal, toItem: scrollView, attribute: .width, multiplier: 1, constant: 0)
        scrollView.addConstraints([leadingConstraint, widthConstraint, verticalConstraint])
    }
    
    func setupRefreshViewConstraints() {
        refreshView.translatesAutoresizingMaskIntoConstraints = false
        
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
        
        contentInsetObserver = scrollView.observe(\.contentInset, options: [.new, .old]) { [weak self] (scrollView, change) in
            guard self?.isHidden == false else { return }
            
            //Required or other inset changes (e.g. bottom) will call this again and disrupt our original inset
            guard change.newValue?.top != change.oldValue?.top else { return }
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
            else if contentOffset.y - verticalConstraint.constant >= -loadingThreshold {
                refreshView.state = .stopped
            }
        case .stopped:
            if contentOffset.y - verticalConstraint.constant < -loadingThreshold && scrollView.isDragging {
                refreshView.state = .committed
            }
        }
    }
            
}

extension TopRefreshContainer: RefreshDelegate {
    
    // TODO: Extract these
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
            self.scrollView.scrollRectToVisible(self.frame, animated: true)
            
            //Addresses an issue where KVO will change the original inset to the LOADING inset value
            self.originalInset = originalInset
        })
    }
        
}
