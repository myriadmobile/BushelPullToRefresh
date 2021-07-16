//
//  ViewController.swift
//  BushelRefresh
//
//  Created by Alex Larson on 06/17/2020.
//  Copyright (c) 2020 Alex Larson. All rights reserved.
//

import UIKit
import BushelRefresh

class ViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTable()
        addPullToRefresh()
        addInfiniteScrolling()
    }
    
    private func setupTable() {
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    private func addPullToRefresh() {
        tableView.addPullToRefresh { [weak self] in
            self?.pullToRefreshAction()
        }
    }
    
    private func addInfiniteScrolling() {
        tableView.addInfiniteScrolling { [weak self] in
            self?.infiniteScrollingAction()
        }
    }
    
    private func pullToRefreshAction() {
        print("Refreshing data!")

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.tableView.pullToRefreshView?.stopAnimating()
            self.tableView.reloadData()
        }
    }
    
    private func infiniteScrollingAction() {
        print("Loading more!")

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.tableView.infiniteScrollingView?.stopAnimating()
            self.tableView.reloadData()
        }
    }
    
    // MARK: Button Actions
    // TODO: Separate start and stop functions
    @IBAction func stop(_ sender: Any) {
        //NOTE: Order will matter in this case; the last called item will probably take priority
        //This is likely an unrealistic use case
        tableView.pullToRefreshView?.stopAnimating()
        tableView.infiniteScrollingView?.stopAnimating()
    }
    
    @IBAction func start(_ sender: Any) {
        //NOTE: Order will matter in this case; the last called item will probably take priority
        //This is likely an unrealistic use case
        tableView.pullToRefreshView?.startAnimating()
        tableView.infiniteScrollingView?.startAnimating()
    }
    
    @IBAction func toggleHidden(_ sender: Any) {
        tableView.pullToRefreshContainer?.isHidden = !isPullToRefreshHidden()
        tableView.infiniteScrollingContainer?.isHidden = !isInfiniteScrollingHidden()
    }
    
    private func isPullToRefreshHidden() -> Bool {
        return tableView.pullToRefreshContainer?.isHidden == true
    }
    
    private func isInfiniteScrollingHidden() -> Bool {
        return tableView.infiniteScrollingContainer?.isHidden == true
    }
    
    @IBAction func newInset(_ sender: Any) {
        let newInset = randomInset()
        tableView.contentInset.top = newInset
        tableView.contentInset.bottom = newInset
        
        print("New Inset: \(newInset)")
    }
    
    private func randomInset() -> CGFloat {
        return CGFloat(arc4random() % 100)
    }
        
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 30
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = "\(arc4random())"
        return cell
    }
    
}
