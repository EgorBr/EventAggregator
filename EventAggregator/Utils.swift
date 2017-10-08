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
let ref = Database.database().reference()
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
        refEvent.child(uds.value(forKey: "cityKey") as! String).child("Events").observeSingleEvent(of: .value, with: { (snapshot) in
            if let keyValue = snapshot.value as? NSDictionary {
                var tmpidArr: [String] = []
                for getKey in keyValue.allKeys {
                    refEvent.child(uds.value(forKey: "cityKey") as! String).child("Events").child(getKey as! String).observeSingleEvent(of: .value, with: { (snapshot) in
                        if let tmpIdKey = snapshot.value as? NSDictionary {
                            let subtmpIdKey = tmpIdKey["title"] as? String ?? ""
                            tmpidArr.append(subtmpIdKey)
                            idArr = tmpidArr
                        }
                    })
                }
            }
        })
    }
    
    func getKeyCity (name: String) {
        refEvent.observeSingleEvent(of: .value, with: { (snapshot) in
            if let keyValue = snapshot.value as? NSDictionary {
                for getKey in keyValue.allKeys {
                    refEvent.child(getKey as! String).observeSingleEvent(of: .value, with: { (snapshot) in
                        if let tmpName = snapshot.value as? NSDictionary {
                            if name == tmpName["NAME"] as? String ?? "" {
                                uds.set(getKey as! String, forKey: "cityKey")
                                if tmpName["SLUG"] as? String ?? "" != "" {
                                    uds.set(tmpName["SLUG"] as? String ?? "", forKey: "citySlug")
                                } else {
                                    uds.set("", forKey: "citySlug")
                                }
                                if tmpName["REGION_ID"] as? String ?? "" != "" {
                                    uds.set(tmpName["REGION_ID"] as? String ?? "", forKey: "regionId")
                                } else {
                                    uds.set("", forKey: "regionId")
                                }
                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "checkAggregator"), object: nil)
                                self.getKeyEvents()
                                
                            }
                        }
                    })
                }
            }
        })
    }
    
    func removeEvent() {
        refEvent.child(uds.value(forKey: "cityKey") as! String).child("Events").observeSingleEvent(of: .value, with: { (snapshot) in
            if let keyValue = snapshot.value as? NSDictionary {
                for getKeyRemove in keyValue.allKeys {
                    refEvent.child(uds.value(forKey: "cityKey") as! String).child("Events").child(getKeyRemove as! String).observeSingleEvent(of: .value, with: { (snapshot) in
                        if let startTime = snapshot.value as? NSDictionary {
                            let tmpStartTime = startTime["start_event"] as? String ?? ""
                            if Int(NSDate().timeIntervalSince1970) - Decoder().timeConvertToSec(startTime: tmpStartTime) > 10000 {
                                print("REMOVE \(getKeyRemove as! String)")
                                refEvent.child(uds.value(forKey: "cityKey") as! String).child("Events").child(getKeyRemove as! String).removeValue()
                            }
                        }
                    })
                }
            }
        })
    }
}
