//
//  ManageEventKudaGO.swift
//  EventAggregator
//
//  Created by Egor Bryzgalov on 27.07.17.
//  Copyright © 2017 Egor Bryzgalov. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import RealmSwift
import FirebaseDatabase

class ManageEventKudaGO {
    
    let urlKudaGO = "https://kudago.com/public-api/v1.3/"
    
    let decoder: Decoder = Decoder()
//    var ref: DatabaseReference!
    
    func loadCityKudaGo() {
        
        Alamofire.request(urlKudaGO+"locations/?lang=ru", method: .get).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
//                refEvent.removeValue()
                for (_, subJSON) in json[] {
                    let key = refEvent.childByAutoId().key
                    refEvent.child(key).child("NAME").setValue(subJSON["name"].stringValue)
                    refEvent.child(key).child("SLUG").setValue(subJSON["slug"].stringValue)
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func loadEventKudaGO(name: String) {
//        var key: String = ""
        
        refEvent.observeSingleEvent(of: .value, with: { (snapshot) in
            if let keyValue = snapshot.value as? NSDictionary {
                for getKey in keyValue.allKeys {
                    refEvent.child(getKey as! String).observeSingleEvent(of: .value, with: { (snapshot) in
                        if let tmpName = snapshot.value as? NSDictionary {
                            let subtmpname = tmpName["NAME"] as? String ?? ""
                            if name == subtmpname {
                                globalCityKey = getKey as! String
                                loadForKey(cityKey: globalCityKey)
                            }
                        }
                    })
                }
            }
        })
        func loadForKey(cityKey: String) {
            refEvent.child(cityKey).observeSingleEvent(of: .value, with: { (snapshot) in
                
                if let value = snapshot.value as? NSDictionary {
                    let slug = value["SLUG"] as? String ?? ""
                    
                    Alamofire.request(self.urlKudaGO+"events/?fields=id%2Cdates%2Cshort_title%2Cdescription%2Cis_free&lang=ru&order_by=-publication_date&page_size=10&slug=\(slug)&text_format=text&page_size=100", method: .get).validate().responseJSON { response in
                        switch response.result {
                        case .success(let value):
                            let json = JSON(value)
                            for (_, subJSON) in json["results"] {
                                refEvent.child(cityKey).observeSingleEvent(of: .value, with: { (snapshot) in
                                    if let value = snapshot.value as? NSDictionary {
                                        let id = value["id"] as? String ?? ""
                                        if id != subJSON["id"].stringValue {
                                            
                                        }
                                    }
//                                let key = refEvent.child(name).childByAutoId().key
//                                refEvent.child(cityKey).child("Events").child(key).child("id").setValue(subJSON["id"].stringValue)
//                                refEvent.child(cityKey).child("Events").child(key).child("short_title").setValue(subJSON["short_title"].stringValue)
//                                refEvent.child(cityKey).child("Events").child(key).child("description").setValue(subJSON["description"].stringValue)
//                                refEvent.child(cityKey).child("Events").child(key).child("is_free").setValue(subJSON["is_free"].stringValue)
//                                refEvent.child(cityKey).child("Events").child(key).child("start_event").setValue(self.decoder.timeConvert(sec: subJSON["dates"][0]["start"].stringValue))
//                                refEvent.child(cityKey).child("Events").child(key).child("stop_event").setValue(self.decoder.timeConvert(sec: subJSON["dates"][0]["end"].stringValue))
                                    
                                })
                            }
                            
                        case .failure(let error):
                            print("",error)
                        }
                    }
                }
            })
        }
    }
    
    func loadDetailsEventKudaGo(eventKey: String) {
            refEvent.child(globalCityKey).child("Events").child(eventKey).observe(.value, with: { snapshot in
                if let value = snapshot.value as? NSDictionary {
//                    print(value)
//                    let slug = value["SLUG"] as? String ?? ""
//                    if tableID == id {
//                        Alamofire.request(self.urlKudaGO+"events/\(id)/?lang=ru&text_format=text", method: .get).validate().responseJSON { response in
//                            switch response.result {
//                            case .success(let value):
//                                let json = JSON(value)
//                                refEvent.child(globalCityKey).child("Events").child(eventKey).child("title").setValue(json["title"].stringValue)
//                                refEvent.child(globalCityKey).child("Events").child(eventKey).child("body_text").setValue(json["body_text"].stringValue)
//                                refEvent.child(globalCityKey).child("Events").child(eventKey).child("place").setValue(json["place"]["id"].stringValue)
//                                refEvent.child(globalCityKey).child("Events").child(eventKey).child("categories").setValue(json["categories"][0].stringValue)
//                                refEvent.child(globalCityKey).child("Events").child(eventKey).child("age_restriction").setValue(json["age_restriction"].stringValue)
//                                refEvent.child(globalCityKey).child("Events").child(eventKey).child("price").setValue(json["price"].stringValue)
//                                refEvent.child(globalCityKey).child("Events").child(eventKey).child("image").setValue(json["images"][0]["image"].stringValue)
//                                refEvent.child(globalCityKey).child("Events").child(eventKey).child("participants").setValue(json["participants"][0]["agent"]["title"].stringValue)
//                                for(subIndex, subJSON) in json["tags"] {
//                                    refEvent.child(globalCityKey).child("Events").child(eventKey).child("tags").child(String(subIndex)).setValue(subJSON.stringValue)
//                                }
//                            case .failure(let error):
//                                print(error)
//                            }
//                        }
//                    }
                }
            })
        
    }
    
    func loadPlaces() {
        print("Start")
        Alamofire.request(self.urlKudaGO+"places/?lang=ru&text_format=text&page_size=100", method: .get).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                for (index, subJSON) in json["results"] {
                    refPlace.child(String(index)).child("id").setValue(subJSON["id"].stringValue)
                    refPlace.child(String(index)).child("slug").setValue(subJSON["slug"].stringValue)
                    refPlace.child(String(index)).child("address").setValue(subJSON["address"].stringValue)
                    refPlace.child(String(index)).child("phone").setValue(subJSON["phone"].stringValue)
                    refPlace.child(String(index)).child("id").setValue(subJSON["id"].stringValue)
                    refPlace.child(String(index)).child("title").setValue(subJSON["title"].stringValue)
                    refPlace.child(String(index)).child("subway").setValue(subJSON["subway"].stringValue)
                    refPlace.child(String(index)).child("is_closed").setValue(subJSON["is_closed"].stringValue)
                }
                
            case .failure(let error):
                print(error)
            }
        }
    }
}
