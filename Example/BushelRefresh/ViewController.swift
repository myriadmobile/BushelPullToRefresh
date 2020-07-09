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
        tableView.addRefresh(id: "pulltorefresh", containerType: RefreshTopContainer.self, viewType: CustomPTR.self) { [weak self] in
            print("Refreshing data!")

            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self?.tableView.refreshView(for: "pulltorefresh")?.stopAnimating()
                self?.tableView.reloadData()
            }
        }
        
        //IL
//        tableView.addRefresh(id: "infiniteloading", containerType: RefreshBottomContainer.self, viewType: CustomPTR.self) { [weak self] in
//            print("Loading more!")
//
//            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//                self?.tableView.refreshView(for: "infiniteloading")?.stopAnimating()
//                self?.tableView.reloadData()
//            }
//        }
    }
    
    //Actions
    @IBAction func stop(_ sender: Any) {
        //NOTE: Order will matter in this case; the last called item will probably take priority
        //This is likely an unrealistic use case
        tableView.refreshView(for: "pulltorefresh")?.stopAnimating()
        tableView.refreshView(for: "infiniteloading")?.stopAnimating()
    }
    
    @IBAction func start(_ sender: Any) {
        //NOTE: Order will matter in this case; the last called item will probably take priority
        //This is likely an unrealistic use case
        tableView.refreshView(for: "pulltorefresh")?.startAnimating()
        tableView.refreshView(for: "infiniteloading")?.startAnimating()
    }
    
    @IBAction func toggleHidden(_ sender: Any) {
        let ptrHidden = tableView.refreshContainer(for: "pulltorefresh")?.isHidden == true
        tableView.refreshContainer(for: "pulltorefresh")?.isHidden = !ptrHidden
        
        let ilHidden = tableView.refreshContainer(for: "infiniteloading")?.isHidden == true
        tableView.refreshContainer(for: "infiniteloading")?.isHidden = !ilHidden
    }
    
    @IBAction func newInset(_ sender: Any) {
        let newInset = CGFloat(arc4random() % 100)
        print("New Inset: \(newInset)")
        tableView.contentInset.top = newInset
        tableView.contentInset.bottom = newInset
    }
    
    //TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 30
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = "\(arc4random())"
        return cell
    }
    
}


