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
import EventKit

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
    @IBOutlet weak var favoriteOutletButton: UIButton!
    
    //SHARE BUTTON
    @IBAction func shareButton(_ sender: Any) {
        if placeName != "" {
            let shareEvent = UIActivityViewController(activityItems: ["Взгляни, тебе понравится! 😏 \(String(describing: self.nameDetails.text!)) в \(placeName) \(String(describing: self.startEvent.text!)). \(shotURL!)"], applicationActivities: nil)
            shareEvent.popoverPresentationController?.sourceView = self.view
            self.present(shareEvent, animated: true, completion: nil)
        } else {
            let shareEvent = UIActivityViewController(activityItems: ["Взгляни, тебе понравится! 😏 \(String(describing: self.nameDetails.text!)). \(String(describing: self.startEvent.text!)). \(shotURL!)"], applicationActivities: nil)
            shareEvent.popoverPresentationController?.sourceView = self.view
            self.present(shareEvent, animated: true, completion: nil)
        }
        
    }
    
    //кнопка для добавления в избранное
    @IBAction func favoriteAction(_ sender: AnyObject) {
//        self.getShotLink(URL: "")
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

    @IBAction func addToCalendar(_ sender: Any) {
        let eventStore: EKEventStore = EKEventStore()
        
        eventStore.requestAccess(to: .event, completion: {(granted, error) in
            if (granted) && (error == nil) {
                let event: EKEvent = EKEvent(eventStore: eventStore)
                event.title = self.eventName
                event.startDate = Date(timeIntervalSince1970: self.starEvent)
                event.endDate = Date(timeIntervalSince1970: (self.starEvent + 7200))
                event.location = self.eventNotes
//                event.alarms = EKAlarm(
                event.calendar = eventStore.defaultCalendarForNewEvents
                do {
                    try eventStore.save(event, span: .thisEvent)
                } catch let error as NSError {
                    print("ERROR: ", error )
                }
                self.showAlert(message: "Событие добавлено в календарь")
            }
        })
    }
    
    
    let loadDB: LoadDB = LoadDB()
    let manageKudaGO: ManageEventKudaGO = ManageEventKudaGO()
    let mangeData: ManageData = ManageData()
    
    var idEvent: String = ""
    var searchId: String = ""
    var targetName: String = ""
    
    var eventKey: String = ""
    var idPlace: String!
    var seo: String = ""
    var placeName = ""
    var shotURL: URL!
    
    var eventName: String!
    var starEvent: Double!
    var eventNotes: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if targetName == "KudaGo" || targetName == "TimePad" {
            buyTicketB.isHidden = true
        }
        
        let valueCityName = realm.objects(FavoriteEvent.self)
        for value in valueCityName {
            if value.id == idEvent {
                self.favoriteOutletButton.setImage(UIImage(named: "favoriteButton"), for: .normal)
            }
        }
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        NotificationCenter.default.addObserver(self, selector: #selector(loadData), name: NSNotification.Name(rawValue: "loadData"), object: nil)
        fullDescription.sizeToFit()
        nameDetails.sizeToFit()
//        print(Realm.Configuration.defaultConfiguration.fileURL!)
        // пришли из EventTableViewController и получаем инфу так
        if idEvent != "" {
            loadData()
        } else if targetName == "KudaGo" && searchId != "" { // если пришли из поиска чтобы посмотреть инфу по мероприятию
            loadDetailsSearchResultKudaGO()
        } else if targetName == "Ponaminalu" && searchId != "" {
            loadDetailsSearchResultPonaminalu()
        }
    }
    
    
    
    func loadData() { //заполняем вьюху
        refEvent.child("\(uds.value(forKey: "city") as! String)/Events/\(idEvent)").observeSingleEvent(of: .value, with: { (snapshot) in
            if let val = snapshot.value as? NSDictionary {
                self.nameDetails.text = val["title"] as? String ?? ""
                self.eventName = val["title"] as? String ?? ""
                self.fullDescription.text = val["body_text"] as? String ?? ""
                /*---------------------------------------*/
                if val["image"] as? String ?? "" != "" {
                    let imgURL: NSURL = NSURL(string: val["image"] as? String ?? "")!
                    let imgData: NSData = NSData(contentsOf: imgURL as URL)!
                    let image: UIImageView = self.imageEvent
                    image.image = UIImage(data: imgData as Data)
                }
                self.startEvent.text = self.decoder.timeConvert(sec: String((val["start_event"] as? Int)!))
                self.starEvent = val["start_event"] as? Double
                /*---------------------------------------*/
                if val["stop_event"] as? String ?? "" != "" {
                    self.stopEvent.text = self.decoder.timeConvert(sec: String((val["stop_event"] as? Int)!))
                }
                /*---------------------------------------*/
                if self.targetName == "KudaGo" {
                    self.idPlace = val["place"] as? String ?? ""
                    if self.idPlace != nil && self.idPlace != "" {
                        refPlace.child(self.idPlace).observeSingleEvent(of: .value, with: { (snapshot) in
                            if snapshot.value as? NSDictionary == nil {
                                self.manageKudaGO.loadPlaces(idPlace: self.idPlace)
                                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                            }
                            
                            if let snapPlace = snapshot.value as? NSDictionary {
                                self.place.setTitle(snapPlace["title"] as? String ?? "", for: .normal)
                                self.eventNotes = snapPlace["title"] as? String ?? ""
                                self.placeName = snapPlace["title"] as? String ?? ""
                                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                            }
                        })
                    } else {
                        self.place.setTitle(uds.value(forKey: "city") as! String, for: .normal)
                    }
                    /*---------------------------------------*/
                } else if self.targetName == "Ponaminalu" {
                    self.seo = val["seo"] as? String ?? ""
                    refPlace.observeSingleEvent(of: .value, with: { (snapshot) in
                        for point in snapshot.children.allObjects as! [DataSnapshot] {
                            if (point.childSnapshot(forPath: "title").value as! String).range(of: val["place"] as? String ?? "") != nil {
                                self.place.setTitle(val["place"] as? String ?? "", for: .normal)
                                self.idPlace = point.childSnapshot(forPath: "id").value as! String
                                break
                            }
                        }
                    })
                    self.place.setTitle(val["place"] as? String ?? "", for: .normal)
                    self.eventNotes = val["place"] as? String ?? ""
                    /*---------------------------------------*/
                } else if self.targetName == "TimePad" {
                    self.idPlace = val["place"] as? String ?? ""
                    if self.idPlace != nil && self.idPlace != "" {
                        refPlace.child(self.idPlace).observeSingleEvent(of: .value, with: { (snapshot) in
                            if snapshot.value as? NSDictionary != nil {
                                if let snapPlace = snapshot.value as? NSDictionary {
                                    self.place.setTitle(snapPlace["title"] as? String ?? "", for: .normal)
                                    self.eventNotes = snapPlace["title"] as? String ?? ""
                                    self.placeName = snapPlace["title"] as? String ?? ""
                                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                                }
                            }
                        })
                } else {
                    self.eventNotes = val["place"] as? String ?? ""
                    self.place.setTitle(val["place"] as? String ?? "", for: .normal)
                    self.placeName = val["place"] as? String ?? ""
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }
                
                /*---------------------------------------*/

                if val["is_free"] as? String ?? "" == "false" {
                    if val["price"] as? String ?? "" == "" || val["price"] as? String ?? "" == "0" {
                        self.cost.text = "Уточните цену в месте проведения."
                    } else {
                        self.cost.text = val["price"] as? String ?? ""
                    }
                } else {
                    self.cost.text = "Бесплатно"
                }
                }
            }
        })
    }
    
    func loadDetailsSearchResultPonaminalu() {
        Alamofire.request("https://api.cultserv.ru/v4/subevents/get/?session=\(apiKeyPonaminalu)&id=\(self.searchId)&region_id=\(uds.value(forKey: "regionId") as! String)&promote=69399e321f034b29441a6a525c50a488", method: .get).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                if json["code"].stringValue == "1" {
                    self.nameDetails.text = json["message"]["title"].stringValue
                    self.eventName = json["message"]["title"].stringValue
                    self.fullDescription.text = Decoder().decodehtmltotxt(htmltxt: json["message"]["description"].stringValue)
                    self.cost.text = "от \(json["message"]["min_price"].stringValue) до \(json["message"]["max_price"].stringValue)"
                    self.startEvent.text = Decoder().dfPonam(date: json["message"]["date"].stringValue)
                    self.starEvent = json["message"]["date"].doubleValue
                    self.stopEvent.text = "Уточняйте"
                    self.seo = json["message"]["event"]["seo"]["alias"].stringValue
                    let imgURL: NSURL = NSURL(string: "http://media.cultserv.ru/i/300x200/\(json["message"]["image"].stringValue)")!
                    let imgData: NSData = NSData(contentsOf: imgURL as URL)!
                    let image: UIImageView = self.imageEvent
                    image.image = UIImage(data: imgData as Data)
                    self.place.setTitle(json["message"]["venue"]["title"].stringValue, for: .normal)
                    ManageData().saveEventToFB(agregator: self.targetName,
                                               key: json["message"]["event"]["id"].stringValue,
                                               title: json["message"]["title"].stringValue,
                                               short_title: json["message"]["title"].stringValue,
                                               is_free: "false",
                                               description: json["message"]["description"].stringValue,
                                               body_text: "",
                                               start_event: json["message"]["date"].stringValue,
                                               stop_event: "",
                                               place: json["message"]["venue"]["title"].stringValue,
                                               categories: json["message"]["categories"][0]["title"].stringValue,
                                               min_price: json["message"]["min_price"].stringValue,
                                               max_price: json["message"]["max_price"].stringValue,
                                               seo: json["message"]["event"]["seo"]["alias"].stringValue,
                                               eticket_possible: json["message"]["eticket_possible"].stringValue,
                                               image: json["message"]["image"].stringValue,
                                               age_restriction: json["message"]["age"].stringValue)
                    ManagePonaminaluEvent().descriptionEvent(id: self.searchId, idEvent: json["message"]["event"]["id"].stringValue)
                    self.getShotLink(URL: "")
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
                self.getShotLink(URL: json["site_url"].stringValue)
                self.nameDetails.text = json["title"].stringValue
                self.eventName = json["title"].stringValue
                self.fullDescription.text = json["body_text"].stringValue
                self.cost.text = json["price"].stringValue
                self.startEvent.text = Decoder().timeConvert(sec: json["dates"][0]["start"].stringValue)
                self.starEvent = json["dates"][0]["start"].doubleValue
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
    
    func getShotLink(URL: String) {
        var url: String!
        if targetName == "Ponaminalu" {
            url = "https://ponominalu.ru/event/\(seo)?promote=eda0f065aec3fce22d0708362ca67e48"
        } else if targetName == "KudaGo" {
            url = URL
        } else {
            url = "http://ya.ru"
        }
        Alamofire.request("https://www.googleapis.com/urlshortener/v1/url?key=AIzaSyA9cmcL-eNsQSpKwN5xkAvlbb8-B9PIuyo", method: .post, parameters: ["longUrl":url], encoding: JSONEncoding.default).validate().responseJSON { response in
            
            switch response.result {
            case .success(let value) :
                let json = JSON(value)
                self.shotURL = json["id"].url!
                
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ок", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
 
    //Идём смотреть инфу по месту проведения
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "place" {
            if idPlace != nil && idPlace != "" {
                let placeVC = segue.destination as! ShowPlaceViewController
                placeVC.placeId = idPlace
                placeVC.aggregator = targetName
            } else {
                showAlert(message: "Я пока не знаю где находится это место, но я выясняю. Как будет известно, то ты узнаешь об этом первым")
            }
        }
        if segue.identifier == "buyTicket" {
            let seq = segue.destination as! UINavigationController
            let buyVC = seq.topViewController as! BuyWebViewController
            buyVC.event = seo
        }
    }
}
