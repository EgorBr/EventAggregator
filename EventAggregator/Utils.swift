//
//  Utils.swift
//  EventAggregator
//
//  Created by Egor Bryzgalov on 26.08.17.
//  Copyright © 2017 Egor Bryzgalov. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import FirebaseDatabase

let userQueue = DispatchQueue(label: "ru.EventEggragator.userInitiated")
let backQueue = DispatchQueue(label: "ru.EventEggragator.background", qos: .background)
let concurrentQueue = DispatchQueue(label: "concurrent_queue", attributes: .concurrent)
let updateTopGroup = DispatchGroup()
let semafore = DispatchSemaphore(value: 0)
let ref = Database.database().reference()
let refEvent = Database.database().reference().child("Event")
let refPlace = Database.database().reference().child("Place")
let refCategory = Database.database().reference().child("Category")
let refTop = Database.database().reference().child("Top")
let uds = UserDefaults.standard

let apiKeyPonaminalu: String = "eventapi98471241"

var idArr: [String] = []

class Utils {
    
    let manageKudaGo: ManageEventKudaGO = ManageEventKudaGO()

    func removeEvent() {
        refEvent.child("\(uds.value(forKey: "city") as! String)/Events").observeSingleEvent(of: .value, with: { (snapshot) in
            if let keyValue = snapshot.value as? NSDictionary {
                for nameAggr in keyValue.allKeys {
                    refEvent.child("\(uds.value(forKey: "city") as! String)/Events/\(nameAggr)").observeSingleEvent(of: .value, with: { (snapshot) in
                        if let ev = snapshot.value as? NSDictionary {
                            for remove in ev.allKeys {
                                refEvent.child("\(uds.value(forKey: "city") as! String)/Events/\(nameAggr)/\(remove)").observeSingleEvent(of: .value, with: { (snapshot) in
                                    if let checkValidate = snapshot.value as? NSDictionary {
                                        if Int(NSDate().timeIntervalSince1970) - Decoder().timeConvertToSec(startTime: checkValidate["start_event"] as? String ?? "") > 10000 {
                                            print("REMOVE \(checkValidate["start_event"] as? String ?? "") \(uds.value(forKey: "city") as! String)/Events/\(nameAggr)/\(remove)")
                                            refEvent.child("\(uds.value(forKey: "city") as! String)/Events/\(nameAggr)/\(remove)").removeValue()
                                        }
                                    }
                                })
                            }
                        }
                    })
                }
            }
        })
    }
    
    func loadHotEvent(topId: String, itemNum: Int) {
        updateTopGroup.enter()
        Alamofire.request("https://api.cultserv.ru/v4/subevents/get/?session=\(apiKeyPonaminalu)&id=\(topId)&region_id=\(uds.value(forKey: "regionId") as! String)&promote=69399e321f034b29441a6a525c50a488", method: .get).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                refTop.child("\(itemNum)/img").setValue("http://media.cultserv.ru/i/300x200/\(json["message"]["image"].stringValue)")
                refTop.child("\(itemNum)/seo").setValue(json["message"]["event"]["seo"]["alias"].stringValue)
                refTop.child("\(itemNum)/title").setValue(json["message"]["title"].stringValue)
            case .failure(let error):
                print(error)
            }
            updateTopGroup.leave()
        }
    }
    
    func loadImage(url: String) -> NSData {
        //        backQueue.async {
        let imgURL: NSURL = NSURL(string: url)!
        let imgData: NSData = NSData(contentsOf: imgURL as URL)!
        //        }
        return imgData
    }
}
