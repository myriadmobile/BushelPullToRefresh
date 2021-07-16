//
//  DefaultInfiniteLoadingView.swift
//  BushelRefresh
//
//  Created by Alex Larson on 7/16/21.
//

import Foundation

public class DefaultInfiniteLoadingView: UIView, RefreshView {

    // MARK: UI
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    // MARK: State
    public var delegate: RefreshDelegate?

    private var lastSetState: RefreshState?
    public var state: RefreshState = .stopped {
        didSet {
            // Only update the layout if the state changes. This mitigates the risk of abnormal layout issues (like duplicated or stuttering animations).
            guard state != lastSetState else { return }
            lastSetState = state
            refreshLayout()
        }
    }

    // MARK: Initialization
    public static func createView() -> RefreshView {
        let view = UINib(nibName: "DefaultInfiniteLoadingView", bundle: .bushelRefresh).instantiate(withOwner: nil, options: nil)[0] as! DefaultInfiniteLoadingView
        return view
    }

    public override func awakeFromNib() {
        super.awakeFromNib()
        style()
    }
    
    private func style() {
        styleView()
        styleActivityIndicator()
    }
    
    private func styleView() {
        backgroundColor = .clear
    }
    
    private func styleActivityIndicator() {
        activityIndicator.style = .gray
    }

    // MARK: Layout
    public func refreshLayout() {
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
        self.activityIndicator.isHidden = true
        self.activityIndicator.stopAnimating()
    }

    private func setLayoutCommitted() {
        self.activityIndicator.isHidden = true
        self.activityIndicator.stopAnimating()
    }

    private func setLayoutLoading() {
        self.activityIndicator.isHidden = false
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
