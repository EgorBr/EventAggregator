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
    var target: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Быстрый поиск"
        sideMenu()
        //создаем searchController
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
//        searchController.searchBar.placeholder = "Мы найдём для Вас ..."
        tableView.tableHeaderView = searchController.searchBar
        searchController.hidesNavigationBarDuringPresentation = true
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
            let url = "https://api.cultserv.ru/v4/events/list/?session=\(apiKeyPonaminalu)&title=\(txtUrl!)&region_id=\(uds.value(forKey: "regionId") as! String)&promote=69399e321f034b29441a6a525c50a488"
            Alamofire.request(url, method: .get).validate().responseJSON { response in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    for (_, subJSON) in json["message"] {
                        self.result.append(subJSON["title"].stringValue)
                        self.resultId.append(subJSON["subevents"][0]["id"].stringValue)
                        self.target.append("Ponaminalu")
                        self.tableView.reloadData()
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
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
                            self.target.append("KudaGo")
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
    
    override func viewWillAppear(_ animated: Bool) {
        let view = UIView(frame: CGRect(x: 0.0, y: 0.0, width: UIScreen.main.bounds.size.width, height: 20.0))
        view.backgroundColor = UIColor(red: 70/255, green: 59/255, blue: 58/255, alpha: 1)
        self.navigationController?.view.addSubview(view)
        //Цвет кнопок
        navigationController?.navigationBar.tintColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
        //Цвет navigationBar
        navigationController?.navigationBar.barTintColor = UIColor(red: 42/255, green: 26/255, blue: 25/255, alpha: 1)
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
                let destinationVC = segue.destination as! DetailsViewController
                destinationVC.searchId = resultId[indexPath.row]
                destinationVC.targetName = target[indexPath.row]
                searchController.isActive = false
            }
        }
    }
}



