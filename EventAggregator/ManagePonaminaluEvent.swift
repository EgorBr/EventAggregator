//
//  ManagePonaminaluEvent.swift
//  EventAggregator
//
//  Created by Egor Bryzgalov on 07.09.17.
//  Copyright © 2017 Egor Bryzgalov. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import FirebaseDatabase

class ManagePonaminaluEvent: Decoder {
    
    let decoder: Decoder = Decoder()
        
//    func loadCityPonaminalu() {
//
//        Alamofire.request(urlPonaminalu+"v4/regions/list?session=\(apiKeyPonaminalu)", method: .get).validate().responseJSON(queue: concurrentQueue) { response in
//            switch response.result {
//            case .success(let value):
//                let json = JSON(value)
//                var tmp: [String] = ["Москва"]
//                for (_, subJSON) in json["message"] {
//                    refEvent.observeSingleEvent(of: .value, with: { (snapshot) in
//                        if let keyValue = snapshot.value as? NSDictionary {
//                            for getKey in keyValue.allKeys {
//                                refEvent.child(getKey as! String).observeSingleEvent(of: .value, with: { (snapshot) in
//                                    if let tmpName = snapshot.value as? NSDictionary {
//                                        let subtmpname = tmpName["Name"] as? String ?? ""
//                                        tmp.append(subtmpname)
//                                        if subJSON["title"].stringValue == subtmpname {
//                                            refEvent.child(getKey as! String).child("Region_id").setValue(subJSON["id"].stringValue)
//                                        } else {
//                                            if tmp.contains(subJSON["title"].stringValue) == false {
//                                                tmp.append(subJSON["title"].stringValue)
////                                                print(subJSON["title"].stringValue)
//
//                                            refEvent.child("\(subJSON["title"].stringValue)/Name").setValue(subJSON["title"].stringValue)
//                                            refEvent.child("\(subJSON["title"].stringValue)/Region_id").setValue(subJSON["id"].stringValue)
//                                            }
//                                        }
//                                    }
//                                })
//                            }
//                        }
//                    })
//
//                }
//            case .failure(let error):
//                print(error)
//            }
//        }
//    }
    
    
    func loadEventPonaminalu() {
        nameLoadStage = "Загружаем мероприятия Ponominalu"
        countLoad += 1
        if uds.value(forKey: "regionId") as! String != "" {
            Alamofire.request("https://api.cultserv.ru/v4/events/list?session=\(apiKeyPonaminalu)&region_id=\(uds.value(forKey: "regionId") as! String)&limit=100", method: .get).validate().responseJSON(queue: concurrentQueue) { response in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    for (index, subJSON) in json["message"] {
                        backQueue.async {
                            let key = subJSON["id"].stringValue + "P"
                            refEvent.child("\(uds.value(forKey: "city") as! String)/Events/\(key)/id").setValue(key)
                            refEvent.child("\(uds.value(forKey: "city") as! String)/Events/\(key)/title").setValue(subJSON["title"].stringValue)
                            refEvent.child("\(uds.value(forKey: "city") as! String)/Events/\(key)/short_title").setValue(subJSON["title"].stringValue)
                            self.descriptionEvent(id: subJSON["subevents"][0]["id"].stringValue, idEvent: subJSON["id"].stringValue)
                            refEvent.child("\(uds.value(forKey: "city") as! String)/Events/\(key)/is_free").setValue("false")
                            refEvent.child("\(uds.value(forKey: "city") as! String)/Events/\(key)/description").setValue(self.decoder.decodehtmltotxt(htmltxt: subJSON["description"].stringValue) )
                            refEvent.child("\(uds.value(forKey: "city") as! String)/Events/\(key)/start_event").setValue(self.decoder.timeConvertToSec(startTime: subJSON["min_date"].stringValue, from: "Ponaminalu"))
                            refEvent.child("\(uds.value(forKey: "city") as! String)/Events/\(key)/place").setValue(subJSON["subevents"][0]["venue"]["title"].stringValue)
                            refEvent.child("\(uds.value(forKey: "city") as! String)/Events/\(key)/categories").setValue(subJSON["categories"][0]["alias"].stringValue)
                            refEvent.child("\(uds.value(forKey: "city") as! String)/Events/\(key)/min").setValue(subJSON["min_price"].intValue)
                            refEvent.child("\(uds.value(forKey: "city") as! String)/Events/\(key)/price").setValue("от \(subJSON["min_price"].stringValue) до \(subJSON["max_price"].stringValue)")
                            refEvent.child("\(uds.value(forKey: "city") as! String)/Events/\(key)/seo").setValue(subJSON["seo"]["alias"].stringValue)
                            refEvent.child("\(uds.value(forKey: "city") as! String)/Events/\(key)/target").setValue("Ponaminalu")
                            refEvent.child("\(uds.value(forKey: "city") as! String)/Events/\(key)/image").setValue("http://media.cultserv.ru/i/300x200/\(subJSON["subevents"][0]["image"].stringValue)")
                            refEvent.child("\(uds.value(forKey: "city") as! String)/Events/\(key)/eticket_possible").setValue(subJSON["eticket_possible"].stringValue)
                            
                            
                            refPlace.child("\(subJSON["subevents"][0]["venue"]["id"].stringValue)P/id").setValue(subJSON["subevents"][0]["venue"]["id"].stringValue + "P")
                            refPlace.child("\(subJSON["subevents"][0]["venue"]["id"].stringValue)P/title").setValue(subJSON["subevents"][0]["venue"]["title"].stringValue)
                            refPlace.child("\(subJSON["subevents"][0]["venue"]["id"].stringValue)P/address").setValue(subJSON["subevents"][0]["venue"]["address"].stringValue)
                            refPlace.child("\(subJSON["subevents"][0]["venue"]["id"].stringValue)P/coords/lat").setValue(subJSON["subevents"][0]["venue"]["google_address"].stringValue)
                            refPlace.child("\(subJSON["subevents"][0]["venue"]["id"].stringValue)P/coords/lon").setValue(subJSON["subevents"][0]["venue"]["google_address"].stringValue)
                        }
                        if Int(index)! + 1 == json["message"].count {
                            persentLoad += statusLoad
                        }
                    }
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
    
    func descriptionEvent(id: String, idEvent: String) {
        Alamofire.request("https://api.cultserv.ru/v4/subevents/description/get?session=\(apiKeyPonaminalu)&id=\(id)", method: .get).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                refEvent.child("\(uds.value(forKey: "city") as! String)/Events/\(idEvent)P/body_text").setValue(self.decoder.decodehtmltotxt(htmltxt: json["message"].stringValue))
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func manageCategory() {
        Alamofire.request("https://api.cultserv.ru/v4/categories/list?session=\(apiKeyPonaminalu)", method: .get).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                var tmpAlis: [String] = []
                for (_, subJSON) in json["message"] {
                    refCategory.observeSingleEvent(of: .value, with: {(snapshot) in
                        if let keyVCategory = snapshot.value as? NSDictionary {
                            for keyCat in keyVCategory.allKeys {
                                refCategory.child(keyCat as! String).observeSingleEvent(of: .value, with: {(snapshot) in
                                    if let alias = snapshot.value as? NSDictionary {
                                        let name = alias["name"]  as? String ?? ""
                                        if subJSON["title"].stringValue != name {
                                            if tmpAlis.contains(subJSON["title"].stringValue) {}
                                            else {
                                                tmpAlis.append(subJSON["title"].stringValue)
                                                let key = refCategory.childByAutoId().key
                                                refCategory.child("\(key)/name").setValue(subJSON["title"].stringValue)
                                                refCategory.child("\(key)/slug").setValue(subJSON["alias"].stringValue)
//                                                refCategory.child("\(key)/events_count").setValue(subJSON["events_count"].stringValue)
                                            }
                                        }
//
                                    }
                                })
                            }
                        }
                    })
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
}
