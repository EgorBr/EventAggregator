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
        self.navigationItem.title = "Ваш город"
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        //делаем поиск
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        tableView.tableHeaderView = searchController.searchBar
        searchController.hidesNavigationBarDuringPresentation = false

        if let textfield = searchController.searchBar.value(forKey: "searchField") as? UITextField {
            textfield.textColor = UIColor.black // Цвет текста в searchbar
            if let backgroundview = textfield.subviews.first {
                // задаём цвет фона searchbar
                backgroundview.backgroundColor = UIColor.white
                // делаем круглым searchbar
                backgroundview.layer.cornerRadius = 9;
                backgroundview.clipsToBounds = true;
            }
        }
        
        //заполняем массив с городами
        refEvent.observeSingleEvent(of: .value, with: { (snapshot) in
            if let keyValue = snapshot.value as? NSDictionary {
                for getKey in keyValue.allKeys {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = true
                    self.sityList.append(getKey as! String)
                    self.sortCity = self.sityList.sorted(by: < )
                    self.tableView.reloadData()
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }
            }
        })
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    //делаем поиск в массиве и формируем новый отсортированный
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
    //Колчество показываемых строк в этой секции если активен searchController из filteredCity, если нет - sityList
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive {
            return filteredCity.count
        } else {
            return sityList.count
        }
//
    }
    //Эти строки данными в 
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cityCell", for: indexPath)
        if searchController.isActive {
            cell.textLabel?.text = filteredCity.sorted(by: < )[indexPath.row]
        } else {
            cell.textLabel?.text = sortCity[indexPath.row]
        }

        return cell
    }
    //с условием для searchController
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "select" {
            if let indexPath = tableView.indexPathForSelectedRow {
                if searchController.isActive {
                    let destinationVC = segue.destination as! SettingsTableViewController
                    destinationVC.selectCity = filteredCity.sorted(by: < )[indexPath.row]
                    searchController.isActive = false
                } else {
                    let destinationVC = segue.destination as! SettingsTableViewController
                    destinationVC.selectCity = sortCity[indexPath.row]
                    searchController.isActive = false
                }
            }
        }
    }
}
