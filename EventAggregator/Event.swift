//
//  Event.swift
//  EventAggregator
//
//  Created by Egor Bryzgalov on 12.07.17.
//  Copyright © 2017 Egor Bryzgalov. All rights reserved.
//

import Foundation
import RealmSwift

class Event: Object {
    dynamic var timepad_id: String = ""
    dynamic var name: String = ""
    dynamic var creat_org: String = ""
    dynamic var start_time: String = ""
    dynamic var end_time: String = ""
    dynamic var event_description: String = ""
    dynamic var img: String = ""
    dynamic var full_event_description: String = ""
    dynamic var address: String = ""
    dynamic var latitude: Double = 0.0
    dynamic var longitude: Double = 0.0
    
    override static func primaryKey() -> String? {
        return "timepad_id"
    }
}
