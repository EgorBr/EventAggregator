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
    
    private var refresher: UIRefreshControl!
    let utils: Utils = Utils()
    let decoder: Decoder = Decoder()
    let spinner = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // обновление списка мерприятий свайпом вниз
        refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString(string: "Pull to refresh")
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
        } else {
            self.navigationItem.title = "\(uds.value(forKey: "city") as! String). \(category)"
        }

        loadListEvent()

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
        for aggregator in aggrs {
            refEvent.child("\(uds.value(forKey: "city") as! String)/Events/\(aggregator)").queryOrdered(byChild: "start_event").queryLimited(toFirst: (UInt(18 / aggrs.count))).observeSingleEvent(of: .value, with: { (snapshot:DataSnapshot) in
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
    }

    func loadListEvent() {
        for aggregator in aggrs {
            if currentKey == nil {
                utils.showActivityIndicator(uiView: self.view)
                refEvent.child("\(uds.value(forKey: "city") as! String)/Events/\(aggregator)").queryOrdered(byChild: "start_event").queryLimited(toFirst: (UInt(18 / aggrs.count))).observeSingleEvent(of: .value, with: { (snapshot:DataSnapshot) in
                    if snapshot.childrenCount > 0 {
                        let first = snapshot.children.allObjects.last as! DataSnapshot
                        for s in snapshot.children.allObjects as! [DataSnapshot]{
                            let item = s.value as! Dictionary<String,AnyObject?>
                            let variables = Variables(dict: item as Dictionary<String,AnyObject>)
                            self.source.append(variables)
                        }
                        self.currentKey = first.key
                        self.currentScore = first.childSnapshot(forPath: "start_event").value as! Int
                        self.tableView.reloadData()
                        self.utils.hideActivityIndicator(uiView: self.view)
                    }
                })
            } else {
                refEvent.child("\(uds.value(forKey: "city") as! String)/Events/\(aggregator)").queryStarting(atValue: self.currentScore).queryOrdered(byChild: "start_event").queryLimited(toFirst: (UInt(18 / aggrs.count))).observeSingleEvent(of: .value, with: { (snapshot:DataSnapshot) in
                    if snapshot.childrenCount > 0 {
                        let first = snapshot.children.allObjects.last as! DataSnapshot
                        for s in snapshot.children.allObjects as! [DataSnapshot]{
                            if s.key != self.currentKey {
                                let item = s.value as! Dictionary<String,AnyObject?>
                                let variables = Variables(dict: item as Dictionary<String,AnyObject>)
                                self.source.append(variables)
//                                self.source.insert(variables, at: self.source.count)
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
            tableView.tableFooterView = spinner
            tableView.tableFooterView?.isHidden = false
            self.loadListEvent()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detailsEvent" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let destinationVC = segue.destination as! DetailsViewController
                destinationVC.idEvent = self.source[indexPath.row]._id
                destinationVC.targetName = self.source[indexPath.row]._target
            }
        }
    }
 }

class EventCellTableViewControllerCell: UITableViewCell {
    @IBOutlet weak var imageEvent: UIImageView!
    @IBOutlet weak var headline: UILabel!
    @IBOutlet weak var descLable: UILabel!
    @IBOutlet weak var timeAtStart: UILabel!
    @IBOutlet weak var cost: UILabel!
}
