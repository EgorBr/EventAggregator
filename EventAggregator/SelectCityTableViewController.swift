//
//  SelectCityTableViewController.swift
//  EventAggregator
//
//  Created by Egor Bryzgalov on 26.08.17.
//  Copyright © 2017 Egor Bryzgalov. All rights reserved.
//

import UIKit

class SelectCityTableViewController: UITableViewController, UISearchResultsUpdating {
    
    let loadDB: LoadDB = LoadDB()
    var sityList: [String] = []
    var sortCity: [String] = []
    var filteredCity: [String] = []
    var searchController = UISearchController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchController = UISearchController(searchResultsController: nil)
        tableView.tableHeaderView = searchController.searchBar
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        
        refEvent.observeSingleEvent(of: .value, with: { (snapshot) in
            if let keyValue = snapshot.value as? NSDictionary {
                for getKey in keyValue.allKeys {
                    refEvent.child(getKey as! String).observeSingleEvent(of: .value, with: { (snapshot) in
                        if let tmpName = snapshot.value as? NSDictionary {
                            let subtmpname = tmpName["NAME"] as? String ?? ""
                            self.sityList.append(subtmpname)
                            self.sortCity = self.sityList.sorted(by: < )
                            self.tableView.reloadData()
                        }
                    })
                }
            }
        })
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        filteredCity = sityList.filter({ (sityList:String) -> Bool in
            if sityList.contains(searchController.searchBar.text!) {
                return true
            } else {
                return false
            }
        })
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    // Количество секций
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    //Колчество показываемых строк в этой секции
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive {
            return filteredCity.count
        } else {
            return sityList.count
        }
//
    }
    //Эти строки данными
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cityCell", for: indexPath)
        if searchController.isActive {
            cell.textLabel?.text = filteredCity.sorted(by: < )[indexPath.row]
        } else {
            cell.textLabel?.text = sortCity[indexPath.row]
        }

        return cell
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "select" {
            if let indexPath = tableView.indexPathForSelectedRow {
                if searchController.isActive {
                    let destinationVC = segue.destination as! SettingsTableViewController
                    destinationVC.selectCity = filteredCity.sorted(by: < )[indexPath.row]
                    dismiss(animated: true, completion: nil)
                } else {
                    let destinationVC = segue.destination as! SettingsTableViewController
                    destinationVC.selectCity = sortCity[indexPath.row]
                    dismiss(animated: true, completion: nil)
                }
            }
        }
        dismiss(animated: true, completion: nil)
    }
    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
