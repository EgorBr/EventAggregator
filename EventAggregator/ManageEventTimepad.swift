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
//    let barrierQueue = DispatchQueue(label: "concurrent_queue", flags: .barrier)
    
    var results = [String: String]()
    var arrayDatabaseCity: [String] = []
    var tmp: [String] = []
    
    func loadJSON(){
        
        var idForCity: [String] = []
        
        
        //Первый запрос для полчения ID мероприятий чтобы получил города
        requestGroup.enter()
        Alamofire.request(urlTimepadEvent+"&limit=15", method: .get).validate().responseJSON(queue: concurrentQueue) { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                for (_, subJSON) in json["values"] {
                    let id = subJSON["id"].stringValue
                    idForCity.append(id)
                }
                
            case .failure(let error):
                print(error)
            }
            
            // По полученным ID получаем название городов где будут проходить мероприятия
            if response.result.isSuccess {
                for (index, value) in idForCity.enumerated() {
                    Alamofire.request(self.urlEvent+value, method: .get).validate().responseJSON(queue: self.concurrentQueue) { response in
                        switch response.result {
                        case .success(let value):
                            let json = JSON(value)
                            let insCity = CityEvent()
                            let insTypeEvent = TypeEvent()
                            insCity.name = json["location"]["city"].stringValue
                            insTypeEvent.name = json["categories"][0]["name"].stringValue
                            let realm = try! Realm()
                            try! realm.write {
                                realm.add(insTypeEvent, update: true)
                                realm.add(insCity, update: true)
                            }
                            
//                            print(index)
                            if idForCity.count == index+1 {
//                                print("Notis")
                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refreshCity"), object: nil)
                            }
//                            
                        case .failure(let error):
                            print(error)
                        }
                    }
                }
            }
            
            self.requestGroup.leave()
        }
        return
    }
    
    func loadDBcity()  {
        let realm = try! Realm()
        let data = realm.objects(CityEvent.self)
        for nameCity in data {
            arrayDatabaseCity.append(nameCity.name)
        }
        loadDetailsEvent()
        tmp = []
        return
    }
    
    func loadDetailsEvent() {
        for valueName in arrayDatabaseCity {
            let decodName = valueName.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
            Alamofire.request(urlTimepadEvent+"&cities=\(decodName!)", method: .get).validate().responseJSON(queue: concurrentQueue) { response in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    let cityName = CityEvent()
                    cityName.name = valueName
                    for (index, subJSON) in json["values"] {
                        Alamofire.request(self.urlEvent+subJSON["id"].stringValue, method: .get).validate().responseJSON(queue: self.concurrentQueue) { response in
                            switch response.result {
                            case .success(let value):
                                let json = JSON(value)
                                let cityEvent = Event()
                                cityEvent.timepad_id = json["id"].stringValue
                                cityEvent.name = Decoder().decodehtmltotxt(htmltxt: json["name"].stringValue)
                                cityEvent.creat_org = json["organization"]["name"].stringValue
                                cityEvent.start_time = json["starts_at"].stringValue
                                cityEvent.end_time = json["ends_at"].stringValue
                                cityEvent.event_description = Decoder().decodehtmltotxt(htmltxt: json["description_short"].stringValue)
                                cityEvent.img = json["poster_image"]["default_url"].stringValue
                                cityEvent.full_event_description = Decoder().decodehtmltotxt(htmltxt: json["description_html"].stringValue)
                                cityEvent.address = Decoder().decodehtmltotxt(htmltxt: json["location"]["address"].stringValue)
                                
//                                print(index)
                                cityName.eventList.append(cityEvent)
//                                if index+1 == 10 {
//                                    print(cityName)
//                                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "writeDBEvent"), object: nil)
//                                }
                            case .failure(let error):
                                print(error)
                            }
                        }
                    }
                    
                case .failure(let error):
                    print(error)
                }
            }
        }
        
    }
}
