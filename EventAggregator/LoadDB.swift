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
        let realm = try! Realm()
        var arrCityName: [String] = []
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
    
    func eventdescription() {
        
    }
    
//    let startTimeString = "2015-06-26T00:10:00+01:00"
//    
//    // First convert the original formatted date/time to a string:
//    let deFormatter = NSDateFormatter()
//    deFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
//    let startTime = deFormatter.dateFromString(startTimeString)
//    print(startTime!) // 2015-06-25 23:10:00 +0000
//    
//    // Note that `println` use the `description` method which defaults to UTC.
//    // Then convert the date/time to the desired formatted string:
//    let formatter = DateFormatter()
//    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
//    let timeString = formatter.stringFromDate(startTime!)
//    print(timeString) // 2015-06-25 19:10:00
}
