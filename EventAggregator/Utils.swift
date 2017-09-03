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
let apiKeyPonaminalu: String = "eventapi98471241"
