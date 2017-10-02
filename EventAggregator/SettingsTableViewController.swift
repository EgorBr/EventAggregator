//
//  SettingsTableViewController.swift
//  EventAggregator
//
//  Created by Egor Bryzgalov on 26.08.17.
//  Copyright © 2017 Egor Bryzgalov. All rights reserved.
//

import UIKit
import SWRevealViewController

class SettingsTableViewController: UITableViewController {
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var kudaGOSwitch: UISwitch!
    @IBOutlet weak var timePadSwitch: UISwitch!
    @IBOutlet weak var ponaminaluSwitch: UISwitch!
    @IBOutlet weak var LableCity: UILabel!
   
    
    let loadDB: LoadDB = LoadDB()
    var selectCity: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()        
        sideMenu()
        customizeNavBar()
        
        if selectCity == "" { }
        else if selectCity != uds.value(forKey: "city") as! String {
            uds.set(selectCity, forKey: "city")
            RootTableViewController().reloadKeyCity()
//            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadKeyCity"), object: nil)
        }
        
        LableCity.text = uds.value(forKey: "city") as! String

        self.kudaGOSwitch.addTarget(self, action: #selector(showKudaGo), for: .valueChanged)
        self.timePadSwitch.addTarget(self, action: #selector(showTimePad), for: .valueChanged)
        self.ponaminaluSwitch.addTarget(self, action: #selector(showPonaminalu), for: .valueChanged)

        kudaGOSwitch.isOn = uds.bool(forKey: "switchKudaGO")
        timePadSwitch.isOn = uds.bool(forKey: "switchTimaPad")
        ponaminaluSwitch.isOn = uds.bool(forKey: "switchPonaminalu")

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
        navigationController?.navigationBar.barTintColor = UIColor(colorLiteralRed: 42/255, green: 26/255, blue: 25/255, alpha: 1)
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
    }

    func showKudaGo() {
        
        if self.kudaGOSwitch.isOn {
            uds.set(true, forKey: "switchKudaGO")
        } else {
            uds.set(false, forKey: "switchKudaGO")
        }
    }
    
    func showTimePad() {
        if timePadSwitch.isOn {
            uds.set(true, forKey: "switchTimaPad")
        } else {
            uds.set(false, forKey: "switchTimaPad")
        }
    }
    
    func showPonaminalu() {
        if ponaminaluSwitch.isOn {
            uds.set(true, forKey: "switchPonaminalu")
        } else {
            uds.set(false, forKey: "switchPonaminalu")
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
//        return 2
//    }

//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        // #warning Incomplete implementation, return the number of rows
//        return 0
//    }

    
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cellCity = tableView.dequeueReusableCell(withIdentifier: "CitySelected", for: indexPath)
//        let LabelCity: UILabel = cellCity.viewWithTag(1) as! UILabel
//        LabelCity.text = uds.value(forKey: "globalCity") as! String
//
//        return cellCity
//    }
    

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
