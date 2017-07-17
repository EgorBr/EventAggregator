//
//  TypeEvent.swift
//  EventAggregator
//
//  Created by Egor Bryzgalov on 12.07.17.
//  Copyright © 2017 Egor Bryzgalov. All rights reserved.
//

import Foundation
import RealmSwift

class TypeEvent: Object {
    dynamic var name: String = ""
    var eventList = List<Event>()
    
    override static func primaryKey() -> String? {
        return "name"
    }
}
