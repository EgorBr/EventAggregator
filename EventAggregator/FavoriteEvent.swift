//
//  FavoriteEvent.swift
//  EventAggregator
//
//  Created by Egor Bryzgalov on 26.08.17.
//  Copyright © 2017 Egor Bryzgalov. All rights reserved.
//

import Foundation
import RealmSwift

class FavoriteEvent: Object {
    dynamic var region: String = ""
    dynamic var id: String = ""
    
    override static func primaryKey() -> String? {
        return "id"
    }
}
