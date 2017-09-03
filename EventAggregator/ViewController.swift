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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        sideMenu()
        customizeNavBar()

        print(Realm.Configuration.defaultConfiguration.fileURL!)
        
//                NotificationCenter.default.addObserver(self, selector: #selector(cityname), name: NSNotification.Name(rawValue: "refresh"), object: nil)
        if load == nil {
//            manageKudaGo.loadCityKudaGo()
        }
        //        else {
        //            city = loadDB.CityName()
        //        }
        
        //            manageTimepad.loadCity()
        manageKudaGo.loadEventKudaGO(name: "Москва")
        //            manageKudaGo.loadDetailsEventKudaGo(city: "Москва", id: "159388")
        //            manageKudaGo.loadPlaces()
        
        //            semafore.wait(timeout: .distantFuture)
        //            concurrentQueue.async (qos: .background) {
        //                self.manageTimepad.loadDB(param: 1)
        //            }
        
        //        ManageEventKudaGO().loadEventKudaGO(name: "Москва", slug: "Msk", number: 50)
        
//        notificationToken = realm.addNotificationBlock {notification, realm in
//            self.tableView.reloadData()
//        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func sideMenu() {
        
        if revealViewController() != nil {
            
            menuButton.target = revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            revealViewController().rearViewRevealWidth = 275
            
            
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
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
