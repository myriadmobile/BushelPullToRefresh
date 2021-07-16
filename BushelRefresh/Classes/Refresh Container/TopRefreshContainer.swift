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
    private var originalInset: CGFloat { didSet { updateVerticalConstraint() } }
    private var contentOffsetObserver: NSKeyValueObservation?
    private var contentInsetObserver: NSKeyValueObservation?
    private lazy var verticalConstraint = NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: scrollView, attribute: .top, multiplier: 1, constant: 0)
    
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
        
        super.init(frame: .zero)
        
        self.setupScrollViewObservers()
        self.setupRefreshView()
    }
    
    private func setupScrollViewObservers() {
        setupOffsetObserver()
        setupInsetObserver()
    }
    
    private func setupOffsetObserver() {
        contentOffsetObserver = scrollView.observe(\.contentOffset) { [weak self] (scrollView, change) in
            guard self?.isHidden == false else { return }
            self?.scrollViewDidScroll()
        }
    }
    
    private func setupInsetObserver() {
        contentInsetObserver = scrollView.observe(\.contentInset, options: [.new, .old]) { [weak self] (scrollView, change) in
            guard self?.isHidden == false else { return }
            guard change.newValue?.top != change.oldValue?.top else { return }
            self?.originalInset = scrollView.contentInset.top
        }
    }
    
    private func setupRefreshView() {
        addRefreshViewToContainer()
        addRefreshViewConstraints()
        refreshView.delegate = self
        refreshView.refreshLayout()
    }
    
    private func addRefreshViewToContainer() {
        self.addSubview(refreshView)
    }
    
    private func addRefreshViewConstraints() {
        refreshView.translatesAutoresizingMaskIntoConstraints = false
        
        let leadingConstraint = NSLayoutConstraint(item: refreshView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 0)
        let trailingConstraint = NSLayoutConstraint(item: refreshView, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: 0)
        let topConstraint = NSLayoutConstraint(item: refreshView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0)
        let bottomConstraint = NSLayoutConstraint(item: refreshView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0)
        
        self.addConstraints([leadingConstraint, trailingConstraint, topConstraint, bottomConstraint])
    }
    
    // MARK: Vertical Constraint
    public func addVerticalConstraint() {
        scrollView.addConstraints([verticalConstraint])
    }
    
    private func updateVerticalConstraint() {
        verticalConstraint.constant = -self.originalInset
    }
    
    // MARK: Scrolling Behavior
    private var loadingThreshold: CGFloat {
        return self.frame.height
    }
    
    private func scrollViewDidScroll() {
        switch refreshView.state {
        case .loading:
            break // We don't want to change states once loading has already begun
        case .committed:
            handleScrollWhileComitted()
        case .stopped:
            handleScrollWhileStopped()
        }
    }

    private func handleScrollWhileComitted() {
        let userHasStoppedDragging = !scrollView.isDragging
        let offsetIsBelowLoadingThreshold = scrollView.contentOffset.y - verticalConstraint.constant >= -loadingThreshold
        
        if userHasStoppedDragging {
            beginLoading()
        } else if offsetIsBelowLoadingThreshold {
            abandonLoadingAttempt()
        }
    }
    
    private func beginLoading() {
        refreshView.state = .loading
        refreshAction()
    }
    
    private func abandonLoadingAttempt() {
        refreshView.state = .stopped
    }
    
    private func handleScrollWhileStopped() {
        let userIsDragging = scrollView.isDragging
        let offsetIsAboveLoadingThreshold = scrollView.contentOffset.y - verticalConstraint.constant < -loadingThreshold
        
        if userIsDragging && offsetIsAboveLoadingThreshold {
            commitToLoading()
        }
    }
    
    private func commitToLoading() {
        refreshView.state = .committed
    }
    
}

extension TopRefreshContainer: RefreshDelegate {
    
    public func didStop() {
        UIView.animate(withDuration: 0.3, delay: 0, options: [.allowUserInteraction], animations: {
            self.resetScrollViewInset()
        })
    }
    
    public func didCommit() {
        UIView.animate(withDuration: 0.3, delay: 0, options: [.allowUserInteraction], animations: {
            self.resetScrollViewInset()
        })
    }
    
    public func didBeginLoading() {
        UIView.animate(withDuration: 0.3, delay: 0, options: [.allowUserInteraction], animations: {
            let insetBeforeUpdate = self.originalInset
            
            self.addContainerToScrollViewInset()
            self.scrollToShowContainer()
            
            // Addresses an issue where KVO will change the original inset to the LOADING inset value
            self.originalInset = insetBeforeUpdate
        })
    }
    
    private func resetScrollViewInset() {
        scrollView.contentInset.top = originalInset
    }
    
    private func addContainerToScrollViewInset() {
        scrollView.contentInset.top = originalInset + self.frame.height
    }
    
    private func scrollToShowContainer() {
        scrollView.scrollRectToVisible(self.frame, animated: true)
    }
    
}
