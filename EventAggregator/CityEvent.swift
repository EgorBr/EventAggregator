//
//  CityEvent.swift
//  EventAggregator
//
//  Created by Egor Bryzgalov on 12.07.17.
//  Copyright © 2017 Egor Bryzgalov. All rights reserved.
//

import Foundation
import RealmSwift

class CityEvent: Object {
    dynamic var name: String = ""
    dynamic var slug: String = ""
    var eventList = List<EventTimepad>()
    var kudagoList = List<EventKudaGO>()
    
    override static func primaryKey() -> String? {
        return "name"
    }
}
