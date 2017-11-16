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

    var start: [Int] = [0]
    var aggrs: [String] = []

    let decoder: Decoder = Decoder()
    
    var indexOfPageRequest = 1
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var categoriesButton: UIBarButtonItem!
    @IBOutlet weak var filterButton: UIBarButtonItem!
    
    var city: String = uds.value(forKey: "city") as! String
    
    var categoryName: String = ""

    var nameEvent: [String] = []
    var eventDescription: [String] = []
    var startEventTime: [String] = []
    var id: [String] = []
    var isFree: [String] = []
    var target: [String] = []
    var image: [NSData] = []
    
    var category: String = ""
    
    var refresher: UIRefreshControl!
    
    let loadDB: LoadDB = LoadDB()
    let manageTimepad: ManageEventTimepad = ManageEventTimepad()
    let manageKudaGo: ManageEventKudaGO = ManageEventKudaGO()
    let managePonaminalu: ManagePonaminaluEvent = ManagePonaminaluEvent()
    let utils:Utils = Utils()
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        
        if category == "" {
            self.navigationItem.title = uds.value(forKey: "city") as! String
        } else {
            self.navigationItem.title = "\(uds.value(forKey: "city") as! String). \(category)"
        }

        loadData()
        // обновление списка мерприятий свайпом вниз
        refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refresher.addTarget(self, action: #selector(loadData), for: UIControlEvents.valueChanged)
        tableView.addSubview(refresher)
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

    func loadData() {
        for name in aggrs {
            print(name)
            refEvent.child("\(uds.value(forKey: "city") as! String)/Events").queryOrdered(byChild: "start_event").queryStarting(atValue: start.last! + 1).queryLimited(toFirst: 20).observeSingleEvent(of: .value, with: { (snapshot) in
                self.start = []
                for val in snapshot.children.allObjects as! [DataSnapshot] {
                    print(val.childSnapshot(forPath: "target").value! as! String)
                    if val.childSnapshot(forPath: "target").value! as! String == name {
                        self.nameEvent.append(val.childSnapshot(forPath: "short_title").value! as! String)
                        self.id.append(val.childSnapshot(forPath: "id").value! as! String)
                        self.eventDescription.append(val.childSnapshot(forPath: "description").value! as! String)
                        self.startEventTime.append(self.decoder.timeConvert(sec: String(val.childSnapshot(forPath: "start_event").value! as! Int)))
                        self.isFree.append(val.childSnapshot(forPath: "is_free").value! as! String)
                        self.image.append( NSData(contentsOf: NSURL(string: val.childSnapshot(forPath: "image").value! as! String)! as URL)!)
                        self.target.append(val.childSnapshot(forPath: "target").value! as! String)
                        self.start.append(Int(val.childSnapshot(forPath: "id").value! as! String)!)
                    }
                }
                self.tableView.reloadData()
            })
        }
        
        
//        if uds.bool(forKey: "switchKudaGO") == true {
//            refEvent.child("\(uds.value(forKey: "city") as! String)/Events/KudaGO").queryOrdered(byChild: "start_event").queryStarting(atValue: Int(startAtK.last!)! + 1).queryLimited(toFirst: 50).observeSingleEvent(of: .value, with: { (snapshot) in
//                self.startAtK = []
//                for val in snapshot.children.allObjects as! [DataSnapshot] {
//                    self.nameEvent.append(val.childSnapshot(forPath: "short_title").value! as! String)
//                    self.id.append(val.childSnapshot(forPath: "id").value! as! String)
//                    self.eventDescription.append(val.childSnapshot(forPath: "description").value! as! String)
//                    self.startEventTime.append(val.childSnapshot(forPath: "start_event").value! as! String)
//                    self.isFree.append(val.childSnapshot(forPath: "is_free").value! as! String)
//                    self.image.append( NSData(contentsOf: NSURL(string: val.childSnapshot(forPath: "image").value! as! String)! as URL)!)
//                    self.target.append("KudaGO")
//                    self.startAtK.append(val.childSnapshot(forPath: "id").value! as! String)
//                }
//                self.tableView.reloadData()
//            })
//        }
//        if uds.bool(forKey: "switchTimaPad") == true {
//            refEvent.child("\(uds.value(forKey: "city") as! String)/Events/TimePad").queryOrdered(byChild: "id").queryStarting(atValue: Int(startAtT.last!)! + 1).queryLimited(toFirst: 20).observeSingleEvent(of: .value, with: { (snapshot) in
//                for val in snapshot.children.allObjects as! [DataSnapshot] {
//                    self.nameEvent.append(val.childSnapshot(forPath: "short_title").value! as! String)
//                    self.id.append(val.childSnapshot(forPath: "id").value! as! String)
//                    self.eventDescription.append(val.childSnapshot(forPath: "description").value! as! String)
//                    self.startEventTime.append(val.childSnapshot(forPath: "start_event").value! as! String)
//                    self.isFree.append(val.childSnapshot(forPath: "is_free").value! as! String)
//                    self.image.append( NSData(contentsOf: NSURL(string: val.childSnapshot(forPath: "image").value! as! String)! as URL)!)
//                    self.target.append("TimePad")
//                    self.startAtT.append(val.childSnapshot(forPath: "id").value! as! String)
//                }
//            })
//        }
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return id.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let eventCell = tableView.dequeueReusableCell(withIdentifier: "eventCell", for: indexPath) as! EventCellTableViewControllerCell
        
        eventCell.headline.text = nameEvent[indexPath.row]
        eventCell.descLable.text = eventDescription[indexPath.row]
        eventCell.timeAtStart.text = startEventTime[indexPath.row]
        eventCell.imageEvent.image = UIImage(data: image[indexPath.row] as Data)
        if isFree[indexPath.row] == "true" {
            eventCell.cost.text = "Бесплатное"
        } else {
            eventCell.cost.text = "Платное"
        }
        
        return eventCell
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastItem = id.count - 1
        print("indexPath.row = \(indexPath.row),lastItem = \(lastItem)")
        if indexPath.row == lastItem {
//            limit += 10
//            loadData()
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detailsEvent" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let destinationVC = segue.destination as! DetailsViewController
                destinationVC.idEvent = id[indexPath.row]
                destinationVC.targetName = target[indexPath.row]
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
