//
//  LoadDB.swift
//  EventAggregator
//
//  Created by Egor Bryzgalov on 18.07.17.
//  Copyright © 2017 Egor Bryzgalov. All rights reserved.
//

import Foundation
import RealmSwift

class LoadDB {
    
    func CityName() -> [String]{
        var arrCityName: [String] = []
        let realm = try! Realm()
        let valueCityName = realm.objects(CityEvent.self)
        for value in valueCityName {
            arrCityName.append(value.name)
        }
        
        return arrCityName
        
    }
    //загружаем эвенты
    func Event(name: String) -> Results<CityEvent> {
        let realm = try! Realm()
        let details = realm.objects(CityEvent.self).filter("name BEGINSWITH %@", name)
        return details
    }
    
//    func eventDescription(id: String) {
//        let realm = try! Realm()
//        let oneDetails = realm.object(Event.self)
//        return oneDetails
//    }
}
