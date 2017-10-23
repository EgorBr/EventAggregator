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
import RealmSwift

class DetailsViewController: UIViewController {
    
    let realm = try! Realm()
    
    @IBOutlet weak var imageEvent: UIImageView!
    @IBOutlet weak var place: UIButton!
    @IBOutlet weak var buyTicketB: UIButton!
    @IBOutlet weak var fullDescription: UILabel!
    @IBOutlet weak var nameDetails: UILabel!
    @IBOutlet weak var startEvent: UILabel!
    @IBOutlet weak var stopEvent: UILabel!
    @IBOutlet weak var cost: UILabel!
    
    @IBOutlet weak var favoriteOutletButton: UIButton!
    @IBAction func favoriteAction(_ sender: AnyObject) {
        let favorite = FavoriteEvent()
        favorite.id = "idEvent"
        favorite.region = uds.value(forKey: "city") as! String
        try! realm.write {
            print(favorite)
            //            realm.add(favorite)
        }
        if 1 == 1 {
            
        } else {
            
        }
        self.favoriteOutletButton.setImage(UIImage(named: "starSelected"), for: .normal)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showAlert"), object: nil)
    }

    let loadDB: LoadDB = LoadDB()
    let manageKudaGO: ManageEventKudaGO = ManageEventKudaGO()
    
    var idEvent: String = ""
    var searchId: String = ""
    var targetName: String = ""
    
    var eventKey: String = ""
    var idPlace: String = ""
    var seo: String = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 11.0, *) {
            navigationItem.largeTitleDisplayMode = .never
        } 
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        NotificationCenter.default.addObserver(self, selector: #selector(loadData), name: NSNotification.Name(rawValue: "loadData"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showAlert), name: NSNotification.Name(rawValue: "showAlert"), object: nil)
        fullDescription.sizeToFit()
        nameDetails.sizeToFit()
        print(Realm.Configuration.defaultConfiguration.fileURL!)
        // пришли из EventTableViewController и получаем инфу так
        if idEvent != "" {
            //Получаем ID Мероприятия для вывода
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
        } else if targetName == "kudago" { // если пришли из поиска чтобы посмотреть инфу по мероприятию
            Alamofire.request("https://kudago.com/public-api/v1.3/events/\(searchId)/?text_format=text&location=\(uds.value(forKey: "citySlug") as! String)", method: .get).validate().responseJSON { response in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    self.nameDetails.text = json["title"].stringValue
                    self.fullDescription.text = json["body_text"].stringValue
                    self.cost.text = json["price"].stringValue
                    self.startEvent.text = Decoder().timeConvert(sec: json["dates"][0]["start"].stringValue)
                    self.stopEvent.text = Decoder().timeConvert(sec: json["dates"][0]["end"].stringValue)
                    if json["images"][0]["image"].stringValue != "" {
                        let imgURL: NSURL = NSURL(string: json["images"][0]["image"].stringValue)!
//                        print(imgURL)
                        let imgData: NSData = NSData(contentsOf: imgURL as URL)!
                        let image: UIImageView = self.imageEvent
                        image.image = UIImage(data: imgData as Data)
                    }
                    self.idPlace = json["place"]["id"].stringValue
                    if self.idPlace != "" {
                        refPlace.child(self.idPlace).observeSingleEvent(of: .value, with: { (snapshot) in
                            if snapshot.value as? NSDictionary == nil {
                                self.manageKudaGO.loadPlaces(idPlace: self.idPlace)
                                refPlace.child(self.idPlace).observeSingleEvent(of: .value, with: { (snapshot) in
                                    if let reloadPlace = snapshot.value as? NSDictionary {
                                        self.place.setTitle(reloadPlace["title"] as? String ?? "", for: .normal)
                                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                                    }
                                })
                            }
                            if let snapPlace = snapshot.value as? NSDictionary {
                                self.place .setTitle(snapPlace["title"] as? String ?? "", for: .normal) 
                                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                            }
                        })
                    }
                case .failure(let error):
                    print(error)
                }
            }
        } else if targetName == "ponaminalu" {
            Alamofire.request("https://api.cultserv.ru/v4/subevents/get/?session=\(apiKeyPonaminalu)&id=\(searchId)&region_id=\(uds.value(forKey: "regionId") as! String)&promote=69399e321f034b29441a6a525c50a488", method: .get).validate().responseJSON { response in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    if json["code"].stringValue == "1" {
                    self.nameDetails.text = json["message"]["title"].stringValue
                    self.fullDescription.text = json["message"]["description"].stringValue
                    self.cost.text = "от \(json["message"]["min_price"].stringValue) до \(json["message"]["max_price"].stringValue)"
                    self.startEvent.text = Decoder().dfPonam(date: json["message"]["date"].stringValue)
                    self.stopEvent.text = "Уточняйте"
                    self.seo = json["message"]["event"]["seo"]["alias"].stringValue
//                    if json["images"][0]["image"].stringValue != "" {
                        let imgURL: NSURL = NSURL(string: "http://media.cultserv.ru/i/300x200/\(json["message"]["image"].stringValue)")!
                        let imgData: NSData = NSData(contentsOf: imgURL as URL)!
                        let image: UIImageView = self.imageEvent
                        image.image = UIImage(data: imgData as Data)
                    } else {
                        self.fullDescription.text = "ПОТРАЧЕНО! БОЛЬШЕ НЕТ БИЛЕТОВ"
                    }
                
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
    
    func loadData() { //заполняем вьюху
        refEvent.child(uds.value(forKey: "cityKey") as! String).child("Events").child(eventKey).observeSingleEvent(of: .value, with: { (snapshot) in
            if let val = snapshot.value as? NSDictionary {
                self.nameDetails.text = val["title"] as? String ?? ""
                self.fullDescription.text = val["description"] as? String ?? ""
                if val["image"] as? String ?? "" != "" {
                    let imgURL: NSURL = NSURL(string: val["image"] as? String ?? "")!
                    let imgData: NSData = NSData(contentsOf: imgURL as URL)!
                    let image: UIImageView = self.imageEvent
                    image.image = UIImage(data: imgData as Data)
                }
                self.startEvent.text = val["start_event"] as? String ?? ""
                self.stopEvent.text = val["stop_event"] as? String ?? ""
                self.seo = val["seo"] as? String ?? ""
                if val["Target"] as? String ?? "" == "kudago" {
                    self.idPlace = val["place"] as? String ?? ""
                    if self.idPlace != "" {
                        refPlace.child(self.idPlace).observeSingleEvent(of: .value, with: { (snapshot) in
                            if snapshot.value as? NSDictionary == nil {
                                self.manageKudaGO.loadPlaces(idPlace: self.idPlace)
                                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                            }
                            if let snapPlace = snapshot.value as? NSDictionary {
                                self.place.setTitle(snapPlace["title"] as? String ?? "", for: .normal)
                                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                            }
                        })
                    }
                } else {
                    self.place.setTitle(val["place"] as? String ?? "", for: .normal)
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }
                self.cost.text = val["price"] as? String ?? ""
                self.fullDescription.text = val["short_title"] as? String ?? ""
            }
        })

    }

    func showAlert() {
        let alert = UIAlertController(title: nil, message: "Добавленно в избранное", preferredStyle: .alert)
        let action = UIAlertAction(title: "Ок", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
 
    //Идём смотреть инфу по месту проведения
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "place" {
            let placeVC = segue.destination as! ShowPlaceViewController
            placeVC.placeId = idPlace
        }
        if segue.identifier == "buyTicket" {
            let seq = segue.destination as! UINavigationController
            let buyVC = seq.topViewController as! BuyWebViewController
            buyVC.event = seo
        }
    }
    

}
