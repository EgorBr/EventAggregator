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
    var index = 0
    func loadEvent() {
        let realm = try! Realm()
        var arrayDatabaseCity: [String] = []
        let urlTimepadEvent = "https://api.timepad.ru/v1/events.json?token=d6a66b1c5d4bd2fc34126bb189de991f7fb07d1c"
        let urlEvent = "https://api.timepad.ru/v1/events/"
        //получаем города и записываем в базу в еденичном экземпляре
        // загружаем ИД евентов для конкретного города
        func loadEvent(city: [String], country: String) {
            for сityName in city {
                let decodeCityName = сityName.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
                let urlEventDetails = urlTimepadEvent+"&cities=\(decodeCityName!)"
                
                Alamofire.request(urlEventDetails, method: .get).validate().responseJSON { response in
                    switch response.result {
                    case .success(let value):
                        let json = JSON(value)
                        
                        let insCity = CityEvent()
                        insCity.name = сityName
                        insCity.country = country
                        
                        realm.beginWrite() //Открываем транзакцию для записи в базу
                        //Получаем ID  мероприятий для конкретного города и получаем детальное описание по ним
                        for (_, subJSON) in json["values"] {
                            let descriptionUrlEvent = urlEvent+subJSON["id"].stringValue
                            Alamofire.request(descriptionUrlEvent, method: .get).validate().responseJSON { response in
                                switch response.result {
                                case .success(let value):
                                    let json = JSON(value)
                                    
                                    let insEvent = Event()
                                    insEvent.timepad_id = json["id"].intValue
                                    insEvent.name = DecodeHTML().decodehtmltotxt(htmltxt: json["name"].stringValue)
                                    insEvent.creat_org = json["organization"]["name"].stringValue
                                    insEvent.start_time = json["starts_at"].stringValue
                                    insEvent.end_time = json["ends_at"].stringValue
                                    insEvent.event_description = DecodeHTML().decodehtmltotxt(htmltxt: json["description_short"].stringValue)
                                    insEvent.img = json["poster_image"]["default_url"].stringValue
                                    insEvent.full_event_description = DecodeHTML().decodehtmltotxt(htmltxt: json["description_html"].stringValue)
                                    insEvent.address = DecodeHTML().decodehtmltotxt(htmltxt: json["location"]["address"].stringValue)
                                    insCity.eventList.append(insEvent)
//                                    try! realm.write {
//                                        insCity.eventList.append(insEvent)
//                                        realm.add(insCity, update: true)
//                                    }
                                    
                                case .failure(let error):
                                    print(error)
                                }
                            }
                        }
//                        try! realm.write {
//                            realm.add(insCity, update: true)
//                        }
                        try! realm.commitWrite()
                    case .failure(let error):
                        print(error)
                    }
                }
            }
        }
        // получаем Список городов
        Alamofire.request(urlTimepadEvent+"&limit=30", method: .get).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                for (_, subJSON) in json["values"] {
                    let eventID = subJSON["id"].intValue
                    let valEventID = urlEvent+String(eventID)
                    Alamofire.request(valEventID, method: .get).validate().responseJSON { response in
                        switch response.result {
                        case .success(let value):
                            let json = JSON(value)
                            let insCity = CityEvent()
                            let insTypeEvent = TypeEvent()
                            insCity.name = json["location"]["city"].stringValue
                            insCity.country = json["location"]["country"].stringValue
                            insTypeEvent.name = json["categories"][0]["name"].stringValue
                            if arrayDatabaseCity.contains(insCity.name) {}
                            else {
                                arrayDatabaseCity.append(insCity.name)
//                                print("ADD", insCity.name)
                            }
                            
                            try! realm.write {
                                realm.add(insTypeEvent, update: true)
                                realm.add(insCity, update: true)
                            }
                            
                        case .failure(let error):
                            print(error)
                        }
                    }
                }
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+3, execute: {
                    return (loadEvent(city: arrayDatabaseCity, country: "Россия"))
                    })
            case .failure(let error):
                print(error)
            }
        }
    }
}
