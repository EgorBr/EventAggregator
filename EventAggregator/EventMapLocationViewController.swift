//
//  EventMapLocationViewController.swift
//  EventAggregator
//
//  Created by Egor Bryzgalov on 07.10.2017.
//  Copyright © 2017 Egor Bryzgalov. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import SWRevealViewController
import FirebaseDatabase
import Firebase

class EventMapLocationViewController: UIViewController, CLLocationManagerDelegate {
    
    let location = CLLocationManager()

    @IBOutlet weak var locationView: MKMapView!
    @IBOutlet weak var locMenuButton: UIBarButtonItem!
    @IBOutlet weak var temp: UIBarButtonItem!
    @IBAction func locationMeButton(_ sender: Any) {
        location.startUpdatingLocation() // запускает метод locationManager()
//      locationView.setCenter(locationView.userLocation.coordinate, animated: true) //Независимо от масштаба ставит тебя в центр экрана
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        temp.title = "-12 C"
        let view = UIView(frame: CGRect(x: 0.0, y: 0.0, width: UIScreen.main.bounds.size.width, height: 20.0))
        view.backgroundColor = UIColor(red: 42/255, green: 26/255, blue: 25/255, alpha: 0.65)
        self.navigationController?.view.addSubview(view)
        UIApplication.shared.keyWindow?.backgroundColor = UIColor.green
        UINavigationBar.appearance().clipsToBounds = true
        
        location.delegate = self
        location.desiredAccuracy = kCLLocationAccuracyBest
        location.requestWhenInUseAuthorization()
        location.startUpdatingLocation()
        
        if revealViewController() != nil {
            locMenuButton.target = revealViewController()
            locMenuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            revealViewController().rearViewRevealWidth = 250
            view.addGestureRecognizer(self.revealViewController().tapGestureRecognizer())
        }
        
        refPlace.observe(.value, with: {(snapshot) in
            for item in snapshot.children {
                if String(describing: (item as AnyObject).childSnapshot(forPath: "location").value!) != "<null>" {
                let namePlace = (item as AnyObject).childSnapshot(forPath: "title").value as! String
                    if uds.value(forKey: "citySlug") as! String == (item as AnyObject).childSnapshot(forPath: "location").value as! String || ((item as AnyObject).childSnapshot(forPath: "id").value as! String).characters.last! == "T"  {
                        refPlace.child("\((item as AnyObject).childSnapshot(forPath: "id").value as! String)/coords").observeSingleEvent(of: .value, with: {(snapshot) in
                            if let coords = snapshot.value as? NSDictionary {
                                //ставим булавку в указанном месте
                                let pin = CLLocationCoordinate2D(latitude: Double(coords["lat"] as? String ?? "")!, longitude: Double(coords["lon"] as? String ?? "")!)
                                let setPin = MapPin(title: namePlace, subtitle: "", coordinate: pin)
                                
                                self.locationView.addAnnotation(setPin)
                            }
                        })
                    }
                }
            }
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
//        UINavigationBar.appearance().barStyle = UIBarStyle.black
        //Цвет кнопок
        navigationController?.navigationBar.tintColor = UIColor.black
        navigationController?.navigationBar.barStyle = UIBarStyle.black
        //Цвет navigationBar
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let currentLoc = locations.last
//        let currentSpeed = locations.last?.speed
        let radius: CLLocationDistance = 3000
        let region = MKCoordinateRegionMakeWithDistance((currentLoc?.coordinate)!, radius, radius)
        locationView.setRegion(region, animated: true)
        self.locationView.showsUserLocation = true
        location.stopUpdatingLocation()

    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
