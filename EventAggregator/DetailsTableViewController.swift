//
//  DetailsTableViewController.swift
//  EventAggregator
//
//  Created by Egor Bryzgalov on 25.07.17.
//  Copyright © 2017 Egor Bryzgalov. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

//var place: String = ""

class ButtonDetailsTableViewControllerCell: UITableViewCell {
    @IBOutlet weak var placeButton: UIButton!
    @IBOutlet weak var buyTicketButton: UIButton!
    @IBOutlet weak var LabelFullDetails: UILabel!
    @IBOutlet weak var LabelNameDetails: UILabel!
    @IBOutlet weak var LabelStartDetails: UILabel!
    @IBOutlet weak var LabelStopDetails: UILabel!
    @IBOutlet weak var LabelCost: UILabel!
    
    @IBOutlet weak var favoriteOutletButton: UIButton!
    @IBAction func favoriteAction(_ sender: UIButton) {
//        self.favoriteOutletButton.setImage(UIImage(named: "starSelected"), for: .normal)
//        let alert = UIAlertController(title: "Error", message: "New city name is empty.", preferredStyle: .alert)
//        let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
//        alert.addAction(action)
//        self.present(alert, animated: true, completion: nil)
    }
    
}

class DetailsTableViewController: UITableViewController {
    
    let loadDB: LoadDB = LoadDB()
    let manageKudaGO: ManageEventKudaGO = ManageEventKudaGO()
    var idEvent: String = ""
    var searchId: String = ""
    
    var name: String = ""
    var details: String = ""
    var fullDetails: String = ""
    var start: String = ""
    var end: String = ""
    var org: String = ""
    var img: String = ""
    var eventKey: String = ""
    var price: String = ""
    var place: String = ""
    var idPlace: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.estimatedRowHeight = 150
        self.tableView.rowHeight = UITableViewAutomaticDimension
        NotificationCenter.default.addObserver(self, selector: #selector(loadData), name: NSNotification.Name(rawValue: "loadData"), object: nil)
        // пришли из EventTableViewController и получаем инфу так
        if idEvent != "" {
            //Получаем ID Мероприятия для звывода
            refEvent.child(uds.value(forKey: "cityKey") as! String).child("Events").observeSingleEvent(of: .value, with: { (snapshot) in
                if let keyValue = snapshot.value as? NSDictionary {
                    for getKey in keyValue.allKeys {
                        refEvent.child(uds.value(forKey: "cityKey") as! String).child("Events").child(getKey as! String).observeSingleEvent(of: .value, with: { (snapshot) in
                            if let tmpId = snapshot.value as? NSDictionary {
                                let subtmpid = tmpId["id"] as? String ?? ""
                                if self.idEvent == subtmpid {
                                    self.eventKey = getKey as! String
                                    concurrentQueue.async(qos: .userInitiated) {
                                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "loadData"), object: nil)
                                    }
                                }
                            }
                        })
                    }
                }
            })
        } else { // если пришли из поиска чтобы посмотреть инфу по мероприятию
            Alamofire.request("https://kudago.com/public-api/v1.3/events/\(searchId)/?text_format=text&location=\(uds.value(forKey: "citySlug") as! String)", method: .get).validate().responseJSON { response in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    self.name = json["title"].stringValue
                    self.fullDetails = json["body_text"].stringValue
                    self.price = json["price"].stringValue
                    self.start = Decoder().timeConvert(sec: json["dates"][0]["start"].stringValue)
                    self.end = Decoder().timeConvert(sec: json["dates"][0]["end"].stringValue)
                    self.img = json["images"][0]["image"].stringValue
                    self.idPlace = json["place"]["id"].stringValue
                    if self.idPlace != "" {
                        refPlace.child(self.idPlace).observeSingleEvent(of: .value, with: { (snapshot) in
                            if let snapPlace = snapshot.value as? NSDictionary {
                                self.place = snapPlace["title"] as? String ?? ""
                                self.tableView.reloadData()
                            }
                        })
                    }
                    self.tableView.reloadData()
                case .failure(let error):
                    print(error)
                }
            }
        }
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    func loadData() { //заполняем вьюху
        refEvent.child(uds.value(forKey: "cityKey") as! String).child("Events").child(eventKey).observeSingleEvent(of: .value, with: { (snapshot) in
            if let val = snapshot.value as? NSDictionary {
                self.name = val["title"] as? String ?? ""
                self.fullDetails = val["description"] as? String ?? ""
                self.img = val["image"] as? String ?? ""
                self.start = val["start_event"] as? String ?? ""
                self.end = val["stop_event"] as? String ?? ""
                if val["Target"] as? String ?? "" == "kudago" {
                    self.idPlace = val["place"] as? String ?? ""
                    refPlace.child(self.idPlace).observeSingleEvent(of: .value, with: { (snapshot) in
                        if let snapPlace = snapshot.value as? NSDictionary {
                            self.place = snapPlace["title"] as? String ?? ""
                            self.tableView.reloadData()
                        }
                    })
                } else {
                    self.place = val["place"] as? String ?? ""
                }
                self.price = val["price"] as? String ?? ""
                self.details = val["short_title"] as? String ?? ""
            }
            self.tableView.reloadData()
        })

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
        let detailsCell = tableView.dequeueReusableCell(withIdentifier: "detailsCell", for: indexPath) as! ButtonDetailsTableViewControllerCell
        
        if img != "" {
                let imgURL: NSURL = NSURL(string: self.img)!
                let imgData: NSData = NSData(contentsOf: imgURL as URL)!
                let image: UIImageView = detailsCell.viewWithTag(8) as! UIImageView
                image.image = UIImage(data: imgData as Data)
        }

        detailsCell.LabelNameDetails.text = self.name
        detailsCell.placeButton.setTitle(place, for: .normal)
        detailsCell.LabelStartDetails.text = self.start

        if fullDetails == "" {
            detailsCell.LabelFullDetails.text = self.details
        } else {
            detailsCell.LabelFullDetails.text = self.fullDetails
        }

        if end != "" {
            detailsCell.LabelStopDetails.text = end
        } else {
            detailsCell.LabelStopDetails.text = ""
        }

        if price != "" {
            detailsCell.LabelCost.text = self.price
        } else {
            detailsCell.LabelCost.text = "Уточняйте в месте проведения"
        }

        return detailsCell
    }
 
    //Идём смотреть инфу по месту проведения
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "place" {
            let destinationVC = segue.destination as! ShowPlaceViewController
            destinationVC.placeId = idPlace
            
        }
    }
    

}
