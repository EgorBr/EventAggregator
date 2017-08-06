//
//  ManageEventTimepad.swift
//  EventAggregator
//
//  Created by Egor Bryzgalov on 12.07.17.
//  Copyright © 2017 Egor Bryzgalov. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import RealmSwift

class ManageEventTimepad {
    
    let urlTimepadEvent = "https://api.timepad.ru/v1/events.json?token=d6a66b1c5d4bd2fc34126bb189de991f7fb07d1c"
    let urlEvent = "https://api.timepad.ru/v1/events/"
    
    let requestGroup = DispatchGroup()
    let concurrentQueue = DispatchQueue(label: "concurrent_queue", attributes: .concurrent)
    var results = [String: String]()
    
    func loadJSON() -> [String]{
        
        var idforcity: [String] = []
        var arrayDatabaseCity: [String] = []
        
        //Первый запрос для полчения ID мероприятий чтобы получил города
        requestGroup.enter()
        Alamofire.request(urlTimepadEvent+"&limit=100", method: .get).validate().responseJSON(queue: concurrentQueue) { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                for (_, subJSON) in json["values"] {
                    let id = subJSON["id"].stringValue
                    idforcity.append(id)
                }
                
            case .failure(let error):
                print(error)
            }
            
            // По полученным ID получаем название городов где будут проходить мероприятия
            if response.result.isSuccess {
                for value in idforcity {
                    Alamofire.request(self.urlEvent+value, method: .get).validate().responseJSON(queue: self.concurrentQueue) { response in
                        switch response.result {
                        case .success(let value):
                            let json = JSON(value)
                            let insCity = CityEvent()
                            let insTypeEvent = TypeEvent()
                            insCity.name = json["location"]["city"].stringValue
                            insTypeEvent.name = json["categories"][0]["name"].stringValue
            print("1: \(Thread.current)")
                            if arrayDatabaseCity.contains(insCity.name) {}
                            else {
                                arrayDatabaseCity.append(insCity.name)
                            }
                            
                            let realm = try! Realm()
                            try! realm.write {
            print("2: \(Thread.current)")
                                realm.add(insTypeEvent, update: true)
                                realm.add(insCity, update: true)
                            }
                            
                        case .failure(let error):
                            print(error)
                        }
                        
                    }
                }
            }
            
            self.requestGroup.leave()
        }
        return arrayDatabaseCity
    }
}
