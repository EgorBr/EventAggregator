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
import FirebaseDatabase
import SwiftMessages

class DetailsViewController: UIViewController {
    
    let decoder: Decoder = Decoder()
    
    let realm = try! Realm()
    
    @IBOutlet weak var imageEvent: UIImageView!
    @IBOutlet weak var place: UIButton!
    @IBOutlet weak var buyTicketB: UIButton!
    @IBOutlet weak var fullDescription: UILabel!
    @IBOutlet weak var nameDetails: UILabel!
    @IBOutlet weak var startEvent: UILabel!
    @IBOutlet weak var stopEvent: UILabel!
    @IBOutlet weak var cost: UILabel!
    
    @IBAction func shareButton(_ sender: Any) {
        if placeName != "" {
            let shareEvent = UIActivityViewController(activityItems: ["Взгляни, тебе понравится! 😏 \(String(describing: self.nameDetails.text!)) в \(placeName) \(String(describing: self.startEvent.text!)). https://ponominalu.ru/event/\(seo)?promote=eda0f065aec3fce22d0708362ca67e48"], applicationActivities: nil)
            shareEvent.popoverPresentationController?.sourceView = self.view
            self.present(shareEvent, animated: true, completion: nil)
        } else {
            let shareEvent = UIActivityViewController(activityItems: ["Взгляни, тебе понравится! 😏 \(String(describing: self.nameDetails.text!)). \(String(describing: self.startEvent.text!)). https://ponominalu.ru/event/\(seo)?promote=eda0f065aec3fce22d0708362ca67e48"], applicationActivities: nil)
            shareEvent.popoverPresentationController?.sourceView = self.view
            self.present(shareEvent, animated: true, completion: nil)
        }
        
    }
    
    @IBOutlet weak var favoriteOutletButton: UIButton!
    //кнопка для добавления в избранное
    @IBAction func favoriteAction(_ sender: AnyObject) {
        let favorite = FavoriteEvent()
        favorite.id = idEvent
        favorite.region = uds.value(forKey: "city") as! String
        favorite.target = targetName

        if favoriteOutletButton.currentImage == UIImage(named: "favoriteButton") {
            self.favoriteOutletButton.setImage(UIImage(named: "unfavoriteButton"), for: .normal)
            try! realm.write {
                realm.delete(realm.objects(FavoriteEvent.self).filter("id=%@",idEvent))
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "loadFavorite"), object: nil)
            }
        } else {
            self.favoriteOutletButton.setImage(UIImage(named: "favoriteButton"), for: .normal)
            try! realm.write {
                realm.add(favorite)
            }
            let iconText = ["🤪", "😳", "🤓", "🤩","🤯","😏"].sm_random()!
            let view = MessageView.viewFromNib(layout: .cardView)
            var config = SwiftMessages.Config()
            view.button?.isHidden = true
            view.bodyLabel?.isHidden = true
            view.configureTheme(backgroundColor: UIColor(colorLiteralRed: 1/255, green: 84/255, blue: 16/255, alpha: 0.7), foregroundColor: UIColor.white, iconImage: nil, iconText: iconText)
            config.presentationStyle = .top
            config.dimMode = .gray(interactive: true)
            view.configureContent(title: "Добавлено в избранное", body: "")
            SwiftMessages.show(config: config, view: view)
        }
    }
    //

    let loadDB: LoadDB = LoadDB()
    let manageKudaGO: ManageEventKudaGO = ManageEventKudaGO()
    
    var idEvent: String = ""
    var searchId: String = ""
    var targetName: String = ""
    
    var eventKey: String = ""
    var idPlace: String = ""
    var seo: String = ""
    var placeName = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let valueCityName = realm.objects(FavoriteEvent.self)
        for value in valueCityName {
            if value.id == idEvent {
                self.favoriteOutletButton.setImage(UIImage(named: "favoriteButton"), for: .normal)
            }
        }
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        NotificationCenter.default.addObserver(self, selector: #selector(loadData), name: NSNotification.Name(rawValue: "loadData"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showAlertPlace), name: NSNotification.Name(rawValue: "unknowplace"), object: nil)
        fullDescription.sizeToFit()
        nameDetails.sizeToFit()
//        print(Realm.Configuration.defaultConfiguration.fileURL!)
        
        // пришли из EventTableViewController и получаем инфу так
        if idEvent != "" {
            loadData()
        } else if targetName == "KudaGO" && searchId != "" { // если пришли из поиска чтобы посмотреть инфу по мероприятию
            loadDetailsSearchResultKudaGO()
        } else if targetName == "Ponaminalu" && searchId != "" {
            loadDetailsSearchResultPonaminalu()
        }
    }
    
    
    
    func loadData() { //заполняем вьюху
        refEvent.child("\(uds.value(forKey: "city") as! String)/Events/\(idEvent)").observeSingleEvent(of: .value, with: { (snapshot) in
            if let val = snapshot.value as? NSDictionary {
                self.nameDetails.text = val["title"] as? String ?? ""
                self.fullDescription.text = val["body_text"] as? String ?? ""
                if val["image"] as? String ?? "" != "" {
                    let imgURL: NSURL = NSURL(string: val["image"] as? String ?? "")!
                    let imgData: NSData = NSData(contentsOf: imgURL as URL)!
                    let image: UIImageView = self.imageEvent
                    image.image = UIImage(data: imgData as Data)
                }
                self.startEvent.text = self.decoder.timeConvert(sec: String((val["start_event"] as? Int)!))
                if val["stop_event"] as? String ?? "" != "" {
                    self.stopEvent.text = self.decoder.timeConvert(sec: String((val["stop_event"] as? Int)!))
                }
                self.seo = val["seo"] as? String ?? ""
                
                if self.targetName == "KudaGO" {
                    self.idPlace = val["place"] as? String ?? ""
                    if self.idPlace != "" {
                        refPlace.child(self.idPlace).observeSingleEvent(of: .value, with: { (snapshot) in
                            if snapshot.value as? NSDictionary == nil {
                                self.manageKudaGO.loadPlaces(idPlace: self.idPlace)
                                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                            }
                            if let snapPlace = snapshot.value as? NSDictionary {
                                self.place.setTitle(snapPlace["title"] as? String ?? "", for: .normal)
                                self.placeName = snapPlace["title"] as? String ?? ""
                                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                            }
                        })
                    }
//                } else if self.targetName == "Ponaminalu" {
//                    refPlace.child(self.checkPlace(name: val["place"] as? String ?? "")).observeSingleEvent(of: .value, with: { (snapshot) in
//                        if snapshot.value as? NSDictionary == nil {
//                            self.place.setTitle(val["place"] as? String ?? "", for: .normal)
//                            UIApplication.shared.isNetworkActivityIndicatorVisible = false
//                        }
//                        if let snapPlace = snapshot.value as? NSDictionary {
//                            self.place.setTitle(snapPlace["title"] as? String ?? "", for: .normal)
//                            self.placeName = snapPlace["title"] as? String ?? ""
//                            UIApplication.shared.isNetworkActivityIndicatorVisible = false
//                        }
//                    })
                } else {
                    self.place.setTitle(val["place"] as? String ?? "", for: .normal)
                    self.placeName = val["place"] as? String ?? ""
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }
                if val["is_free"] as? String ?? "" == "false" {
                    if val["price"] as? String ?? "" == "" {
                        self.cost.text = "Цена уточняется"
                    } else {
                        self.cost.text = val["price"] as? String ?? ""
                    }
                } else {
                    self.cost.text = "Бесплатно"
                }
            }
        })
    }
    
    func checkPlace() {
        var result = ""
        refPlace.observeSingleEvent(of: .value, with: {(snapshot) in
            for id in snapshot.children.allObjects as! [DataSnapshot] {
                if id.childSnapshot(forPath: "title").value as! String == "бар Strelka" {
                    result = id.childSnapshot(forPath: "id").value as! String
                }
            }
        })
    }
    
    func loadDetailsSearchResultPonaminalu() {
        Alamofire.request("https://api.cultserv.ru/v4/subevents/get/?session=\(apiKeyPonaminalu)&id=\(searchId)&region_id=\(uds.value(forKey: "regionId") as! String)&promote=69399e321f034b29441a6a525c50a488", method: .get).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                if json["code"].stringValue == "1" {
                    self.nameDetails.text = json["message"]["title"].stringValue
                    self.fullDescription.text = Decoder().decodehtmltotxt(htmltxt: json["message"]["description"].stringValue)
                    self.cost.text = "от \(json["message"]["min_price"].stringValue) до \(json["message"]["max_price"].stringValue)"
                    self.startEvent.text = Decoder().dfPonam(date: json["message"]["date"].stringValue)
                    self.stopEvent.text = "Уточняйте"
                    self.seo = json["message"]["event"]["seo"]["alias"].stringValue
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
    
    func loadDetailsSearchResultKudaGO() {
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
                                    self.placeName = reloadPlace["title"] as? String ?? ""
                                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                                }
                            })
                        }
                        if let snapPlace = snapshot.value as? NSDictionary {
                            self.place.setTitle(snapPlace["title"] as? String ?? "", for: .normal)
                            self.placeName = snapPlace["title"] as? String ?? ""
                            UIApplication.shared.isNetworkActivityIndicatorVisible = false
                        }
                    })
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func showAlertPlace() {
        let alert = UIAlertController(title: nil, message: "Я пока не знаю где находится это место, но я выясняю. Как будет известно, то ты узнаешь об этом первым", preferredStyle: .alert)
        let action = UIAlertAction(title: "Ок", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
 
    //Идём смотреть инфу по месту проведения
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "place" {
            if idPlace != "" {
                let placeVC = segue.destination as! ShowPlaceViewController
                placeVC.placeId = idPlace
            } else {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "unknowplace"), object: nil)
            }
        }
        if segue.identifier == "buyTicket" {
            let seq = segue.destination as! UINavigationController
            let buyVC = seq.topViewController as! BuyWebViewController
            buyVC.event = seo
        }
    }
    

}
