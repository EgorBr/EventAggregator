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
        let realm = try! Realm()
        Alamofire.request(urlKudaGO+"locations/?lang=ru", method: .get).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                for (_, subJSON) in json[] {
                    let insCity = CityEvent()
                    insCity.name = subJSON["name"].stringValue
                    insCity.slug = subJSON["slug"].stringValue
                    try! realm.write {
                        realm.add(insCity, update: true)
                    }
                }
            case .failure(let error):
                print(error)
            }
        }
        loadDetailsKudaGO()
    }
    
    func loadDetailsKudaGO() {
        let realm = try! Realm()
        Alamofire.request(urlKudaGO+"events/?lang=ru&slug=msk", method: .get).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                
                print(json)
                
            case .failure(let error):
                print(error)
            }
        }
    }
}
