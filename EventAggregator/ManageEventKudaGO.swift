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

class ManageEventKudaGO {
    
    let urlKudaGO = "https://kudago.com/public-api/v1.3/"
    
    
    func loadcitykudago() {
        Alamofire.request(urlKudaGO+"locations/?lang=ru", method: .get).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                for (_, subJSON) in json[] {
                    let insertCity = CityEvent()
                    insertCity.name = subJSON["name"].stringValue
                    insertCity.slug = subJSON["slug"].stringValue
                    let realm = try! Realm()
                    try! realm.write {
                        realm.add(insertCity, update: true)
                    }
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func loadDetailsKudaGO(name: String, slug: String, number: Int) {
        Alamofire.request(urlKudaGO+"events/?lang=ru&slug=\(slug)&page_size=\(number)", method: .get).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                let insertEvent = EventKudaGO()
                let cityName = CityEvent()
                cityName.slug = slug
                cityName.name = name
                for (_, subJSON) in json["results"] {
                    insertEvent.kudago_id = subJSON["id"].stringValue
                    insertEvent.name = subJSON["title"].stringValue
                    print(insertEvent)
                    cityName.kudagoList.append(insertEvent)
                    print(cityName.kudagoList)
                }
                let realm = try! Realm()
                try! realm.write {
//                    print(cityName.kudagoList)
                    realm.add(cityName, update: true)
                }
            case .failure(let error):
                print(error)
            }
        }
    }
}
