//
//  Utils.swift
//  EventAggregator
//
//  Created by Egor Bryzgalov on 26.08.17.
//  Copyright © 2017 Egor Bryzgalov. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import FirebaseDatabase

let userQueue = DispatchQueue(label: "ru.EventEggragator.userInitiated")
let backQueue = DispatchQueue(label: "ru.EventEggragator.background", qos: .background)
let concurrentQueue = DispatchQueue(label: "concurrent_queue", attributes: .concurrent)
let updateTopGroup = DispatchGroup()
let ref = Database.database().reference()
let refEvent = Database.database().reference().child("Event")
let refPlace = Database.database().reference().child("Place")
let refCategory = Database.database().reference().child("Category")
let refTop = Database.database().reference().child("Top")
let uds = UserDefaults.standard

let apiKeyPonaminalu: String = "eventapi98471241"
var statusLoad:Float = 0
var persentLoad: Float = 0
var countLoad: Int = 0
var nameLoadStage: String!

var idCellNews: [String] = []
var titleCellNews: [String] = []
var descriptionCellNews: [String] = []
var imgCellNews: [NSData] = []

var idArr: [String] = []

//var agregators: [String] = []

class Utils {
    
    let manageKudaGo: ManageEventKudaGO = ManageEventKudaGO()
    var container: UIView = UIView()
    var loadingView: UIView = UIView()
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()

    func removeEvent() {
        countLoad += 1
        refEvent.child("\(uds.value(forKey: "city") as! String)/Events/").observeSingleEvent(of: .value, with: { (snapshot) in
            if let ev = snapshot.value as? NSDictionary {
                persentLoad += statusLoad
                for remove in ev.allKeys {
                    refEvent.child("\(uds.value(forKey: "city") as! String)/Events/\(remove)").observeSingleEvent(of: .value, with: { (snapshot) in
                        if let checkValidate = snapshot.value as? NSDictionary {
                            let time = checkValidate["start_event"]! as! Double
                            if NSDate().timeIntervalSince1970 - time > 10000 {
                                print("REMOVE \(time) \(uds.value(forKey: "city") as! String)/Events/\(remove)")
                                refEvent.child("\(uds.value(forKey: "city") as! String)/Events/\(remove)").removeValue()
                            }
                        }
                    })
                }
            }
        })
    }
    
    func loadHotEvent(topId: String, itemNum: Int) {
        updateTopGroup.enter()
        Alamofire.request("https://api.cultserv.ru/v4/subevents/get/?session=\(apiKeyPonaminalu)&id=\(topId)&region_id=\(uds.value(forKey: "regionId") as! String)&promote=69399e321f034b29441a6a525c50a488", method: .get).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                refTop.child("\(itemNum)/img").setValue("http://media.cultserv.ru/i/300x200/\(json["message"]["image"].stringValue)")
//                refTop.child("\(itemNum)/seo").setValue(json["message"]["event"]["seo"]["alias"].stringValue)
                refTop.child("\(itemNum)/title").setValue(json["message"]["title"].stringValue)
                refTop.child("\(itemNum)/eventID").setValue(json["message"]["event"]["id"].stringValue)
                ManageData().saveEventToFB(agregator: "Ponaminalu",
                                           key: json["message"]["event"]["id"].stringValue,
                                           title: json["message"]["title"].stringValue,
                                           short_title: json["message"]["title"].stringValue,
                                           is_free: "false",
                                           description: json["message"]["description"].stringValue,
                                           body_text: "",
                                           start_event: json["message"]["date"].stringValue,
                                           stop_event: "",
                                           place: json["message"]["venue"]["title"].stringValue,
                                           categories: json["message"]["categories"][0]["title"].stringValue,
                                           min_price: json["message"]["min_price"].stringValue,
                                           max_price: json["message"]["max_price"].stringValue,
                                           seo: json["message"]["event"]["seo"]["alias"].stringValue,
                                           eticket_possible: json["message"]["eticket_possible"].stringValue,
                                           image: json["message"]["image"].stringValue,
                                           age_restriction: json["message"]["age"].stringValue)
                ManagePonaminaluEvent().descriptionEvent(id: topId, idEvent: json["message"]["event"]["id"].stringValue)
            case .failure(let error):
                print(error)
            }
            updateTopGroup.leave()
        }
    }
    
    func loadImage(url: String) -> NSData {
        let imgURL: NSURL = NSURL(string: url)!
        let imgData: NSData = NSData(contentsOf: imgURL as URL)!
        return imgData
    }
    
    func showActivityIndicator(uiView: UIView) {
        container.frame = uiView.frame
        container.center = uiView.center
        container.backgroundColor = UIColorFromHex(rgbValue: 0xffffff, alpha: 0.3)
        
        loadingView.frame = CGRect(x: 0.0, y: 0.0, width: 120.0, height: 120.0)
        loadingView.center = uiView.center
        loadingView.backgroundColor = UIColorFromHex(rgbValue: 0x444444, alpha: 0.7)
        loadingView.clipsToBounds = true
        loadingView.layer.cornerRadius = 10
        
        activityIndicator.frame = CGRect(x: 0.0, y: 0.0, width: 80.0, height: 80.0)
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
        activityIndicator.center = CGPoint(x: loadingView.frame.size.width / 2, y: loadingView.frame.size.height / 2);
        
        loadingView.addSubview(activityIndicator)
        container.addSubview(loadingView)
        uiView.addSubview(container)
        activityIndicator.startAnimating()
    }
    
    func hideActivityIndicator(uiView: UIView) {
        activityIndicator.stopAnimating()
        container.removeFromSuperview()
    }
    
    func UIColorFromHex(rgbValue:UInt32, alpha:Double=1.0)->UIColor {
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
        let blue = CGFloat(rgbValue & 0xFF)/256.0
        return UIColor(red:red, green:green, blue:blue, alpha:CGFloat(alpha))
    }
    
    func lastLoad () {
        refEvent.child("\(uds.value(forKey: "city") as! String)").observeSingleEvent(of: .value, with: { (snapshot) in
            if let lastLoad = snapshot.value as? NSDictionary {
                uds.set(lastLoad["lastLoad"]! as! Double, forKey: "lastLoad")
            }
        })
    }
}
