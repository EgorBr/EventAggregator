//
//  ManageEventTimepad.swift
//  EventAggregator
//?token=d6a66b1c5d4bd2fc34126bb189de991f7fb07d1c
//  Created by Egor Bryzgalov on 12.07.17.
//  Copyright © 2017 Egor Bryzgalov. All rights reserved.
//

import Alamofire
import SwiftyJSON
import RealmSwift
import FirebaseDatabase

private let _manage = ManageEventTimepad()

class ManageEventTimepad {
    
    let urlTimepadEvent = "https://api.timepad.ru/v1/events.json"
    let urlEvent = "https://api.timepad.ru/v1/events/"
    
    let requestGroup = DispatchGroup()
    let serialQueue = DispatchQueue(label: "serial_queue")
    
    
    
    var results = [String: String]()
    
    func loadCity(){
        
        var idForCity: [String] = []
        //Первый запрос для полчения ID мероприятий чтобы получил города
        requestGroup.enter()
        Alamofire.request(urlTimepadEvent+"?limit=100", method: .get).validate().responseJSON(queue: concurrentQueue) { response in
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
                    Alamofire.request(self.urlEvent+value, method: .get).validate().responseJSON(queue: concurrentQueue) { response in
                        switch response.result {
                        case .success(let value):
                            let json = JSON(value)
                            let insCity = CityEvent()
                            let insTypeEvent = TypeEvent()
                            insCity.name = json["location"]["city"].stringValue
                            insTypeEvent.name = json["categories"][0]["name"].stringValue
                            if insCity.name != "Без города" {
                                let realm = try! Realm()
                                try! realm.write {
                                    realm.add(insTypeEvent, update: true)
                                    realm.add(insCity, update: true)
                                }
                            }
                            
                            if idForCity.count == index+1 {
//                                print("Notis")
//                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refresh"), object: nil)
                                semafore.signal()
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
    
    func loadDB(param: Int) /*-> [String]*/ {
//        var array: [String] = []
        let realm = try! Realm()
        if param == 1 {
            let data = realm.objects(CityEvent.self)
            for (index, nameCity) in data.enumerated() {
                loadDetailsEvent(city: nameCity.name, slug: nameCity.slug, num: 10)
                print(nameCity.slug)
                semafore.wait(timeout: .distantFuture)
                
                if data.count == index+1 {
                    load = true as AnyObject
                }
            }
        }
//        if param == 2 {
//            let data = realm.objects(EventTimepad.self)
//            for id in data {
//                array.append(id.timepad_id)
//            }
//        }
//        return array
    }
    
    func loadDetailsEvent(city: String, slug: String, num: Int) {
        var total = num
        let decodName = city.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        Alamofire.request(urlTimepadEvent+"?limit=\(num)&cities=\(decodName!)&sort=+starts_at&access_statuses=public", method: .get).validate().responseJSON(queue: serialQueue) { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                let totalJSON = json["total"].intValue
//                print(totalJSON)
                if total > totalJSON {
                    total = totalJSON
                }
                
                let cityName = CityEvent()
                cityName.name = city
                cityName.slug = slug
                
                for (_, subJSON) in json["values"] {
                    Alamofire.request(self.urlEvent+subJSON["id"].stringValue, method: .get).validate().responseJSON(queue: self.serialQueue) { response in
                        switch response.result {
                        case .success(let value):
                            let json = JSON(value)
                            let cityEvent = EventTimepad()
                            cityEvent.timepad_id = json["id"].stringValue
                            cityEvent.name = Decoder().decodehtmltotxt(htmltxt: json["name"].stringValue)
                            cityEvent.creat_org = json["organization"]["name"].stringValue
                            cityEvent.start_time = json["starts_at"].stringValue
                            cityEvent.end_time = json["ends_at"].stringValue
                            cityEvent.event_description = Decoder().decodehtmltotxt(htmltxt: json["description_short"].stringValue)
                            cityEvent.img = json["poster_image"]["default_url"].stringValue
                            cityEvent.full_event_description = Decoder().decodehtmltotxt(htmltxt: json["description_html"].stringValue)
                            cityEvent.address = Decoder().decodehtmltotxt(htmltxt: json["location"]["address"].stringValue)
                            cityName.eventList.append(cityEvent)
                            if (cityName.eventList.count) == total {
                                autoreleasepool { () -> () in
                                    let realm = try! Realm()
                                    
                                    try! realm.write {
                                        realm.add(cityName, update: true)
                                    }
                                    semafore.signal()
                                }
                            }
                        case .failure(let error):
                            print("ERROR!!!!!\(subJSON["id"])",error)
                        }
                    }
                }
                
                
            case .failure(let error):
                print(error)
            }
        }
    }
}


var load: AnyObject? {
    get {
        return UserDefaults.standard.object(forKey: "flag") as AnyObject?
    }
    set {
        UserDefaults.standard.set(newValue, forKey: "flag")
        UserDefaults.standard.synchronize()
    }
}
