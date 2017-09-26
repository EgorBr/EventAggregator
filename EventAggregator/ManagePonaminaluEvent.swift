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

class ManagePonaminaluEvent {
    
    let urlPonaminalu = "https://api.cultserv.ru/"
    let decoder: Decoder = Decoder()
    
    func loadCityPonaminalu() {
        
        Alamofire.request(urlPonaminalu+"v4/regions/list?session=\(apiKeyPonaminalu)", method: .get).validate().responseJSON(queue: concurrentQueue) { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                var tmp: [String] = ["Москва"]
                for (_, subJSON) in json["message"] {
                    
                    refEvent.observeSingleEvent(of: .value, with: { (snapshot) in
                        if let keyValue = snapshot.value as? NSDictionary {
                            for getKey in keyValue.allKeys {
                                refEvent.child(getKey as! String).observeSingleEvent(of: .value, with: { (snapshot) in
                                    if let tmpName = snapshot.value as? NSDictionary {
                                        let subtmpname = tmpName["NAME"] as? String ?? ""
                                        tmp.append(subtmpname)
                                        if subJSON["title"].stringValue == subtmpname {
                                            refEvent.child(getKey as! String).child("REGION_ID").setValue(subJSON["id"].stringValue)
                                        } else {
                                            if tmp.contains(subJSON["title"].stringValue) == false {
                                                tmp.append(subJSON["title"].stringValue)
//                                                print(subJSON["title"].stringValue)
                                            
                                            let key = refEvent.childByAutoId().key
                                            refEvent.child(key).child("NAME").setValue(subJSON["title"].stringValue)
                                            refEvent.child(key).child("REGION_ID").setValue(subJSON["id"].stringValue)
                                            }
                                        }
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
    
    
    func loadEventPonaminalu() {
        if uds.value(forKey: "regionId") as! String != "" {
            Alamofire.request(self.urlPonaminalu+"v4/events/list?session=\(apiKeyPonaminalu)&region_id=\(uds.value(forKey: "regionId") as! String)&limit=100", method: .get).validate().responseJSON(queue: concurrentQueue) { response in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    for (_, subJSON) in json["message"] {
                        if idArr.contains(subJSON["title"].stringValue) {}
                        else {
                            let key = refEvent.child(uds.value(forKey: "cityKey") as! String).childByAutoId().key
                            refEvent.child("\(uds.value(forKey: "cityKey") as! String)/Events/\(key)/id").setValue(subJSON["id"].stringValue)
                            refEvent.child("\(uds.value(forKey: "cityKey") as! String)/Events/\(key)/title").setValue(subJSON["title"].stringValue)
                            refEvent.child("\(uds.value(forKey: "cityKey") as! String)/Events/\(key)/short_title").setValue(subJSON["title"].stringValue)
                            refEvent.child("\(uds.value(forKey: "cityKey") as! String)/Events/\(key)/description").setValue(subJSON["description"].stringValue)
                            refEvent.child("\(uds.value(forKey: "cityKey") as! String)/Events/\(key)/is_free").setValue("false")
                            refEvent.child("\(uds.value(forKey: "cityKey") as! String)/Events/\(key)/start_event").setValue(self.decoder.dfPonam(date: subJSON["min_date"].stringValue))
                            refEvent.child("\(uds.value(forKey: "cityKey") as! String)/Events/\(key)/place").setValue(subJSON["subevents"][0]["venue"]["title"].stringValue)
                            refEvent.child("\(uds.value(forKey: "cityKey") as! String)/Events/\(key)/categories").setValue(subJSON["categories"][0]["title"].stringValue)
                            refEvent.child("\(uds.value(forKey: "cityKey") as! String)/Events/\(key)/price").setValue("от \(subJSON["min_price"].stringValue) до \(subJSON["max_price"].stringValue)")
                            refEvent.child("\(uds.value(forKey: "cityKey") as! String)/Events/\(key)/image").setValue("http://media.cultserv.ru/i/300x200/\(subJSON["subevents"][0]["image"].stringValue)")
                            refEvent.child("\(uds.value(forKey: "cityKey") as! String)/Events/\(key)/Target").setValue("ponaminalu")
                            refEvent.child("\(uds.value(forKey: "cityKey") as! String)/Events/\(key)/eticket_possible").setValue(subJSON["eticket_possible"].stringValue)
                        }
                    }
                    
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
    
    func descriptionEvent(id: String) {
        Alamofire.request(self.urlPonaminalu+"v4/subevents/description/get?session=\(apiKeyPonaminalu)", method: .get).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                
            case .failure(let error):
                print(error)
            }
        }
    }
}
