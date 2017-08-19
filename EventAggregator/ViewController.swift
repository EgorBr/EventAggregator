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

class TableCityViewController: UITableViewController {
    let loadDB: LoadDB = LoadDB()
    let serialQueue = DispatchQueue(label: "serial_queue")
    let concurrentQueue = DispatchQueue(label: "concurrent_queue", attributes: .concurrent)
    let manageTimepad: ManageEventTimepad = ManageEventTimepad()
    let realm = try! Realm()
    var notificationToken: NotificationToken? = nil
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        print(Realm.Configuration.defaultConfiguration.fileURL)
        
//        NotificationCenter.default.addObserver(self, selector: #selector(cityname), name: NSNotification.Name(rawValue: "refresh"), object: nil)
//        if load == nil {
        manageTimepad.loadCity()
        manageTimepad.semafore.wait(timeout: .distantFuture)
        concurrentQueue.async (qos: .background) {
            self.manageTimepad.loadDB(param: 1)
        }
            
        
//        ManageEventKudaGO().loadDetailsKudaGO(name: "Москва", slug: "Msk", number: 3)
    
    notificationToken = realm.addNotificationBlock {notification, realm in
        self.tableView.reloadData()
    }
        
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
    
//    deinit {
//        notificationToken?.stop()
//    }

}

