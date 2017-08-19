//
//  DetailsTableViewController.swift
//  EventAggregator
//
//  Created by Egor Bryzgalov on 25.07.17.
//  Copyright © 2017 Egor Bryzgalov. All rights reserved.
//

import UIKit

class DetailsTableViewController: UITableViewController {
    
    var idEvent: String = ""
    var event: [String] = []
    let loadDB: LoadDB = LoadDB()
    var name: String = ""
    var details: String = ""
    var fullDetails: String = ""
    var start: String = ""
    var end: String = ""
    var org: String = ""
    

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.estimatedRowHeight = 150
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        let event = loadDB.eventDescription(id: idEvent)
        for value in event {
            name = value.name
            details = value.event_description
            fullDetails = value.full_event_description
            start = value.start_time
            end = value.end_time
            org = value.creat_org
        }
//        print(event)
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
        return loadDB.eventDescription(id: idEvent).count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let detailsCell = tableView.dequeueReusableCell(withIdentifier: "detailsCell", for: indexPath)

        let LabelNameDetails: UILabel = detailsCell.viewWithTag(1) as! UILabel
        LabelNameDetails.text = self.name
        
        let LabelFullDetails: UILabel = detailsCell.viewWithTag(2) as! UILabel
        LabelFullDetails.text = self.details+self.fullDetails
//
        let LabelStartDetails: UILabel = detailsCell.viewWithTag(3) as! UILabel
        LabelStartDetails.text = Decoder().dateformatter(date: self.start)
        
        let LabelStopDetails: UILabel = detailsCell.viewWithTag(4) as! UILabel
        LabelStopDetails.text = Decoder().dateformatter(date: self.end)
        
        let LabelOrgDetails: UILabel = detailsCell.viewWithTag(7) as! UILabel
        LabelOrgDetails.text = self.org

        return detailsCell
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
