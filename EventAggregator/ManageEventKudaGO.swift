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
    //загружаем мероприятия
    func loadEventKudaGO() {
        if uds.value(forKey: "citySlug") as! String != "" {
            Alamofire.request(self.urlKudaGO+"events/?fields=id%2Cdates%2Cshort_title%2Cdescription%2Cis_free%2Ctitle%2Cbody_text%2Cplace%2Ccategories%2Cage_restriction%2Cimages%2Cparticipants%2Ctags&lang=ru&order_by=-publication_date&page_size=10&slug=\(uds.value(forKey: "citySlug") as! String)&text_format=text&page_size=100", method: .get).validate().responseJSON { response in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    var tmpIdPlace: [String] = []
                    for (_, subJSON) in json["results"] {
                        if idArr.contains(subJSON["title"].stringValue) {}
                        else {
                            let key = refEvent.child(UserDefaults.standard.value(forKey: "cityKey") as! String).childByAutoId().key
                            refEvent.child("\(uds.value(forKey: "cityKey") as! String)/Events/\(key)/id").setValue(subJSON["id"].stringValue)
                            refEvent.child("\(uds.value(forKey: "cityKey") as! String)/Events/\(key)/short_title").setValue(subJSON["short_title"].stringValue)
                            refEvent.child("\(uds.value(forKey: "cityKey") as! String)/Events/\(key)/description").setValue(subJSON["description"].stringValue)
                            refEvent.child("\(uds.value(forKey: "cityKey") as! String)/Events/\(key)/is_free").setValue(subJSON["is_free"].stringValue)
                            refEvent.child("\(uds.value(forKey: "cityKey") as! String)/Events/\(key)/start_event").setValue(self.decoder.timeConvert(sec: subJSON["dates"][0]["start"].stringValue))
                            refEvent.child("\(uds.value(forKey: "cityKey") as! String)/Events/\(key)/stop_event").setValue(self.decoder.timeConvert(sec: subJSON["dates"][0]["end"].stringValue))
                            refEvent.child("\(uds.value(forKey: "cityKey") as! String)/Events/\(key)/title").setValue(subJSON["title"].stringValue)
                            refEvent.child("\(uds.value(forKey: "cityKey") as! String)/Events/\(key)/body_text").setValue(subJSON["body_text"].stringValue)
                            refEvent.child("\(uds.value(forKey: "cityKey") as! String)/Events/\(key)/place").setValue(subJSON["place"]["id"].stringValue)
                            refEvent.child("\(uds.value(forKey: "cityKey") as! String)/Events/\(key)/categories").setValue(subJSON["categories"][0].stringValue)
                            refEvent.child("\(uds.value(forKey: "cityKey") as! String)/Events/\(key)/age_restriction").setValue(subJSON["age_restriction"].stringValue)
                            refEvent.child("\(uds.value(forKey: "cityKey") as! String)/Events/\(key)/price").setValue(subJSON["price"].stringValue)
                            refEvent.child("\(uds.value(forKey: "cityKey") as! String)/Events/\(key)/image").setValue(subJSON["images"][0]["image"].stringValue)
                            refEvent.child("\(uds.value(forKey: "cityKey") as! String)/Events/\(key)/participants").setValue(subJSON["participants"][0]["agent"]["title"].stringValue)
                            refEvent.child("\(uds.value(forKey: "cityKey") as! String)/Events/\(key)/Target").setValue("kudago")
                            for(index, subSubJSON) in subJSON["tags"] {
                                refEvent.child("\(uds.value(forKey: "cityKey") as! String)/Events/\(key)/tags/\(String(index))").setValue(subSubJSON.stringValue)
                            }
                            if subJSON["place"]["id"].stringValue != "" {
                                if tmpIdPlace.contains(subJSON["place"]["id"].stringValue) {}
                                else {
                                    self.loadPlaces(idPlace: subJSON["place"]["id"].stringValue)
                                    tmpIdPlace.append(subJSON["place"]["id"].stringValue)
                                }
                            }
                        }
                        
                    }
                    
                case .failure(let error):
                    print("ERROR",error)
                }
            }
        }

        uds.set(Int(NSDate().timeIntervalSince1970), forKey: "lastLoad")
    }
    
    func eventsOfTheDays() {
        refEvent.child(uds.value(forKey: "cityKey") as! String).observeSingleEvent(of: .value, with: { (snapshot) in
            if let value = snapshot.value as? NSDictionary {
                let slug = value["SLUG"] as? String ?? ""
                Alamofire.request(self.urlKudaGO+"events-of-the-day/?expand=event&text_format=text&location="+slug, method: .get).validate().responseJSON { response in
                    switch response.result {
                    case .success(let value):
                        let json = JSON(value)
                        for (index, subJSON) in json["results"] {
                            let image = subJSON["event"]["first_image"]["thumbnails"]["640x384"].stringValue
                            let id = subJSON["event"]["id"].stringValue
                            Database.database().reference().child("Top/KudaGo/\(uds.value(forKey: "cityKey") as! String)/\(index)/id").setValue(id)
                            Database.database().reference().child("Top/KudaGo/\(uds.value(forKey: "cityKey") as! String)/\(index)/image").setValue(image)
                        }
                    case .failure(let error):
                        print(error)
                    }
                }
            }
        })
    }
    //загружаем метсто проведения 
    func loadPlaces(idPlace: String) {
        Alamofire.request(self.urlKudaGO+"places/\(idPlace)/?lang=ru&text_format=text", method: .get).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                print(idPlace)
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
            }
        }
    }
    
    func loadCategory() {
        Alamofire.request(self.urlKudaGO+"place-categories/?lang=ru", method: .get).validate().responseJSON { response in
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
