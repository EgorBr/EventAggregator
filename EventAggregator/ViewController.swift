//
//  ViewController.swift
//  EventAggregator
//
//  Created by Egor Bryzgalov on 24.08.17.
//  Copyright © 2017 Egor Bryzgalov. All rights reserved.
//

import UIKit
import RealmSwift
import SWRevealViewController


class ViewController: UIViewController {
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    let manageTimepad: ManageEventTimepad = ManageEventTimepad()
    let manageKudaGo: ManageEventKudaGO = ManageEventKudaGO()
    let managePonaminalu: ManagePonaminaluEvent = ManagePonaminaluEvent()
    let utils: Utils = Utils()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(reloadKeyCity), name: NSNotification.Name(rawValue: "reloadKeyCity"), object: nil)
        
        if uds.value(forKey: "globalCity") != nil {
            startUtils()
        }
        
        sideMenu()
        customizeNavBar()

        print(Realm.Configuration.defaultConfiguration.fileURL!)
        
        if uds.value(forKey: "globalCity") == nil {
            uds.set("Москва", forKey: "globalCity")
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadKeyCity"), object: nil)
        }

        if uds.value(forKey: "lastLoad") == nil {
            uds.set(Int(NSDate().timeIntervalSince1970), forKey: "lastLoad")
        }
        
        if Int(NSDate().timeIntervalSince1970) - (uds.value(forKey: "lastLoad") as! Int) > 28800 {
            if uds.bool(forKey: "switchKudaGO") == true {
                manageKudaGo.loadEventKudaGO()
            }
            if uds.bool(forKey: "switchPonaminalu") == true {
                managePonaminalu.loadEventPonaminalu()
            }
            if uds.bool(forKey: "switchTimaPad") == true {
                print("TimePad is ON")
            }
            uds.set(Int(NSDate().timeIntervalSince1970), forKey: "lastLoad")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func startUtils() {
        concurrentQueue.async(qos: .userInitiated) {
            self.utils.getKeyEvents()
            self.utils.removeEvent()
        }
    }
    
    func reloadKeyCity() {
            utils.getKeyCity(name: uds.value(forKey: "globalCity") as! String)
            print("RELOAD CITY KEY")
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
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "favorite" {
//            let destionationVC: FavoriteTableViewController = segue.destination as! FavoriteTableViewController
//            destionationVC.delegate = self
//        }
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
//    }


}
