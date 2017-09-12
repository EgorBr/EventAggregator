//
//  DetailsTableViewController.swift
//  EventAggregator
//
//  Created by Egor Bryzgalov on 25.07.17.
//  Copyright © 2017 Egor Bryzgalov. All rights reserved.
//

import UIKit

var place: String = ""

class DetailsTableViewController: UITableViewController {
    
    let loadDB: LoadDB = LoadDB()
    let manageKudaGO: ManageEventKudaGO = ManageEventKudaGO()

    var idEvent: String = ""
    var name: String = ""
    var details: String = ""
    var fullDetails: String = ""
    var start: String = ""
    var end: String = ""
    var org: String = ""
    var img: String = ""
    var eventKey: String = ""
    var price: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.estimatedRowHeight = 150
        self.tableView.rowHeight = UITableViewAutomaticDimension
        NotificationCenter.default.addObserver(self, selector: #selector(loadData), name: NSNotification.Name(rawValue: "loadData"), object: nil)
        
        refEvent.child(uds.value(forKey: "globalCityKey") as! String).child("Events").observeSingleEvent(of: .value, with: { (snapshot) in
            if let keyValue = snapshot.value as? NSDictionary {
                for getKey in keyValue.allKeys {
                    refEvent.child(uds.value(forKey: "globalCityKey") as! String).child("Events").child(getKey as! String).observeSingleEvent(of: .value, with: { (snapshot) in
                        if let tmpId = snapshot.value as? NSDictionary {
                            let subtmpid = tmpId["id"] as? String ?? ""
                            if self.idEvent == subtmpid {
                                self.eventKey = getKey as! String
                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "loadData"), object: nil)
                            }
                        }
                    })
                }
            }
        })
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    func loadData() {
        refEvent.child(uds.value(forKey: "globalCityKey") as! String).child("Events").child(eventKey).observeSingleEvent(of: .value, with: { (snapshot) in
            if let val = snapshot.value as? NSDictionary {
                let tmpName = val["title"] as? String ?? ""
                let tmpFull = val["body_text"] as? String ?? ""
                let tmpImg = val["image"] as? String ?? ""
                let tmpStart = val["start_event"] as? String ?? ""
                let tmpEnd = val["stop_event"] as? String ?? ""
                let tmpPlace = val["place"] as? String ?? ""
                let tmpPrice = val["price"] as? String ?? ""

                self.fullDetails = tmpFull
                self.name = tmpName
                self.img = tmpImg
                self.start = tmpStart
                self.end = tmpEnd
                self.price = tmpPrice
//                self.manageKudaGO.printNamePlace(idPlace: tmpPlace)
            }
            self.tableView.reloadData()
            
        })

    }
    
    func reloadTableView() {
        DispatchQueue.main.sync {
            self.tableView.reloadData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let detailsCell = tableView.dequeueReusableCell(withIdentifier: "detailsCell", for: indexPath)
        
        if img != "" {
//            concurrentQueue.async {
//            print(self.img)
                let imgURL: NSURL = NSURL(string: self.img)!
                let imgData: NSData = NSData(contentsOf: imgURL as URL)!
                let image: UIImageView = detailsCell.viewWithTag(8) as! UIImageView
                image.image = UIImage(data: imgData as Data)
//            }
//            DispatchQueue.main.async {
//                self.tableView.reloadData()
//            }
        }
        
        let LabelNameDetails: UILabel = detailsCell.viewWithTag(1) as! UILabel
        LabelNameDetails.text = self.name
        
        let LabelFullDetails: UILabel = detailsCell.viewWithTag(2) as! UILabel
        if fullDetails == "" {
            LabelFullDetails.text = "Увы, описание нет. Извините"
        } else {
            LabelFullDetails.text = self.fullDetails
        }
        
//
        let LabelStartDetails: UILabel = detailsCell.viewWithTag(3) as! UILabel
        LabelStartDetails.text = self.start
        
        let LabelStopDetails: UILabel = detailsCell.viewWithTag(4) as! UILabel
        if end != "" {
            LabelStopDetails.text = end
        } else {
            LabelStopDetails.text = ""
        }
        
        let LabelMinCostDetails: UILabel = detailsCell.viewWithTag(5) as! UILabel
        if price != "" {
            LabelMinCostDetails.text = self.price
        } else {
            LabelMinCostDetails.text = "Уточняйте в месте проведения"
        }
        
//        let LabelMaxCostDetails: UILabel = detailsCell.viewWithTag(6) as! UILabel
//        LabelMaxCostDetails.text = place

        return detailsCell
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
