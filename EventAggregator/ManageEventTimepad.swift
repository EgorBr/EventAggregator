////
////  ManageEventTimepad.swift
////  EventAggregator
////?token=d6a66b1c5d4bd2fc34126bb189de991f7fb07d1c
////  Created by Egor Bryzgalov on 12.07.17.
////  Copyright © 2017 Egor Bryzgalov. All rights reserved.
////
//
import Alamofire
import SwiftyJSON
import RealmSwift
import FirebaseDatabase
//
//private let _manage = ManageEventTimepad()
//
class ManageEventTimepad {
//
    let urlTimepadEvent = "https://api.timepad.ru/v1/events.json"
    let urlEvent = "https://api.timepad.ru/v1/events/"

    func loadTimePadEvent() {
        let decodName = (uds.value(forKey: "city") as! String!).addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        Alamofire.request(urlTimepadEvent+"?limit=100&cities=\(decodName!)&sort=+starts_at&access_statuses=public", method: .get).validate().responseJSON() { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                for (_, subJSON) in json["values"] {
                    backQueue.async {
                        Alamofire.request(self.urlEvent+subJSON["id"].stringValue, method: .get).validate().responseJSON() { response in
                            switch response.result {
                            case .success(let value):
                                let json = JSON(value)
                                let key = subJSON["id"].stringValue + "T"
                                refEvent.child("\(uds.value(forKey: "city") as! String)/Events/\(key)/id").setValue(key)
                                refEvent.child("\(uds.value(forKey: "city") as! String)/Events/\(key)/target").setValue("TimePad")
                                refEvent.child("\(uds.value(forKey: "city") as! String)/Events/\(key)/title").setValue(Decoder().decodehtmltotxt(htmltxt: json["name"].stringValue))
                                refEvent.child("\(uds.value(forKey: "city") as! String)/Events/\(key)/short_title").setValue(Decoder().decodehtmltotxt(htmltxt: json["name"].stringValue))
                                refEvent.child("\(uds.value(forKey: "city") as! String)/Events/\(key)/body_text").setValue(Decoder().decodehtmltotxt(htmltxt: json["description_html"].stringValue))
                                refEvent.child("\(uds.value(forKey: "city") as! String)/Events/\(key)/description").setValue(Decoder().decodehtmltotxt(htmltxt: json["description_short"].stringValue))
                                refEvent.child("\(uds.value(forKey: "city") as! String)/Events/\(key)/categories").setValue(json["categories"][0]["name"].stringValue)
                                refEvent.child("\(uds.value(forKey: "city") as! String)/Events/\(key)/start_event").setValue(Decoder().timeConvertToSec(startTime: json["starts_at"].stringValue, from: "TimePad"))
                                refEvent.child("\(uds.value(forKey: "city") as! String)/Events/\(key)/stop_event").setValue(Decoder().timeConvertToSec(startTime: json["ends_at"].stringValue, from: "TimePad"))
                                if json["poster_image"]["default_url"].stringValue == "" {
                                    refEvent.child("\(uds.value(forKey: "city") as! String)/Events/\(key)/image").setValue("https://firebasestorage.googleapis.com/v0/b/aggreventus.appspot.com/o/No%20image%20available.jpg?alt=media&token=98a9c207-68d7-4957-a028-edbdbfe2d10f")
                                } else {
                                    refEvent.child("\(uds.value(forKey: "city") as! String)/Events/\(key)/image").setValue(json["poster_image"]["default_url"].stringValue)
                                }
                                
                                
                                refEvent.child("\(uds.value(forKey: "city") as! String)/Events/\(key)/url").setValue(json["url"].stringValue)
                                if json["ticket_types"][0]["price"].intValue == 0 || json["ticket_types"][0]["price"].stringValue == "" {
                                    refEvent.child("\(uds.value(forKey: "city") as! String)/Events/\(key)/is_free").setValue(true)
                                } else {
                                    refEvent.child("\(uds.value(forKey: "city") as! String)/Events/\(key)/is_free").setValue(false)
                                    refEvent.child("\(uds.value(forKey: "city") as! String)/Events/\(key)/price").setValue("от \(json["ticket_types"][0]["price"].stringValue)")
                                }
                                refEvent.child("\(uds.value(forKey: "city") as! String)/Events/\(key)/min").setValue(json["ticket_types"][0]["price"].intValue)
                                refEvent.child("\(uds.value(forKey: "city") as! String)/Events/\(key)/place").setValue(json["organization"]["id"].stringValue + "T")
                                
                                refPlace.child("\(json["organization"]["id"].stringValue + "T")/id").setValue(json["organization"]["id"].stringValue + "T")
                                refPlace.child("\(json["organization"]["id"].stringValue + "T")/title").setValue(Decoder().decodehtmltotxt(htmltxt: json["organization"]["name"].stringValue))
                                refPlace.child("\(json["organization"]["id"].stringValue + "T")/description").setValue(json["organization"]["description_html"].stringValue)
                                //
                                for (index, i) in json["location"]["coordinates"] {
                                    if Int(index) == 0 {
                                        refPlace.child("\(json["organization"]["id"].stringValue + "T")/coords/lat").setValue(String(describing: i))
                                    } else if Int(index) == 1 {
                                        refPlace.child("\(json["organization"]["id"].stringValue + "T")/coords/lon").setValue(String(describing: i))
                                    }
                                }
                                
                            case .failure(let error):
                                print("ERROR!!!!!\(subJSON["id"])",error)
                            }
                        }
                    }
                }
                
            case .failure(let error):
                print(error)
            }
        }
    }
}


