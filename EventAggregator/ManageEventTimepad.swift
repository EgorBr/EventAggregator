//
//  ManageEventTimepad.swift
//  EventAggregator
//
//  Created by Egor Bryzgalov on 12.07.17.
//  Copyright © 2017 Egor Bryzgalov. All rights reserved.
//

import Alamofire
import SwiftyJSON
import RealmSwift

private let _manage = ManageEventTimepad()
class ManageEventTimepad {
    
//    class var manage: ManageEventTimepad {
//        return _manage
//    }
    
    let urlTimepadEvent = "https://api.timepad.ru/v1/events.json?token=d6a66b1c5d4bd2fc34126bb189de991f7fb07d1c"
    let urlEvent = "https://api.timepad.ru/v1/events/"
    
    let requestGroup = DispatchGroup()
    let concurrentQueue = DispatchQueue(label: "concurrent_queue", attributes: .concurrent)
    let serialQueue = DispatchQueue(label: "serial_queue")
    let semafore = DispatchSemaphore(value: 0)
    
    
    var results = [String: String]()
    
    func loadCity(){
        
        var idForCity: [String] = []
        
        
        //Первый запрос для полчения ID мероприятий чтобы получил города
        requestGroup.enter()
        Alamofire.request(urlTimepadEvent+"&limit=100", method: .get).validate().responseJSON(queue: concurrentQueue) { response in
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
//                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refresh"), object: nil)
                                self.semafore.signal()
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
    
    func loadDB(param: Int) -> [String] {
        var array: [String] = []
        let realm = try! Realm()
        if param == 1 {
            let data = realm.objects(CityEvent.self)
            for nameCity in data {
                loadDetailsEvent(city: nameCity.name, slug: nameCity.slug)
            }
        }
        if param == 2 {
            let data = realm.objects(EventTimepad.self)
            for id in data {
                array.append(id.timepad_id)
            }
        }
        return array
    }
    
    func loadDetailsEvent(city: String, slug: String) {
        let decodName = city.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        Alamofire.request(urlTimepadEvent+"&cities=\(decodName!)&sort=+starts_at&limit=10", method: .get).validate().responseJSON(queue: serialQueue) { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                let cityName = CityEvent()
                cityName.name = city
                cityName.slug = slug
                for (_, subJSON) in json["values"] {
                    //                        print("INDEX:\(index)")
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
                            
                            
                            if (cityName.eventList.count) == 10 {
//                                print("REALM 1: \(Thread.current) \(index)")
                                autoreleasepool { () -> () in
                                    let realm = try! Realm()
                                    try! realm.write {
//                                        print("INSERT: \(Thread.current)")
                                        realm.add(cityName, update: true)
                                    }
                                }
                            }
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
    
//    var load: AnyObject? {
//        get {
//            return UserDefaults.standard.object(forKey: "flag") as AnyObject?
//        }
//        set {
//            UserDefaults.standard.set(newValue, forKey: "flag")
//            UserDefaults.standard.synchronize()
//        }
//    }
}
