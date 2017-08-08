//
//  EventTableViewController.swift
//  EventAggregator
//
//  Created by Egor Bryzgalov on 25.07.17.
//  Copyright © 2017 Egor Bryzgalov. All rights reserved.
//

import UIKit

class EventTableViewController: UITableViewController {
    
    var city: String = ""
    var nameEvent: [String] = []
    var eventDescription: [String] = []
    var startEventTime: [String] = []
    var id: [String] = []
    let loadDB: LoadDB = LoadDB()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.estimatedRowHeight = 15
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        let eventDB = loadDB.Event(name: city)
        for value in eventDB[0].eventList {
            nameEvent.append(value.name)
            eventDescription.append(value.event_description)
            startEventTime.append(value.start_time)
            id.append(value.timepad_id)
        }
        

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
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
        return nameEvent.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let eventCell = tableView.dequeueReusableCell(withIdentifier: "eventCell", for: indexPath)
        //eventCell.textLabel?.text = self.nameEvent[indexPath.row]
        //eventCell.detailTextLabel?.text = self.eventDescription[indexPath.row]
        
        let labelName: UILabel = eventCell.viewWithTag(1) as! UILabel
        labelName.text = self.nameEvent[indexPath.row]
        
        let labelDesc: UILabel = eventCell.viewWithTag(2) as! UILabel
        labelDesc.text = self.eventDescription[indexPath.row]
        
        let labelStart: UILabel = eventCell.viewWithTag(3) as! UILabel
        labelStart.text = Decoder().dateformatter(date: self.startEventTime[indexPath.row])
        
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
