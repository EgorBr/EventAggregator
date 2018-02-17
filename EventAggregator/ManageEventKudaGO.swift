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
//        Alamofire.request(urlKudaGO+"locations/?lang=ru", method: .get).validate().responseJSON { response in
//            switch response.result {
//            case .success(let value):
//                let json = JSON(value)
//                for (_, subJSON) in json[] {
//                    refEvent.child("\(subJSON["name"].stringValue)/Name").setValue(subJSON["name"].stringValue)
//                    refEvent.child("\(subJSON["name"].stringValue)/Slug").setValue(subJSON["slug"].stringValue)
//                }
//            case .failure(let error):
//                print(error)
//            }
//        }
//    }
    //загружаем мероприятия
    func loadEventKudaGO() {
        nameLoadStage = "Загружаем мероприятия KudaGo"
        countLoad += 1
        if uds.value(forKey: "citySlug") as! String != "" {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            Alamofire.request(self.urlKudaGO+"events/?fields=id%2Cdates%2Cshort_title%2Cdescription%2Cis_free%2Ctitle%2Cbody_text%2Cplace%2Ccategories%2Cage_restriction%2Cimages%2Cparticipants%2Ctags&lang=ru&order_by=-publication_date&page_size=10&location=\(uds.value(forKey: "citySlug") as! String)&text_format=text&page_size=100&page=1", method: .get).validate().responseJSON { response in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    var tmpIdPlace: [String] = []
                    for (index, subJSON) in json["results"] {
                        if  Int(NSDate().timeIntervalSince1970) - subJSON["dates"][0]["start"].intValue >= 1800 {
                            let key = subJSON["id"].stringValue + "K"
                            refEvent.child("\(uds.value(forKey: "city") as! String)/Events/\(key)/id").setValue(key)
                            refEvent.child("\(uds.value(forKey: "city") as! String)/Events/\(key)/short_title").setValue(subJSON["short_title"].stringValue)
                            refEvent.child("\(uds.value(forKey: "city") as! String)/Events/\(key)/description").setValue(subJSON["description"].stringValue)
                            refEvent.child("\(uds.value(forKey: "city") as! String)/Events/\(key)/is_free").setValue(subJSON["is_free"].stringValue)
                            refEvent.child("\(uds.value(forKey: "city") as! String)/Events/\(key)/start_event").setValue(subJSON["dates"][0]["start"].intValue)
                            refEvent.child("\(uds.value(forKey: "city") as! String)/Events/\(key)/stop_event").setValue(subJSON["dates"][0]["end"].intValue)
                            refEvent.child("\(uds.value(forKey: "city") as! String)/Events/\(key)/title").setValue(subJSON["title"].stringValue)
                            refEvent.child("\(uds.value(forKey: "city") as! String)/Events/\(key)/body_text").setValue(subJSON["body_text"].stringValue)
                            refEvent.child("\(uds.value(forKey: "city") as! String)/Events/\(key)/place").setValue(subJSON["place"]["id"].stringValue)
                            refEvent.child("\(uds.value(forKey: "city") as! String)/Events/\(key)/categories").setValue(subJSON["categories"][0].stringValue)
                            refEvent.child("\(uds.value(forKey: "city") as! String)/Events/\(key)/age_restriction").setValue(subJSON["age_restriction"].stringValue)
                            if subJSON["price"].stringValue == "" {
                                refEvent.child("\(uds.value(forKey: "city") as! String)/Events/\(key)/price").setValue("0")
                            } else {
                                refEvent.child("\(uds.value(forKey: "city") as! String)/Events/\(key)/price").setValue(subJSON["price"].stringValue)
                            }
                            refEvent.child("\(uds.value(forKey: "city") as! String)/Events/\(key)/image").setValue(subJSON["images"][0]["image"].stringValue)
                            refEvent.child("\(uds.value(forKey: "city") as! String)/Events/\(key)/participants").setValue(subJSON["participants"][0]["agent"]["title"].stringValue)
                            refEvent.child("\(uds.value(forKey: "city") as! String)/Events/\(key)/target").setValue("KudaGo")
                            for(index, subSubJSON) in subJSON["tags"] {
                                refEvent.child("\(uds.value(forKey: "city") as! String)/Events/\(key)/tags/\(String(index)!)").setValue(subSubJSON.stringValue)
                            }
                            if subJSON["place"]["id"].stringValue != "" {
                                if tmpIdPlace.contains(subJSON["place"]["id"].stringValue) == false{
                                    self.loadPlaces(idPlace: subJSON["place"]["id"].stringValue)
                                    tmpIdPlace.append(subJSON["place"]["id"].stringValue)
                                }
                            }
                        }
                        if Int(index)! + 1 == json["results"].count {
                            persentLoad += statusLoad
                        }
                        
                    }
//                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                case .failure(let error):
                    print("ERROR",error)
                }
            }
        }

        uds.set(Int(NSDate().timeIntervalSince1970), forKey: "lastLoad")
    }
    
    //загружаем метсто проведения 
    func loadPlaces(idPlace: String) {
        Alamofire.request(self.urlKudaGO+"places/\(idPlace)/?lang=ru&text_format=text", method: .get).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                refPlace.child("\(idPlace)/id").setValue(json["id"].stringValue)
                refPlace.child("\(idPlace)/short_title").setValue(json["short_title"].stringValue)
                refPlace.child("\(idPlace)/title").setValue(json["title"].stringValue)
                refPlace.child("\(idPlace)/description").setValue(json["description"].stringValue)
                refPlace.child("\(idPlace)/age_restriction").setValue(json["age_restriction"].stringValue)
                refPlace.child("\(idPlace)/subway").setValue(json["subway"].stringValue)
                refPlace.child("\(idPlace)/address").setValue(json["address"].stringValue)
                refPlace.child("\(idPlace)/phone").setValue(json["phone"].stringValue)
                refPlace.child("\(idPlace)/location").setValue(json["location"].stringValue)
                for (index, subJSONimage) in json["images"] {
                    refPlace.child("\(idPlace)/images").child(String(index)).setValue(subJSONimage["image"].stringValue)
                }
                for (index, subJSONcategories) in json["categories"] {
                    refPlace.child("\(idPlace)/categories").child(String(index)).setValue(subJSONcategories.stringValue)
                }
                refPlace.child("\(idPlace)/coords/lat").setValue(json["coords"]["lat"].stringValue)
                refPlace.child("\(idPlace)/coords/lon").setValue(json["coords"]["lon"].stringValue)
            case .failure(let error):
                print(error)
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }
    
    func loadCategory() {
        Alamofire.request(self.urlKudaGO+"event-categories/?lang=ru", method: .get).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                for (_, subJSON) in json {
                    print(subJSON)
                    let key = refCategory.childByAutoId().key
                    refCategory.child(key).child("name").setValue(subJSON["name"].stringValue)
                    refCategory.child(key).child("slug").setValue(subJSON["slug"].stringValue)
                }
            case .failure(let error):
                print(error)
            }
        }
    }    
}
