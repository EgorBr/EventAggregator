//
//  ViewController.swift
//  EventAggregator
//
//  Created by Egor Bryzgalov on 17.07.17.
//  Copyright © 2017 Egor Bryzgalov. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire
import RealmSwift

class TableCityViewController: UITableViewController {
    let loadDB: LoadDB = LoadDB()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        print(Realm.Configuration.defaultConfiguration.fileURL)
        ManageEventTimepad().loadEvent()
    
    }
    
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return loadDB.loadDBCityName().count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cityCell = tableView.dequeueReusableCell(withIdentifier: "cityCell", for: indexPath)
        cityCell.textLabel?.text = loadDB.loadDBCityName()[indexPath.row]
        return cityCell
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

