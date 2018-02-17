//
//  Variables.swift
//  EventAggregator
//
//  Created by Egor Bryzgalov on 15.01.2018.
//  Copyright © 2018 Egor Bryzgalov. All rights reserved.
//

import Foundation

struct Variables {
    
    let decoder: Decoder = Decoder()
    
    var _nameEvent: String!
    var _eventDescription: String!
    var _startEventTime: String!
    var _id: String!
    var _isFree: String!
    var _target: String!
    var _image: NSData!
    
    init(dict: Dictionary<String,AnyObject>) {
        if let nameEvent = dict["short_title"] as? String {
            self._nameEvent = nameEvent
        }
        if let id = dict["id"] as? String {
            self._id = id
        }
        if let eventDescription = dict["description"] as? String {
            self._eventDescription = eventDescription
        }
        if let startEventTime = dict["start_event"] as? Int {
            let tempVar = self.decoder.timeConvert(sec: String(startEventTime))
            self._startEventTime = tempVar
        }
        if let isFree = dict["is_free"] as? String {
            if isFree == "true" {
                self._isFree = "Бесплатно"
            } else {
                self._isFree = "Платное"
            }
        }
        if let image = dict["image"] as? String {
            if image == "" {
//                self._image = NSData(contentsOf: #imageLiteral(resourceName: "no_photo"))
            } else {
                let tmpImg = Utils().loadImage(url: image)
//                    NSData(contentsOf: NSURL(string: image)! as URL)!
                self._image = tmpImg
            }
        }
        if let target = dict["target"] as? String {
            self._target = target
        }
    }
}
