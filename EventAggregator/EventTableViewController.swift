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
    
    var city: String = uds.value(forKey: "globalCity") as! String
    var nameEvent: [String] = []
    var eventDescription: [String] = []
    var startEventTime: [String] = []
    var id: [String] = []
    var isFree: [String] = []
//    var indexEv: [String] = []
    
    
    let loadDB: LoadDB = LoadDB()
    let manageDate = ManageEventTimepad()
    let manageKudaGo: ManageEventKudaGO = ManageEventKudaGO()
    let utils:Utils = Utils()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        utils.getKeyEvents()
        
        sideMenu()
        customizeNavBar()
        
        self.navigationItem.title = uds.value(forKey: "globalCity") as! String
        
        self.tableView.estimatedRowHeight = 15
        self.tableView.rowHeight = UITableViewAutomaticDimension
            
        load()
    
    }
    
    func load() {
        refEvent.child(uds.value(forKey: "globalCityKey") as! String).child("Events").observeSingleEvent(of: .value, with: { (snapshot) in
            var tmpName: [String] = []
            var tmpId: [String] = []
            var tmpEventDescription: [String] = []
            var tmpStartEventTime: [String] = []
            var tmpIsFree: [String] = []
            for val in snapshot.children {
                tmpName.append((val as AnyObject).childSnapshot(forPath: "short_title").value as! String)
                tmpId.append((val as AnyObject).childSnapshot(forPath: "id").value as! String)
                tmpEventDescription.append((val as AnyObject).childSnapshot(forPath: "description").value as! String)
                tmpStartEventTime.append((val as AnyObject).childSnapshot(forPath: "start_event").value as! String)
                tmpIsFree.append((val as AnyObject).childSnapshot(forPath: "is_free").value as! String)
            }
            self.nameEvent = tmpName
            self.id = tmpId
            self.startEventTime = tmpStartEventTime
            self.isFree = tmpIsFree
            self.eventDescription = tmpEventDescription
            self.tableView.reloadData()
        })
        
//        let eventDB = loadDB.Event(name: city)
//        print(city)
//        for value in eventDB[0].eventList {
//            self.nameEvent.append(value.name)
//            self.eventDescription.append(value.event_description)
//            self.startEventTime.append(value.start_time)
//            self.id.append(value.timepad_id)
//        }
    }
    
    func sideMenu() {
        if revealViewController() != nil {
            menuButton.target = revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            revealViewController().rearViewRevealWidth = 250
            view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
    }
    //Разрисовываем navigationBar
    func customizeNavBar() {
        //Цвет кнопки меню
        navigationController?.navigationBar.tintColor = UIColor(colorLiteralRed: 255/255, green: 255/255, blue: 255/255, alpha: 1)
        //Цвет navigationBar
        navigationController?.navigationBar.barTintColor = UIColor(colorLiteralRed: 255/255, green: 150/255, blue: 35/255, alpha: 1)
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return id.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let eventCell = tableView.dequeueReusableCell(withIdentifier: "eventCell", for: indexPath)

        let labelName: UILabel = eventCell.viewWithTag(1) as! UILabel
        labelName.text = self.nameEvent[indexPath.row]
        
        let labelDesc: UILabel = eventCell.viewWithTag(2) as! UILabel
        labelDesc.text = self.eventDescription[indexPath.row]
        
        let labelStart: UILabel = eventCell.viewWithTag(3) as! UILabel
        labelStart.text = self.startEventTime[indexPath.row]
        
        return eventCell
    }
 

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

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detailsEvent" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let destinationVC = segue.destination as! DetailsTableViewController
                destinationVC.idEvent = id[indexPath.row]
            }
        }
    }
 

}
