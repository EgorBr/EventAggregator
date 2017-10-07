//
//  MapPin.swift
//  EventAggregator
//
//  Created by Egor Bryzgalov on 07.10.2017.
//  Copyright © 2017 Egor Bryzgalov. All rights reserved.
//

import MapKit

class MapPin: NSObject,MKAnnotation {
    var title: String?
    var subtitle: String?
    var coordinate: CLLocationCoordinate2D
    
    init(title:String, subtitle:String, coordinate:CLLocationCoordinate2D) {
        self.title = title
        self.subtitle = title
        self.coordinate = coordinate
    }
}
