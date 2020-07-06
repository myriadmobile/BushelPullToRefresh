//
//  ViewController.swift
//  BushelRefresh
//
//  Created by Alex Larson on 06/17/2020.
//  Copyright (c) 2020 Alex Larson. All rights reserved.
//

import UIKit
import BushelRefresh

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    //UI
    @IBOutlet var tableView: UITableView!
    
    //Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        
        //PTR
        addPullToRefresh()
    }
    
    func addPullToRefresh() {
        tableView.addPullToRefresh(action: {
            print("Fetching data!")
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.tableView.pullToRefreshView?.stopAnimating()
                self.tableView.reloadData()
            }
        }, viewType: CustomPTR.self)
    }
    
    //Actions
    @IBAction func stop(_ sender: Any) {
        tableView.pullToRefreshView?.stopAnimating()
    }
    
    @IBAction func start(_ sender: Any) {
        tableView.pullToRefreshView?.startAnimating()
    }
    
    @IBAction func toggleHidden(_ sender: Any) {
        //TODO: This seems heavy handed. Being able to hide it would be ideal, but it makes dealing with insets and offsets quite confusing.
        if tableView.pullToRefreshView == nil {
            addPullToRefresh()
        } else {
            tableView.removePullToRefresh()
        }
    }
    
    @IBAction func newInset(_ sender: Any) {
        let newInset = CGFloat(arc4random() % 100)
        print("New Inset: \(newInset)")
        tableView.contentInset.top = newInset
    }
    
    //TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = "\(arc4random())"
        return cell
    }
    
}


