//
//  ViewController.swift
//  EventAggregator
//
//  Created by Egor Bryzgalov on 17.07.17.
//  Copyright © 2017 Egor Bryzgalov. All rights reserved.
//
import Foundation
import UIKit
import SwiftyJSON
import Alamofire
import SWRevealViewController

class SearchTableViewController: UITableViewController, UISearchResultsUpdating {
    
    var searchController = UISearchController()
    @IBOutlet weak var menuButtonTable: UIBarButtonItem!
    
    var result: [String] = []
    var resultId: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sideMenu()
        customizeNavBar()
        //создаем searchController
        searchController = UISearchController(searchResultsController: nil)
//        tableView.tableHeaderView = searchController.searchBar
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.placeholder = "Мы найдём для Вас ..."
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
        self.navigationItem.titleView = searchController.searchBar
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //обработка поисковых запросов агрегаторами
    func updateSearchResults(for searchController: UISearchController) {
        result = []
        resultId = []
        self.tableView.reloadData()
        if uds.bool(forKey: "switchKudaGO") == true {
            searchKudago(txt: searchController.searchBar.text!)
        }
        if uds.bool(forKey: "switchPonaminalu") == true {
            searchPonaminalu(txt: searchController.searchBar.text!)
        }
    }
    // поиск по ресурсу Ponaminalu
    func searchPonaminalu(txt: String) {
        if uds.value(forKey: "regionId") as! String != "" {
            let txtUrl = txt.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
            let url = "https://search.ponominalu.ru/search.php?q=\(txtUrl!)&region_id=\(uds.value(forKey: "regionId") as! String)&promote=69399e321f034b29441a6a525c50a488&format=json"
            Alamofire.request(url, method: .get).validate().responseJSON { response in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    for (_, subJSON) in json["message"] {
                        print(subJSON)
                        self.tableView.reloadData()
                    }
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
    // поиск по ресурсу Кudago
    func searchKudago(txt: String) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        if uds.value(forKey: "citySlug") as! String != "" {
            var txtUrl = txt.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
            if txt.characters.count > 2 {
                Alamofire.request("https://kudago.com/public-api/v1.3/search/?location=\(uds.value(forKey: "citySlug") as! String)&q=\(txtUrl!)&ctype=event", method: .get).validate().responseJSON { response in
                    switch response.result {
                    case .success(let value):
                        let json = JSON(value)
                        for (_, subJSON) in json["results"] {
                            self.result.append(subJSON["title"].stringValue)
                            self.resultId.append(subJSON["id"].stringValue)
                            self.tableView.reloadData()
                            UIApplication.shared.isNetworkActivityIndicatorVisible = false
                        }
                    case .failure(let error):
                        print(error)
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                        let alert = UIAlertController(title: "Упс! 🤦‍♂️ Ошибочка!", message: "Напиши пожалуйста нормальный текст. 😉", preferredStyle: .alert)
                        let action = UIAlertAction(title: "Понял", style: .default) { (action) in
                            self.searchController.searchBar.text! = ""
                            txtUrl = nil
                        }
                        alert.addAction(action)
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            } else {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }
    
    func sideMenu() {
        if revealViewController() != nil {
            menuButtonTable.target = revealViewController()
            menuButtonTable.action = #selector(SWRevealViewController.revealToggle(_:))
            revealViewController().rearViewRevealWidth = 250
            tableView.addGestureRecognizer(self.revealViewController().tapGestureRecognizer())
        }
    }
    
    //Разрисовываем navigationBar
    func customizeNavBar() {
        navigationController?.navigationBar.tintColor = UIColor(colorLiteralRed: 255/255, green: 255/255, blue: 255/255, alpha: 1)
        navigationController?.navigationBar.barTintColor = UIColor(colorLiteralRed: 42/255, green: 26/255, blue: 25/255, alpha: 1)
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
    }
    
    // Количество секций
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    //Колчество показываемых строк в этой секции
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return result.count

    }
    //Эти строки данными
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let searchCell = tableView.dequeueReusableCell(withIdentifier: "searchCell", for: indexPath)
        searchCell.textLabel?.text = result[indexPath.row]
        return searchCell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showSearch" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let destinationVC = segue.destination as! DetailsTableViewController
                destinationVC.searchId = resultId[indexPath.row]
                dismiss(animated: true, completion: nil)
            }
        }
    }
}



