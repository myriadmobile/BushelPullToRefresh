//
//  BundleExtensions.swift
//  BushelRefresh
//
//  Created by Alex (Work) on 7/6/20.
//

extension Bundle {
    
    static let bushelRefresh: Bundle = {
        return Bundle(for: DefaultPullToRefreshView.self)
    }()
    
    static let resources: Bundle? = {
        guard let bundleURL = Bundle.bushelRefresh.resourceURL?.appendingPathComponent("BushelRefresh.bundle") else { return nil }
        return Bundle(url: bundleURL)
    }()
    
}
