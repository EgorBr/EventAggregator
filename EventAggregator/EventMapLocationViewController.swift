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

class EventMapLocationViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var locationView: MKMapView!    
    @IBOutlet weak var locMenuButton: UIBarButtonItem!
    @IBAction func locationMeButton(_ sender: Any) {
    }
    
    let location = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //Цвет кнопок
        navigationController?.navigationBar.tintColor = UIColor.black
        //Цвет navigationBar
//        navigationController?.navigationBar.barTintColor = UIColor.white
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
