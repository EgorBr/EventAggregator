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
    func loadDBCityName() -> [String]{
        let realm = try! Realm()
        var arrCityName: [String] = []
        let valueCityName = realm.objects(CityEvent.self)
        for value in valueCityName {
            arrCityName.append(value.name)
        }
        
        return arrCityName
        
    }
}
