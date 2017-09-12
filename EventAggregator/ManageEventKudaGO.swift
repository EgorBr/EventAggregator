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
    
//    func loadCityKudaGo() {
//        
//        Alamofire.request(urlKudaGO+"locations/?lang=ru", method: .get).validate().responseJSON { response in
//            switch response.result {
//            case .success(let value):
//                let json = JSON(value)
////                refEvent.removeValue()
//                for (_, subJSON) in json[] {
//                    let key = refEvent.childByAutoId().key
//                    refEvent.child(key).child("NAME").setValue(subJSON["name"].stringValue)
//                    refEvent.child(key).child("SLUG").setValue(subJSON["slug"].stringValue)
//                }
//            case .failure(let error):
//                print(error)
//            }
//        }
//    }
    
    func loadEventKudaGO() {
        refEvent.child(uds.value(forKey: "globalCityKey") as! String).observeSingleEvent(of: .value, with: { (snapshot) in
            if let value = snapshot.value as? NSDictionary {
                let slug = value["SLUG"] as? String ?? ""
                Alamofire.request(self.urlKudaGO+"events/?fields=id%2Cdates%2Cshort_title%2Cdescription%2Cis_free%2Ctitle%2Cbody_text%2Cplace%2Ccategories%2Cage_restriction%2Cimages%2Cparticipants%2Ctags&lang=ru&order_by=-publication_date&page_size=10&slug=\(slug)&text_format=text&page_size=100", method: .get).validate().responseJSON { response in
                    switch response.result {
                    case .success(let value):
                        let json = JSON(value)
                        print(idArr)
                        for (_, subJSON) in json["results"] {
                            if idArr.contains(subJSON["id"].stringValue) {}
                            else {
                                let key = refEvent.child(UserDefaults.standard.value(forKey: "globalCityKey") as! String).childByAutoId().key
                                refEvent.child(uds.value(forKey: "globalCityKey") as! String).child("Events").child(key).child("id").setValue(subJSON["id"].stringValue)
                                refEvent.child(uds.value(forKey: "globalCityKey") as! String).child("Events").child(key).child("short_title").setValue(subJSON["short_title"].stringValue)
                                refEvent.child(uds.value(forKey: "globalCityKey") as! String).child("Events").child(key).child("description").setValue(subJSON["description"].stringValue)
                                refEvent.child(uds.value(forKey: "globalCityKey") as! String).child("Events").child(key).child("is_free").setValue(subJSON["is_free"].stringValue)
                                refEvent.child(uds.value(forKey: "globalCityKey") as! String).child("Events").child(key).child("start_event").setValue(self.decoder.timeConvert(sec: subJSON["dates"][0]["start"].stringValue))
                                refEvent.child(uds.value(forKey: "globalCityKey") as! String).child("Events").child(key).child("stop_event").setValue(self.decoder.timeConvert(sec: subJSON["dates"][0]["end"].stringValue))
                                refEvent.child(uds.value(forKey: "globalCityKey") as! String).child("Events").child(key).child("title").setValue(subJSON["title"].stringValue)
                                refEvent.child(uds.value(forKey: "globalCityKey") as! String).child("Events").child(key).child("body_text").setValue(subJSON["body_text"].stringValue)
                                refEvent.child(uds.value(forKey: "globalCityKey") as! String).child("Events").child(key).child("place").setValue(subJSON["place"]["id"].stringValue)
                                refEvent.child(uds.value(forKey: "globalCityKey") as! String).child("Events").child(key).child("categories").setValue(subJSON["categories"][0].stringValue)
                                refEvent.child(uds.value(forKey: "globalCityKey") as! String).child("Events").child(key).child("age_restriction").setValue(subJSON["age_restriction"].stringValue)
                                refEvent.child(uds.value(forKey: "globalCityKey") as! String).child("Events").child(key).child("price").setValue(subJSON["price"].stringValue)
                                refEvent.child(uds.value(forKey: "globalCityKey") as! String).child("Events").child(key).child("image").setValue(subJSON["images"][0]["image"].stringValue)
                                refEvent.child(uds.value(forKey: "globalCityKey") as! String).child("Events").child(key).child("participants").setValue(subJSON["participants"][0]["agent"]["title"].stringValue)
                                refEvent.child(uds.value(forKey: "globalCityKey") as! String).child("Events").child(key).child("KudaGo").setValue("1")
                                for(index, subSubJSON) in subJSON["tags"] {
                                    refEvent.child(uds.value(forKey: "globalCityKey") as! String).child("Events").child(key).child("tags").child(String(index)).setValue(subSubJSON.stringValue)
                                }
                                self.loadPlaces(idPlace: subJSON["place"]["id"].stringValue)
                            }
                            
                        }
                        
                    case .failure(let error):
                        print("",error)
                    }
                }
            }
        })
        uds.set(Int(NSDate().timeIntervalSince1970), forKey: "lastLoad")
    }
    
    
    func loadPlaces(idPlace: String) {
        Alamofire.request(self.urlKudaGO+"places/\(idPlace)/?lang=ru&text_format=text", method: .get).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                refPlace.child(idPlace).child("id").setValue(json["id"].stringValue)
                refPlace.child(idPlace).child("short_title").setValue(json["short_title"].stringValue)
                refPlace.child(idPlace).child("title").setValue(json["title"].stringValue)
                refPlace.child(idPlace).child("description").setValue(json["description"].stringValue)
                refPlace.child(idPlace).child("age_restriction").setValue(json["age_restriction"].stringValue)
                refPlace.child(idPlace).child("subway").setValue(json["subway"].stringValue)
                refPlace.child(idPlace).child("address").setValue(json["address"].stringValue)
                refPlace.child(idPlace).child("phone").setValue(json["phone"].stringValue)
                for (index, subJSONimage) in json["images"] {
                    refPlace.child(idPlace).child("images").child(String(index)).setValue(subJSONimage["image"].stringValue)
                }
                for (index, subJSONcategories) in json["categories"] {
                    refPlace.child(idPlace).child("categories").child(String(index)).setValue(subJSONcategories.stringValue)
                }
                
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func printNamePlace(idPlace: String) {
//        var placeName: String = ""
        refPlace.child(idPlace).observeSingleEvent(of: .value, with: { (snapshot) in
            if let value = snapshot.value as? NSDictionary {
                let tmpPlaceName = value["short_title"] as? String ?? ""
                if tmpPlaceName == "" {
                    self.loadPlaces(idPlace: idPlace)
                } else {
//                place = tmpPlaceName
                }
            }
        })
        
    }
    
//    func loadCategory() {
//        Alamofire.request(self.urlKudaGO+"place-categories/?lang=ru", method: .get).validate().responseJSON { response in
//            switch response.result {
//            case .success(let value):
//                let json = JSON(value)
//                for (_, subJSON) in json {
//                    print(subJSON)
//                    let key = refCategory.childByAutoId().key
//                    refCategory.child(key).child("name").setValue(subJSON["name"].stringValue)
//                    refCategory.child(key).child("slug").setValue(subJSON["slug"].stringValue)
//
//                }
//                
//            case .failure(let error):
//                print(error)
//            }
//        }
//    }    
}
