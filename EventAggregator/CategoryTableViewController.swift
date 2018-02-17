//
//  CategoryTableViewController.swift
//  EventAggregator
//
//  Created by Egor Bryzgalov on 06.10.2017.
//  Copyright © 2017 Egor Bryzgalov. All rights reserved.
//

import UIKit
import Firebase

class CategoryTableViewControllerCell: UITableViewCell {
    @IBOutlet weak var eventNameLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
}


class CategoryTableViewController: UITableViewController {
    
    var categories: [String:String] = [:]
    
    var name: [String] = []
    var count: [String] = []
    var slug: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let view = UIView(frame: CGRect(x: 0.0, y: 0.0, width: UIScreen.main.bounds.size.width, height: 20.0))
        view.backgroundColor = UIColor(red: 42/255, green: 26/255, blue: 25/255, alpha: 1)
        self.navigationController?.view.addSubview(view)
        
        refCategory.observeSingleEvent(of: .value, with: { (snapshot) in
            if let keyValue = snapshot.value as? NSDictionary {
                for getKey in keyValue.allKeys {
                    refCategory.child(getKey as! String).observeSingleEvent(of: .value, with: { (snapshot) in
                        if let items = snapshot.value as? NSDictionary {
//                            print(items["slug"] as? String ?? "")
                            self.name.append(items["name"] as? String ?? "")
                            self.slug.append(items["slug"] as? String ?? "")
                            
//                            refEvent.child("\(uds.value(forKey: "city") as! String)/Events/Ponaminalu").observeSingleEvent(of: .value, with: { (snapshot) in
//                                for val in snapshot.children.allObjects as! [DataSnapshot] {
//                                    if snap["slug"] as? String ?? "" == val.childSnapshot(forPath: "categories").value as! String {
//                                        if self.slug.contains(snap["slug"] as? String ?? "") == false {
//                                            self.slug.append(snap["slug"] as? String ?? "")
//                                            print(self.slug)
//                                            print(self.name)
//                                        }
//                                    }
//                                    
//                                }
//                                self.categories[snap["slug"] as? String ?? ""] = String(self.slug.count)
//                            })
//                            self.count.append(snap["events_count"] as? String ?? "")
//                            self.tableView.reloadData()
                        }
                    })
                }
            }
        })
        
        
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return name.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let categoryCell = tableView.dequeueReusableCell(withIdentifier: "category", for: indexPath) as! CategoryTableViewControllerCell
        categoryCell.eventNameLabel.text = name[indexPath.row]
        categoryCell.countLabel.isHidden = true
//        categoryCell.countLabel.text =  "Скоро"
        return categoryCell
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "setCategory" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let seq = segue.destination as! UINavigationController
                let categoryVC = seq.topViewController as! EventTableViewController
                categoryVC.categoryName = slug[indexPath.row]
                categoryVC.category = name[indexPath.row]
            }
        }
    }

}
