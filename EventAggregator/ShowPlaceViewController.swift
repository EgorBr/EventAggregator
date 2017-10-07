//
//  ShowPlaceViewController.swift
//  EventAggregator
//
//  Created by Egor Bryzgalov on 26.09.2017.
//  Copyright © 2017 Egor Bryzgalov. All rights reserved.
//

import UIKit
import MapKit

class ShowPlaceViewController: UIViewController {

    @IBOutlet weak var namePlaceLabel: UILabel!
    @IBOutlet weak var descriptionPlaceLabel: UILabel!
    @IBOutlet weak var phonePlaceLabel: UILabel!
    @IBOutlet weak var subwayPlaceLabel: UILabel!
    @IBOutlet weak var cityPlaceLabel: UILabel!
    @IBOutlet weak var addressPlaceLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    
    var placeId: String = ""    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //заполняем инфой о месте проведения
        refPlace.child(self.placeId).observeSingleEvent(of: .value, with: { (snapshot) in
            if let place = snapshot.value as? NSDictionary {
                self.namePlaceLabel.text = place["title"] as? String ?? ""
                self.descriptionPlaceLabel.text = place["description"] as? String ?? ""
                self.phonePlaceLabel.text = place["phone"] as? String ?? ""
                self.subwayPlaceLabel.text = place["subway"] as? String ?? ""
                self.addressPlaceLabel.text = place["address"] as? String ?? ""
                
//                print(place["coords"]!)
                if place["location"] as? String ?? "" == "" {
                    self.cityPlaceLabel.text = uds.value(forKey: "city") as! String
                } else {
                    refEvent.observeSingleEvent(of: .value, with: { (snapshot) in
                        if let keyValue = snapshot.value as? NSDictionary {
                            for key in keyValue.allKeys {
                                refEvent.child(key as! String).observeSingleEvent(of: .value, with: { (snapshot) in
                                    if let tmp = snapshot.value as? NSDictionary {
                                        if place["location"] as? String ?? "" == tmp["SLUG"] as? String ?? "" {
                                            self.cityPlaceLabel.text = tmp["NAME"] as? String ?? ""
                                        }
                                    }
                                })
                            }
                        }
                    })
                }
            }
        })
        refPlace.child("\(self.placeId)/coords").observeSingleEvent(of: .value, with: { (snaphot) in
            if let coords = snaphot.value as? NSDictionary {
                //Создаём точку на карте и задаём радиус отображения
                let location = CLLocation(latitude: Double(coords["lat"] as? String ?? "")!, longitude: Double(coords["lon"] as? String ?? "")!)
                let radius: CLLocationDistance = 500
                let point = MKCoordinateRegionMakeWithDistance(location.coordinate, radius, radius )
                self.mapView.setRegion(point, animated: true)
                //ставим булавку в указанном месте
                let pin = CLLocationCoordinate2D(latitude: Double(coords["lat"] as? String ?? "")!, longitude: Double(coords["lon"] as? String ?? "")!)
                let setPin = MapPin(title: "", subtitle: "", coordinate: pin)
                self.mapView.addAnnotation(setPin)
            }
        })
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
