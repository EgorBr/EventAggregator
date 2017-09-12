//
//  Utils.swift
//  EventAggregator
//
//  Created by Egor Bryzgalov on 26.08.17.
//  Copyright © 2017 Egor Bryzgalov. All rights reserved.
//

import Foundation
import FirebaseDatabase

let serialQueue = DispatchQueue(label: "serial_queue")
let concurrentQueue = DispatchQueue(label: "concurrent_queue", attributes: .concurrent)
let semafore = DispatchSemaphore(value: 0)
let refEvent = Database.database().reference().child("Event")
let refPlace = Database.database().reference().child("Place")
let refCategory = Database.database().reference().child("Category")
let uds = UserDefaults.standard

let apiKeyPonaminalu: String = "eventapi98471241"

var idArr: [String] = []
var removeKeyEvent: String = ""

class Utils {
    
    let manageKudaGo: ManageEventKudaGO = ManageEventKudaGO()

    func getKeyEvents() {
        refEvent.child(uds.value(forKey: "globalCityKey") as! String).child("Events").observeSingleEvent(of: .value, with: { (snapshot) in
            if let keyValue = snapshot.value as? NSDictionary {
                var tmpidArr: [String] = []
                for getKey in keyValue.allKeys {
                    refEvent.child(uds.value(forKey: "globalCityKey") as! String).child("Events").child(getKey as! String).observeSingleEvent(of: .value, with: { (snapshot) in
                        if let tmpIdKey = snapshot.value as? NSDictionary {
                            let subtmpIdKey = tmpIdKey["id"] as? String ?? ""
                            tmpidArr.append(subtmpIdKey)
                            idArr = tmpidArr
                        }
                    })
                }
            }
        })
    }
    
    func getKeyCity (name: String) {
        var cityKey = ""
        refEvent.observeSingleEvent(of: .value, with: { (snapshot) in
            if let keyValue = snapshot.value as? NSDictionary {
                for getKey in keyValue.allKeys {
                    refEvent.child(getKey as! String).observeSingleEvent(of: .value, with: { (snapshot) in
                        if let tmpName = snapshot.value as? NSDictionary {
                            let subtmpname = tmpName["NAME"] as? String ?? ""
                            if name == subtmpname {
                                cityKey = getKey as! String
                                print("reload",name)
                                print("reload",cityKey)
                                UserDefaults.standard.set(cityKey, forKey: "globalCityKey")
//                                self.manageKudaGo.loadEventKudaGO()
                                self.getKeyEvents()
                                
                            }
                        }
                    })
                }
            }
        })
    }
    
    func removeEvent() {
        refEvent.child(uds.value(forKey: "globalCityKey") as! String).child("Events").observeSingleEvent(of: .value, with: { (snapshot) in
            if let keyValue = snapshot.value as? NSDictionary {
                for getKeyRemove in keyValue.allKeys {
                    refEvent.child(uds.value(forKey: "globalCityKey") as! String).child("Events").child(getKeyRemove as! String).observeSingleEvent(of: .value, with: { (snapshot) in
                        if let startTime = snapshot.value as? NSDictionary {
                            let tmpStartTime = startTime["start_event"] as? String ?? ""
                            if Int(NSDate().timeIntervalSince1970) - Decoder().timeConvertToSec(startTime: tmpStartTime) > 10000 {
//                                refEvent.child(uds.value(forKey: "globalCityKey") as! String).child("Events").removeValue(getKeyRemove)
                            }
                        }
                    })
                }
            }
        })
    }
}
