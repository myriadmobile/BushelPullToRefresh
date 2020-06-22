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
        tableView.addPullToRefesh(action: {
            print("Fetching data!")
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.tableView.pullToRefreshView.stopAnimating()
                self.tableView.reloadData()
            }
        }, position: .top)
    }
    
    //Actions
    @IBAction func stop(_ sender: Any) {
        tableView.pullToRefreshView.stopAnimating()
    }
    
    @IBAction func trigger(_ sender: Any) {
        tableView.pullToRefreshView.trigger()
    }
    
    @IBAction func start(_ sender: Any) {
        tableView.pullToRefreshView.startAnimating()
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

