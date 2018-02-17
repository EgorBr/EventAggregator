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
   
    let manageData = ManageData()
    let loadDB: LoadDB = LoadDB()
    var selectCity: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sideMenu()
        self.navigationItem.title = "Настройки"
        
        LableCity.text = uds.value(forKey: "city") as! String

        self.kudaGOSwitch.addTarget(self, action: #selector(showKudaGo), for: .valueChanged)
        self.timePadSwitch.addTarget(self, action: #selector(showTimePad), for: .valueChanged)
        self.ponaminaluSwitch.addTarget(self, action: #selector(showPonaminalu), for: .valueChanged)

        kudaGOSwitch.isOn = uds.bool(forKey: "switchKudaGO")
        timePadSwitch.isOn = uds.bool(forKey: "switchTimaPad")
        ponaminaluSwitch.isOn = uds.bool(forKey: "switchPonaminalu")
        
        if uds.value(forKey: "citySlug") as! String == "" {
            kudaGOSwitch.isEnabled = false
        }
        if uds.value(forKey: "regionId") as! String == "" {
            ponaminaluSwitch.isEnabled = false
        }
    }
    
    func sideMenu() {
        if revealViewController() != nil {
            menuButton.target = revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
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

    func showKudaGo() {
        
        if kudaGOSwitch.isOn {
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
    
    @IBAction func unwindApplyCity(_ sender: UIStoryboardSegue) {
        guard let cityVC = sender.source as? SelectCityTableViewController else { return }
        if let indexPath = cityVC.tableView.indexPathForSelectedRow {
            if cityVC.searchController.isActive {
                selectCity = cityVC.filteredCity.sorted(by: < )[indexPath.row]
//                cityVC.searchController.isActive = false
                if selectCity != uds.value(forKey: "city") as! String {
                    uds.set(selectCity, forKey: "city")
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadKeyCity"), object: nil)
                    manageData.loadNews()
                }
            } else {
                selectCity = cityVC.sortCity[indexPath.row]
//                cityVC.searchController.isActive = false
                if selectCity != uds.value(forKey: "city") as! String {
                    uds.set(selectCity, forKey: "city")
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadKeyCity"), object: nil)
                }
            }
        }
        LableCity.text = uds.value(forKey: "city") as! String
    }

}
