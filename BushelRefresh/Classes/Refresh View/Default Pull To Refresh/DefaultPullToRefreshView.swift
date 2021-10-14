//
//  DefaultPullToRefreshView.swift
//  BushelRefresh
//
//  Created by Alex Larson on 7/16/21.
//

import Foundation

public class DefaultPullToRefreshView: UIView, RefreshView {
    
    let stoppedTitle = "Pull to refresh..."
    let triggeredTitle = "Release to refresh..."

    // MARK: UI
    @IBOutlet var label: UILabel!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    // MARK: State
    public var delegate: RefreshDelegate?

    private var lastSetState: RefreshState?
    public var state: RefreshState = .stopped {
        didSet {
            // Only update the layout if the state changes. This mitigates the risk of abnormal layout issues (like duplicated or stuttering animations).
            guard state != lastSetState else { return }
            lastSetState = state
            refreshWithCurrentState()
        }
    }

    // MARK: Initialization
    public static func createView() -> RefreshView {
        let view = UINib(nibName: "DefaultPullToRefreshView", bundle: .bushelRefresh).instantiate(withOwner: nil, options: nil)[0] as! DefaultPullToRefreshView
        return view
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        style()
    }
    
    private func style() {
        styleView()
        styleLabel()
        styleActivityIndicator()
    }

    private func styleView() {
        backgroundColor = .clear
    }

    private func styleLabel() {
        label.textColor = .darkGray
    }

    private func styleActivityIndicator() {
        activityIndicator.style = .gray
        activityIndicator.hidesWhenStopped = true
    }

    // MARK: Layout
    public func refreshWithCurrentState() {
        switch state {
        case .stopped:
            handleStoppedState()
        case .committed:
            handleComittedState()
        case .loading:
            handleLoadingState()
        }
    }
    
    private func handleStoppedState() {
        setLayoutStopped()
        delegate?.didStop()
    }
    
    private func handleComittedState() {
        setLayoutCommitted()
        delegate?.didCommit()
    }
    
    private func handleLoadingState() {
        setLayoutLoading()
        delegate?.didBeginLoading()
    }

    private func setLayoutStopped() {
        self.label.text = stoppedTitle
        self.activityIndicator.stopAnimating()
    }

    private func setLayoutCommitted() {
        self.label.text = triggeredTitle
        self.activityIndicator.stopAnimating()
    }

    private func setLayoutLoading() {
        self.label.text = nil
        self.activityIndicator.startAnimating()
    }

    // MARK: Actions
    public func startAnimating() {
        self.state = .loading
    }

    public func stopAnimating() {
        self.state = .stopped
    }

}
