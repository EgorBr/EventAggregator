//
//  LoadDB.swift
//  EventAggregator
//
//  Created by Egor Bryzgalov on 18.07.17.
//  Copyright © 2017 Egor Bryzgalov. All rights reserved.
//

import Foundation
import RealmSwift
import FirebaseDatabase

class LoadDB {
    
    func CityName() -> [String]{
        var favoriteId: [String] = []
        let realm = try! Realm()
        let valueCityName = realm.objects(FavoriteEvent.self)
        for value in valueCityName {
            favoriteId.append(value.id)
        }
        
        return favoriteId
        
    }
    //загружаем эвенты
    func Event(name: String) -> Results<CityEvent> {
        let realm = try! Realm()
        let details = realm.objects(CityEvent.self).filter("name BEGINSWITH %@", name)
        return details
    }
    
    func eventDescription(id: String) -> Results<EventTimepad> {
        let realm = try! Realm()
        let oneEvent = realm.objects(EventTimepad.self).filter("timepad_id BEGINSWITH %@", id)
        return oneEvent
    }
}
