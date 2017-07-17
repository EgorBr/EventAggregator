//
//  EventTickets.swift
//  EventAggregator
//
//  Created by Egor Bryzgalov on 12.07.17.
//  Copyright © 2017 Egor Bryzgalov. All rights reserved.
//

import Foundation
import RealmSwift

class EventTickets: Object {
    dynamic var price_min: Double = 0.0
    dynamic var price_max: Double = 0.0
    dynamic var total_tickets: Int = 0
    dynamic var free_tickets: Bool = false
    dynamic var sale_ends: Date? = nil
}
