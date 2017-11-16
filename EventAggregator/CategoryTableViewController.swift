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
                        if let snap = snapshot.value as? NSDictionary {
//                            self.name.append(snap["name"] as? String ?? "")
                            refEvent.child("\(uds.value(forKey: "city") as! String)/Events/Ponaminalu").observeSingleEvent(of: .value, with: { (snapshot) in
                                for val in snapshot.children.allObjects as! [DataSnapshot] {
                                    if snap["slug"] as? String ?? "" == val.childSnapshot(forPath: "categories").value as! String {
                                        if self.slug.contains(snap["slug"] as? String ?? "") == false {
                                            self.slug.append(snap["slug"] as? String ?? "")
                                        }
                                    }
                                    
//                                    self.tableView.reloadData()
                                }
                                self.categories[snap["slug"] as? String ?? ""] = String(self.slug.count)
                            })
//                            self.count.append(snap["events_count"] as? String ?? "")
//                            self.tableView.reloadData()
                        }
                    })
                }
            }
        })
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

//    override func numberOfSections(in tableView: UITableView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return 1
//    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return categories.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let categoryCell = tableView.dequeueReusableCell(withIdentifier: "category", for: indexPath) as! CategoryTableViewControllerCell
//        let slug = self.slug[indexPath.row]
//        print(slug)
//        categoryCell.eventNameLabel.text = categories[slug]
//        if self.count[indexPath.row] == "" {
//            categoryCell.countLabel.text = "-"
//        } else {
//            categoryCell.countLabel.text = self.count[indexPath.row]
//        }
        return categoryCell
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
