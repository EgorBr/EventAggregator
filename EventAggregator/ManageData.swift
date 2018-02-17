//
//  ManageData.swift
//  EventAggregator
//
//  Created by Egor Bryzgalov on 16.01.2018.
//  Copyright © 2018 Egor Bryzgalov. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class ManageData {
    
    let decoder: Decoder = Decoder()
    let utils: Utils = Utils()
    
    func saveEventToFB (agregator: String,
                        key: String,
                        title: String,
                        short_title: String,
                        is_free: String,
                        description: String,
                        body_text: String,
                        start_event: String,
                        stop_event: String,
                        place: String,
                        categories: String,
                        min_price: String,
                        max_price: String,
                        seo: String,
                        eticket_possible: String,
                        image: String,
                        age_restriction: String) {
        
        let reference = refEvent.child("\(uds.value(forKey: "city") as! String)/Events/")
        
        reference.child("\(key)/id").setValue(key)
        reference.child("\(key)/title").setValue(title)
        reference.child("\(key)/short_title").setValue(short_title)
//        self.descriptionEvent(id: subJSON["subevents"][0]["id"].stringValue, idEvent: subJSON["id"].stringValue, aggregator: aggr )
        reference.child("\(key)/is_free").setValue("false")
        reference.child("\(key)/description").setValue(self.decoder.decodehtmltotxt(htmltxt: description))
        reference.child("\(key)/place").setValue(place)
        reference.child("\(key)/categories").setValue(categories)
        reference.child("\(key)/price").setValue("от \(min_price) до \(max_price)")
        reference.child("\(key)/min").setValue(Int(min_price))
//        reference.child("\(key)/target").setValue(agregator)

        if key.characters.last! == "K"{
            reference.child("\(key)/age_restriction").setValue(age_restriction)
        }

        if key.characters.last! == "P" {
            reference.child("\(key)/start_event").setValue(self.decoder.timeConvertToSec(startTime: start_event, from: "Ponaminalu"))
        } else {
            reference.child("\(key)/start_event").setValue(start_event)
            reference.child("\(key)/stop_event").setValue(stop_event)
        }
        
        if key.characters.last! == "P" {
            reference.child("\(key)/seo").setValue(seo)
        }
        
        if key.characters.last! == "P" {
            reference.child("\(key)/image").setValue("http://media.cultserv.ru/i/300x200/\(image)")
        } else {
            reference.child("\(key)/image").setValue(image)
        }
        
        if key.characters.last! == "P" {
            reference.child("\(key)/eticket_possible").setValue(eticket_possible)
        }
        if key.characters.last! == "K" {
            reference.child("\(key)/body_text").setValue(self.decoder.decodehtmltotxt(htmltxt: body_text))
        } 
    }

    func loadNews() {
//        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        Alamofire.request("https://kudago.com/public-api/v1.2/news/?fields=id,title,description,images&order_by=-publication_date&text_format=text&location=\(uds.value(forKey: "citySlug") as! String)", method: .get).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                for (_, value) in json["results"] {
                    idCellNews.append(value["id"].stringValue)
                    titleCellNews.append(value["title"].stringValue)
                    descriptionCellNews.append(value["description"].stringValue)
                    imgCellNews.append(self.utils.loadImage(url: value["images"][0]["image"].stringValue))

                }
                
            case .failure(let error):
                print(error)
            }
        }
    }
    
}
