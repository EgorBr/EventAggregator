//
//  EventKudaGo.swift
//  EventAggregator
//
//  Created by Egor Bryzgalov on 17.08.17.
//  Copyright © 2017 Egor Bryzgalov. All rights reserved.
//

import Foundation
import RealmSwift

class EventKudaGO: Object {
    dynamic var kudago_id: String = ""
    dynamic var name: String = ""

    override static func primaryKey() -> String? {
        return "kudago_id"
    }
}
