//
//  EventTableViewController.swift
//  EventAggregator
//
//  Created by Egor Bryzgalov on 25.07.17.
//  Copyright © 2017 Egor Bryzgalov. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import RealmSwift
import Firebase
import SWRevealViewController

class EventTableViewController: UITableViewController {

    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var categoriesButton: UIBarButtonItem!
    @IBOutlet weak var filterButton: UIBarButtonItem!
    
    var city: String = uds.value(forKey: "city") as! String
    var source = [Variables]()
    var currentScore:Int!
    var currentKey:String!
    
    var aggrs: [String] = []
    var category: String!
    var categoryName: String!
    
    var date: String!
    var cost: String!
    var filterSort: Int!
    
    
    private var refresher: UIRefreshControl!
    let utils: Utils = Utils()
    let decoder: Decoder = Decoder()
    let spinner = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // обновление списка мерприятий свайпом вниз
        refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString(string: "Сбросил все фильтры. Подождите ... ")
        refresher.addTarget(self, action: #selector(EventTableViewController.refreshLoad), for: .valueChanged)
        tableView.addSubview(refresher)
        
        if uds.bool(forKey: "switchPonaminalu") == true {
            aggrs.append("Ponaminalu")
        }
        if uds.bool(forKey: "switchKudaGO") == true {
            aggrs.append("KudaGo")
        }
        if uds.bool(forKey: "switchTimaPad") == true {
            aggrs.append("TimePad")
        }
        
        self.tableView.estimatedRowHeight = 3
        self.tableView.rowHeight = UITableViewAutomaticDimension
        sideMenu()
        
        if category == nil {
            self.navigationItem.title = uds.value(forKey: "city") as! String
            loadListEvent()
        } else {
            self.navigationItem.title = "\(uds.value(forKey: "city") as! String). \(category!)"
            resetVariables()
            loadCategoryEvent()
        }
    }

    
    // выводим краткую инфу по мероприятиям в зависимости отквключенных агрегаторов
    
    func sideMenu() {
        if revealViewController() != nil {
            menuButton.target = revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            revealViewController().rearViewRevealWidth = 250
            categoriesButton.target = revealViewController()
            categoriesButton.action = #selector(SWRevealViewController.rightRevealToggle(_:))
            revealViewController().rightViewRevealWidth = 300
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
    
    func refreshLoad() {
        source = []
        self.tableView.reloadData()
        refEvent.child("\(uds.value(forKey: "city") as! String)/Events/").queryOrdered(byChild: "start_event").queryLimited(toFirst: (UInt(18 / aggrs.count))).observeSingleEvent(of: .value, with: { (snapshot:DataSnapshot) in
            if snapshot.childrenCount > 0 {
                let first = snapshot.children.allObjects.last as! DataSnapshot
                for s in snapshot.children.allObjects as! [DataSnapshot]{
                    let item = s.value as! Dictionary<String,AnyObject?>
                    let variables = Variables(dict: item as Dictionary<String,AnyObject>)
                    self.source.append(variables)
                }
                self.currentKey = first.key
                self.currentScore = first.childSnapshot(forPath: "start_event").value as! Int
                self.refresher.endRefreshing()
                self.tableView.reloadData()
                
            }
        })
        
    }

    func loadListEvent() {
            if currentKey == nil {
                utils.showActivityIndicator(uiView: self.view)
                refEvent.child("\(uds.value(forKey: "city") as! String)/Events/").queryOrdered(byChild: "start_event").queryLimited(toFirst: 20).observeSingleEvent(of: .value, with: { (snapshot:DataSnapshot) in
                    if snapshot.childrenCount > 0 {
                        let first = snapshot.children.allObjects.last as! DataSnapshot
                        for s in snapshot.children.allObjects as! [DataSnapshot]{
                            let item = s.value as! Dictionary<String,AnyObject?>
                            let variables = Variables(dict: item as Dictionary<String,AnyObject>)
                            if uds.bool(forKey: "switchKudaGO") == true {
                                if variables._id.characters.last! == "K" {
                                    self.source.append(variables)
                                }
                            }
                            if uds.bool(forKey: "switchPonaminalu") == true {
                                if variables._id.characters.last! == "P" {
                                    self.source.append(variables)
                                }
                            }
                            if uds.bool(forKey: "switchTimaPad") == true {
                                if variables._id.characters.last! == "T" {
                                    self.source.append(variables)
                                }
                            }
                        }
                        self.currentKey = first.key
                        self.currentScore = first.childSnapshot(forPath: "start_event").value as! Int
                        self.tableView.reloadData()
                        self.utils.hideActivityIndicator(uiView: self.view)
                    } else {
                        self.utils.hideActivityIndicator(uiView: self.view)
                        self.showAlert(message: "Ничего нет, но сейчас все загрузим")
                        if uds.bool(forKey: "switchKudaGO") == true {
                            ManageEventKudaGO().loadEventKudaGO()
                        }
                        if uds.bool(forKey: "switchPonaminalu") == true {
                            ManagePonaminaluEvent().loadEventPonaminalu()
                        }
                        if uds.bool(forKey: "switchTimaPad") == true {
                            ManageEventTimepad().loadTimePadEvent()
                        }
                        refEvent.child("\(uds.value(forKey: "city") as! String)/lastLoad").setValue(Int(NSDate().timeIntervalSince1970))
                    }
                })
            } else {
                refEvent.child("\(uds.value(forKey: "city") as! String)/Events/").queryStarting(atValue: self.currentScore).queryOrdered(byChild: "start_event").queryLimited(toFirst:20).observeSingleEvent(of: .value, with: { (snapshot:DataSnapshot) in
                    if snapshot.childrenCount > 0 {
                        let first = snapshot.children.allObjects.last as! DataSnapshot
                        for s in snapshot.children.allObjects as! [DataSnapshot]{
                            if s.key != self.currentKey {
                                let item = s.value as! Dictionary<String,AnyObject?>
                                let variables = Variables(dict: item as Dictionary<String,AnyObject>)
                                if uds.bool(forKey: "switchKudaGO") == true {
                                    if variables._id.characters.last! == "K" {
                                        self.source.append(variables)
                                    }
                                }
                                if uds.bool(forKey: "switchPonaminalu") == true {
                                    if variables._id.characters.last! == "P" {
                                        self.source.append(variables)
                                    }
                                }
                                if uds.bool(forKey: "switchTimaPad") == true {
                                    if variables._id.characters.last! == "T" {
                                        self.source.append(variables)
                                    }
                                }
                            }
                        }
                        self.currentKey = first.key
                        self.currentScore = first.childSnapshot(forPath: "start_event").value as! Int
                        self.tableView.reloadData()
                    }
                    self.spinner.stopAnimating()
                    self.tableView.tableFooterView = nil
                })
            }
    }
    
    
    func loadFilteredListEvent(cost: String, date: Int) {
            if currentKey == nil {
                utils.showActivityIndicator(uiView: self.view)
                refEvent.child("\(uds.value(forKey: "city") as! String)/Events/").queryOrdered(byChild: "start_event").observeSingleEvent(of: .value, with: { (snapshot:DataSnapshot) in
                    if snapshot.childrenCount > 0 {
                        for s in snapshot.children.allObjects as! [DataSnapshot] {
                            if self.source.count < (UInt(18 / self.aggrs.count)) {
                                if Int(cost)! != 0 && date == 0 {
                                    if (s.childSnapshot(forPath: "min").value as! Int) < Int(cost)! {
                                        let item = s.value as! Dictionary<String,AnyObject?>
                                        let variables = Variables(dict: item as Dictionary<String,AnyObject>)
                                        self.source.append(variables)
                                    }
                                }
                                if date != 0 && Int(cost)! == 0 {
                                    if (s.childSnapshot(forPath: "start_event").value as! Int) <= date {
                                        let item = s.value as! Dictionary<String,AnyObject?>
                                        let variables = Variables(dict: item as Dictionary<String,AnyObject>)
                                        self.source.append(variables)
                                    }
                                }
                                if date != 0 && Int(cost)! != 0 {
                                    print(s.childSnapshot(forPath: "start_event").value as! Int)
                                    print(date)
                                    print(s.childSnapshot(forPath: "min").value as! Int)
                                    print(cost)
                                    if (s.childSnapshot(forPath: "start_event").value as! Int) <= date && (s.childSnapshot(forPath: "min").value as! Int) <= Int(cost)! {
                                        print("WTF!?")
                                        let item = s.value as! Dictionary<String,AnyObject?>
                                        let variables = Variables(dict: item as Dictionary<String,AnyObject>)
                                        self.source.append(variables)
                                    }
                                }
                            } else {
                                break
                            }
                        }
                        self.currentKey = self.source.last?._id
                        self.currentScore = self.decoder.dfTP(time: (self.source.last?._startEventTime)!)
                        self.tableView.reloadData()
                        self.utils.hideActivityIndicator(uiView: self.view)
                    }
                })
            } else {
                refEvent.child("\(uds.value(forKey: "city") as! String)/Events/").queryStarting(atValue: self.currentScore).queryOrdered(byChild: "start_event").queryLimited(toFirst: (UInt(18 / aggrs.count))).observeSingleEvent(of: .value, with: { (snapshot:DataSnapshot) in
                    if snapshot.childrenCount > 0 {
                        let last = snapshot.children.allObjects.last as! DataSnapshot
                        for s in snapshot.children.allObjects as! [DataSnapshot]{
                            if s.key != self.currentKey {
                                if Int(cost)! != 0 && date == 0 {
                                    if (s.childSnapshot(forPath: "min").value as! Int) < Int(cost)! {
                                        let item = s.value as! Dictionary<String,AnyObject?>
                                        let variables = Variables(dict: item as Dictionary<String,AnyObject>)
                                        self.source.append(variables)
                                    }
                                }
                                if date != 0 && Int(cost)! == 0 {
                                    if (s.childSnapshot(forPath: "start_event").value as! Int) <= date {
                                        let item = s.value as! Dictionary<String,AnyObject?>
                                        let variables = Variables(dict: item as Dictionary<String,AnyObject>)
                                        self.source.append(variables)
                                    }
                                }
                                if date != 0 && Int(cost)! != 0 {
                                    if (s.childSnapshot(forPath: "start_event").value as! Int) <= date && (s.childSnapshot(forPath: "min").value as! Int) < Int(cost)! {
                                        let item = s.value as! Dictionary<String,AnyObject?>
                                        let variables = Variables(dict: item as Dictionary<String,AnyObject>)
                                        self.source.append(variables)
                                    }
                                }
                            }
                        }
                        self.currentKey = last.key
                        self.currentScore = last.childSnapshot(forPath: "start_event").value as! Int
                        self.tableView.reloadData()
                    }
                    self.spinner.stopAnimating()
                    self.tableView.tableFooterView = nil
                })
            }
        
    }
    
    func loadCategoryEvent() {
        if currentKey == nil {
            utils.showActivityIndicator(uiView: self.view)
            refEvent.child("\(uds.value(forKey: "city") as! String)/Events/").queryOrdered(byChild: "start_event").observeSingleEvent(of: .value, with: { (snapshot:DataSnapshot) in
                if snapshot.childrenCount > 0 {
                    for s in snapshot.children.allObjects as! [DataSnapshot] {
                        if self.source.count < (UInt(18 / self.aggrs.count)) {
                            if s.childSnapshot(forPath: "categories").value as! String == self.categoryName {
                                let item = s.value as! Dictionary<String,AnyObject?>
                                let variables = Variables(dict: item as Dictionary<String,AnyObject>)
                                self.source.append(variables)
                            }
                        } else {
                            break
                        }
                    }
                    if self.source.count > 0 {
                        self.currentKey = self.source.last?._id
                        self.currentScore = self.decoder.dfTP(time: (self.source.last?._startEventTime)!)
                        self.utils.hideActivityIndicator(uiView: self.view)
                        self.tableView.reloadData()
                    } else {
                        self.utils.hideActivityIndicator(uiView: self.view)
                        self.showAlertPlace()
                    }
                }
            })
        } else {
            refEvent.child("\(uds.value(forKey: "city") as! String)/Events/").queryStarting(atValue: self.currentScore).queryOrdered(byChild: "start_event").queryLimited(toFirst: (UInt(18 / aggrs.count))).observeSingleEvent(of: .value, with: { (snapshot:DataSnapshot) in
                if snapshot.childrenCount > 0 {
                    let last = snapshot.children.allObjects.last as! DataSnapshot
                    for s in snapshot.children.allObjects as! [DataSnapshot]{
                        if s.key != self.currentKey {
                            if s.childSnapshot(forPath: "categories").value as! String == self.categoryName {
                                let item = s.value as! Dictionary<String,AnyObject?>
                                let variables = Variables(dict: item as Dictionary<String,AnyObject>)
                                self.source.append(variables)
                            }
                        }
                    }
                    self.currentKey = last.key
                    self.currentScore = last.childSnapshot(forPath: "start_event").value as! Int
                    self.tableView.reloadData()
                }
                self.spinner.stopAnimating()
                self.tableView.tableFooterView = nil
            })
        }
    }
    
    func resetVariables() {
        source = []
        currentScore = nil
        currentKey = nil
        self.tableView.reloadData()
    }
    
    func showAlertPlace() {
        let alert = UIAlertController(title: nil, message: "Прости, но ничего нет. Давай посмотрим что-нибудь ещё!?", preferredStyle: .alert)
        let action = UIAlertAction(title: "Ок", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return source.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let eventCell = tableView.dequeueReusableCell(withIdentifier: "eventCell", for: indexPath) as! EventCellTableViewControllerCell
        eventCell.headline.text = source[indexPath.row]._nameEvent
        eventCell.descLable.text = source[indexPath.row]._eventDescription
        eventCell.timeAtStart.text = source[indexPath.row]._startEventTime
        eventCell.imageEvent.image = UIImage(data: source[indexPath.row]._image as Data)
        eventCell.cost.text = source[indexPath.row]._isFree
        return eventCell
    }
    
    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let currentOffset = scrollView.contentOffset.y
        let maxOffset = scrollView.contentSize.height - scrollView.frame.height
        if maxOffset - currentOffset <= 44 && self.source.count != 0 {
            spinner.startAnimating()
            spinner.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: tableView.bounds.width * 2, height: CGFloat(44))
            tableView.tableFooterView = self.spinner
            tableView.tableFooterView?.isHidden = false
            if cost != nil {
                self.loadFilteredListEvent(cost: cost, date: 0)
            } else if date != nil {
                self.loadFilteredListEvent(cost: String(0), date: self.decoder.timeConvertToSec(startTime: date, from: "filter"))
            } else if date != nil && cost != nil {
                self.loadFilteredListEvent(cost: cost, date: self.decoder.timeConvertToSec(startTime: date, from: "filter"))
            } else if categoryName != nil {
                self.loadCategoryEvent()
            } else {
                self.loadListEvent()
            }
            
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detailsEvent" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let destinationVC = segue.destination as! DetailsViewController
                destinationVC.idEvent = self.source[indexPath.row]._id
                if self.source[indexPath.row]._id.characters.last! == "K" {
                    destinationVC.targetName = "KudaGo"
                } else if self.source[indexPath.row]._id.characters.last! == "P" {
                    destinationVC.targetName = "Ponaminalu"
                } else {
                    destinationVC.targetName = "TimePad"
                }
            }
        }
        if segue.identifier == "setFilter" {
            let destinationVC = segue.destination as! SetFilterViewController
            if cost != nil {
                destinationVC.switchStatus = true
                destinationVC.cost = cost
            }
            if date != nil {
                destinationVC.date = date
            }
        }
    }
    
    @IBAction func unwindApplyFilter(_ sender: UIStoryboardSegue) {
        guard let filterVC = sender.source as? SetFilterViewController else { return }
        if filterVC.dateField.text! != "" && filterVC.maxCost.text! == "" {
            date = filterVC.dateField.text
            cost = nil
            if date != nil {
                resetVariables()
                loadFilteredListEvent(cost: String(0), date: self.decoder.timeConvertToSec(startTime: date, from: "filter"))
            }
        } else if filterVC.maxCost.text! != "" && filterVC.dateField.text! == "" {
            cost = filterVC.maxCost.text
            date = nil
            if cost != nil {
                resetVariables()
                loadFilteredListEvent(cost: cost, date: 0)
            }
        } else if filterVC.maxCost.text! != "" && filterVC.dateField.text! != "" {
            date = filterVC.dateField.text
            cost = filterVC.maxCost.text
            if cost != nil && date != nil {
                resetVariables()
                loadFilteredListEvent(cost: cost, date: self.decoder.timeConvertToSec(startTime: date, from: "filter"))
            }
        }
    }
    func showAlert(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ок", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
        
    }
 }

class EventCellTableViewControllerCell: UITableViewCell {
    @IBOutlet weak var imageEvent: UIImageView!
    @IBOutlet weak var headline: UILabel!
    @IBOutlet weak var descLable: UILabel!
    @IBOutlet weak var timeAtStart: UILabel!
    @IBOutlet weak var cost: UILabel!
}
