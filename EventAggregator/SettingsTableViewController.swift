//
//  SettingsTableViewController.swift
//  EventAggregator
//
//  Created by Egor Bryzgalov on 26.08.17.
//  Copyright © 2017 Egor Bryzgalov. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {
    
    @IBOutlet weak var kudaGOSwitch: UISwitch!
    @IBOutlet weak var timePadSwitch: UISwitch!
    @IBOutlet weak var ponaminaluSwitch: UISwitch!
    @IBOutlet weak var ticketLandSwitch: UISwitch!
    
    let loadDB: LoadDB = LoadDB()
    var selectCity: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.kudaGOSwitch.addTarget(self, action: #selector(showKudaGo), for: .valueChanged)
        self.timePadSwitch.addTarget(self, action: #selector(showtimaPad), for: .valueChanged)
        self.ponaminaluSwitch.addTarget(self, action: #selector(showPonaminalu), for: .valueChanged)
        self.ticketLandSwitch.addTarget(self, action: #selector(showTicketLand), for: .valueChanged)

        globalCity = selectCity
    }

    func showKudaGo() {
        if self.kudaGOSwitch.isOn {
            let showKudaGO = true
            print("ON")
        } else {
            let showKudaGO = false
            print("OFF")
        }
    }
    
    func showtimaPad() {
        if timePadSwitch.isOn {
            let showTime = true
        } else {
            let showTime = false
        }
    }
    
    func showPonaminalu() {
        if ponaminaluSwitch.isOn {
            let showPonaminalu = true
        } else {
            let showPonaminalu = false
        }
    }
    
    func showTicketLand() {
        if ticketLandSwitch.isOn {
            let showTicketLand = true
        } else {
            let showTicketLand = false
        }
    }
    
//    self.print(selectCity)
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

//    override func numberOfSections(in tableView: UITableView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return 3
//    }

//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        // #warning Incomplete implementation, return the number of rows
//        return 0
//    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CitySelected", for: indexPath)
        cell.textLabel?.text = globalCity
        return cell
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
