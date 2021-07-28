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
    let loadingTitle = "Loading..."

    // MARK: UI
    @IBOutlet var label: UILabel!
    @IBOutlet var arrowImageView: UIImageView!
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
        styleArrow()
        styleActivityIndicator()
    }

    private func styleView() {
        backgroundColor = .clear
    }

    private func styleLabel() {
        label.textColor = .darkGray
    }

    private func styleArrow() {
        arrowImageView.image = UIImage(named: "Arrow", in: .resources, compatibleWith: nil)
        setArrowColor(.gray)
    }

    private func styleActivityIndicator() {
        activityIndicator.style = .gray
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
        self.arrowImageView.isHidden = false
        self.setArrowOrientation(isStopped: true, animated: true)
        self.activityIndicator.isHidden = true
        self.activityIndicator.stopAnimating()
    }

    private func setLayoutCommitted() {
        self.label.text = triggeredTitle
        self.arrowImageView.isHidden = false
        self.setArrowOrientation(isStopped: false, animated: true)
        self.activityIndicator.isHidden = true
        self.activityIndicator.stopAnimating()
    }

    private func setLayoutLoading() {
        self.label.text = loadingTitle
        self.arrowImageView.isHidden = true
        self.setArrowOrientation(isStopped: true, animated: false)
        self.activityIndicator.isHidden = false
        self.activityIndicator.startAnimating()
    }

    private func setArrowColor(_ color: UIColor) {
        arrowImageView.image = arrowImageView.image?.withRenderingMode(.alwaysTemplate)
        arrowImageView.tintColor = color
    }

    private func setArrowOrientation(isStopped: Bool, animated: Bool) {
        let shouldPointUp = !isStopped
        let orientation = orientationInRadians(shouldPointUp: shouldPointUp)
        let animationDuration = animated ? 0.2 : 0
        
        UIView.animate(withDuration: animationDuration, delay: 0, options: [.allowUserInteraction], animations: {
            self.arrowImageView.layer.transform = CATransform3DMakeRotation(orientation, 0, 0, 1);
        })
    }
    
    private func orientationInRadians(shouldPointUp: Bool) -> CGFloat{
        let degrees: CGFloat = shouldPointUp ? 0 : 180
        return degrees * .pi / 180
    }

    // MARK: Actions
    public func startAnimating() {
        self.state = .loading
    }

    public func stopAnimating() {
        self.state = .stopped
    }

}
