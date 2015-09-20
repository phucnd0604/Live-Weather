//
//  ViewController.swift
//  LiveWeather
//
//  Created by phuc on 9/19/15.
//  Copyright © 2015 phuc nguyen. All rights reserved.
//

import UIKit
import CoreLocation

var AppmenuItems = [NSDictionary]()
class MenuViewController: UITableViewController {
    
    private let searchController = UISearchController(searchResultsController: nil)
    private var searchResult = [NSDictionary]()
    var selectedIndex: NSIndexPath? = NSIndexPath(forRow: 0, inSection: 0) {
        willSet {
            if let indexPath = selectedIndex,
                cell = tableView.cellForRowAtIndexPath(indexPath) {
                    cell.backgroundColor = UIColor.clearColor()
            }
        } didSet {
            if let indexPath = selectedIndex,
                cell = tableView.cellForRowAtIndexPath(indexPath) {
                    cell.backgroundColor = UIColor.brownColor()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        // Remove the drop shadow from the navigation bar
        navigationController!.navigationBar.clipsToBounds = true
        title = "Favorite"
        // init menuItem
        guard let amenuItems = NSUserDefaults.standardUserDefaults().arrayForKey(kAppFavoriteCity) as? [NSDictionary] else {
            return
        }
        AppmenuItems = amenuItems
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateMenuItem", name: kMenuItemDidUpdate, object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateMenuItem() {
        tableView.reloadData()
    }
    
    // MARK: - Segues
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        selectedIndex = indexPath
        if indexPath.row == 0 {
            let containerVC = navigationController!.parentViewController as! ContainerViewController
            containerVC.detailViewController!.requestUpdateLocation()
            containerVC.hideOrShowMenu(false, animated: true)
        } else {
            let menuItem = AppmenuItems[indexPath.row - 1]
            (navigationController!.parentViewController as! ContainerViewController).menuItem = menuItem
        }
    }
    
    // MARK: - Table View
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.active {
            return searchResult.count
        } else {
            return AppmenuItems.count + 1
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        // adjust row height so items all fit into view
        return 80
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if searchController.active {
            let cell: UITableViewCell
            if let acell = tableView.dequeueReusableCellWithIdentifier("Cell") {
                cell = acell
            } else {
                cell = UITableViewCell()
            }
            
            let dict = searchResult[indexPath.row]
            cell.textLabel?.text = dict["city"]?.string
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("MenuItemCell") as! MenuItemCell
            if indexPath == selectedIndex! {
                cell.backgroundColor = UIColor.brownColor()
            }
            if indexPath.row == 0 {
                cell.cityName.text = "Current location"
            } else {
                let menuItem = AppmenuItems[indexPath.row - 1]
                cell.configureForMenuItem(menuItem)
            }
            return cell
        }
    }
    
}

extension MenuViewController: UISearchResultsUpdating {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        
    }
}

