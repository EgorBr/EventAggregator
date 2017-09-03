//
//  ViewController.swift
//  EventAggregator
//
//  Created by Egor Bryzgalov on 17.07.17.
//  Copyright © 2017 Egor Bryzgalov. All rights reserved.
//
import Foundation
import UIKit
import SwiftyJSON
import Alamofire
import RealmSwift
import SWRevealViewController

class TableCityViewController: UITableViewController {
    
    let loadDB: LoadDB = LoadDB()
    let realm = try! Realm()
    var notificationToken: NotificationToken? = nil
    
    @IBOutlet weak var menuButtonTable: UIBarButtonItem!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sideMenu()
        customizeNavBar()
        
        // Do any additional setup after loading the view, typically from a nib.
        
        
    }
    
    func sideMenu() {
        
        if revealViewController() != nil {
            
            menuButtonTable.target = revealViewController()
            menuButtonTable.action = #selector(SWRevealViewController.revealToggle(_:))
            revealViewController().rearViewRevealWidth = 275
            
            
            view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            
        }
    }
    //Разрисовываем navigationBar
    func customizeNavBar() {
        
        
        navigationController?.navigationBar.tintColor = UIColor(colorLiteralRed: 255/255, green: 255/255, blue: 255/255, alpha: 1)
        navigationController?.navigationBar.barTintColor = UIColor(colorLiteralRed: 255/255, green: 87/255, blue: 35/255, alpha: 1)
        
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        
        
    }

    
    func cityname() {
        DispatchQueue.main.sync {
            self.tableView.reloadData()
            
        }
    }
    
    // Количество секций
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    //Колчество показываемых строк в этой секции
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return loadDB.CityName().count
    }
    //Эти строки данными
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cityCell = tableView.dequeueReusableCell(withIdentifier: "cityCell", for: indexPath)
        cityCell.textLabel?.text = loadDB.CityName()[indexPath.row]
        return cityCell
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "event" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let destinationVC = segue.destination as! EventTableViewController
                destinationVC.city = loadDB.CityName()[indexPath.row]
                //                ManageEventTimepad().loadDetailsEvent(city: loadDB.CityName()[indexPath.row])
            }
        }
    }
    
    deinit {
        notificationToken?.stop()
    }
    
}



