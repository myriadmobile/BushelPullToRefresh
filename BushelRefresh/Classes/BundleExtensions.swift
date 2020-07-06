//
//  BundleExtensions.swift
//  BushelRefresh
//
//  Created by Alex (Work) on 7/6/20.
//

extension Bundle {
    
    static func current() -> Bundle {
        return Bundle(for: DefaultPullToRefreshView.self)
    }
    
    static func resource() -> Bundle? {
        guard let bundleURL = Bundle.current().resourceURL?.appendingPathComponent("BushelRefresh.bundle") else { return nil }
        return Bundle(url: bundleURL)
    }
    
}
