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
    @IBOutlet weak var underground: UILabel!
    
    var placeId: String = ""
    var aggregator: String!
    
    var lat: String!
    var lon: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("placeId", placeId)
        print("aggregator", aggregator)
        UIApplication.shared.isNetworkActivityIndicatorVisible = true //Запускает индикатор загрузки
        //заполняем инфой о месте проведения
        refPlace.child(self.placeId).observeSingleEvent(of: .value, with: { (snapshot) in
            if let place = snapshot.value as? NSDictionary {
                self.namePlaceLabel.text = place["title"] as? String ?? ""
                self.descriptionPlaceLabel.text = place["description"] as? String ?? ""
                self.phonePlaceLabel.text = place["phone"] as? String ?? ""
                self.subwayPlaceLabel.text = place["subway"] as? String ?? ""
                self.addressPlaceLabel.text = place["address"] as? String ?? ""
                
                if place["location"] as? String ?? "" == "" {
                    self.cityPlaceLabel.text = uds.value(forKey: "city") as! String
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                } else {
                    refEvent.observeSingleEvent(of: .value, with: { (snapshot) in
                        if let keyValue = snapshot.value as? NSDictionary {
                            for key in keyValue.allKeys {
                                refEvent.child(key as! String).observeSingleEvent(of: .value, with: { (snapshot) in
                                    if let tmp = snapshot.value as? NSDictionary {
                                        if place["location"] as? String ?? "" == tmp["SLUG"] as? String ?? "" {
                                            self.cityPlaceLabel.text = tmp["NAME"] as? String ?? ""
                                            UIApplication.shared.isNetworkActivityIndicatorVisible = false //останавливает индикатор загрузки
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
                if self.placeId.characters.last! == "P" {
                    self.underground.isHidden = true
                    self.lat = (coords["lat"] as? String ?? "").components(separatedBy: ",")[0].components(separatedBy: " ")[0]
                    self.lon = (coords["lat"] as? String ?? "").components(separatedBy: ",")[1].components(separatedBy: " ")[1]
                } else {
                    self.lat = coords["lat"] as? String ?? ""
                    self.lon = coords["lon"] as? String ?? ""
                }
                let location = CLLocation(latitude: Double(self.lat)!, longitude: Double(self.lon)!)
                let radius: CLLocationDistance = 500
                let point = MKCoordinateRegionMakeWithDistance(location.coordinate, radius, radius )
                self.mapView.setRegion(point, animated: true)
                //ставим булавку в указанном месте
                let pin = CLLocationCoordinate2D(latitude: Double(self.lat)!, longitude: Double(self.lon)!)
                let setPin = MapPin(title: "", subtitle: "", coordinate: pin)
                self.mapView.addAnnotation(setPin)
            }
        })
        
    }
}
