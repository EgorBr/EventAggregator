//
//  LoadViewController.swift
//  EventAggregator
//
//  Created by Egor Bryzgalov on 18.10.2017.
//  Copyright © 2017 Egor Bryzgalov. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class LoadViewController: UIViewController {

    let manageTimepad: ManageEventTimepad = ManageEventTimepad()
    let manageKudaGo: ManageEventKudaGO = ManageEventKudaGO()
    let managePonaminalu: ManagePonaminaluEvent = ManagePonaminaluEvent()
    let utils: Utils = Utils()
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        updateTopGroup.wait(timeout: DispatchTime.distantFuture)
//        var waitResAll = updateTopGroup.wait(timeout: DispatchTime.distantFuture)
//        print("waitResAll",waitResAll)
        // проверяем выполняется ли задача сейчас.
//        var waitResNow =  updateTopGroup.wait(timeout: DispatchTime.now())
//        print("waitResNow", waitResNow)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadKeyCity), name: NSNotification.Name(rawValue: "reloadKeyCity"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(checkAggregator), name: NSNotification.Name(rawValue: "checkAggregator"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(segue), name: NSNotification.Name(rawValue: "segue"), object: nil)
        
        //Очистака от старых эвентов и формарование массива актуальных мероприятий
        if uds.value(forKey: "city") != nil {
            userQueue.async {self.utils.removeEvent()} // чистит старое
        }
        /*-------------**************ПЕРВАЯ ЗАГРУЗКА**************-------------*/
        //При первой загрузке задаётся город
        if uds.value(forKey: "city") == nil {
            uds.set("Москва", forKey: "city")
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadKeyCity"), object: nil)
        }
        //создаём отметку первого запуска чтобы вести отчёт когда почистить события
        if uds.value(forKey: "lastLoad") == nil {
            uds.set(true, forKey: "switchKudaGO")
            uds.set(true, forKey: "switchPonaminalu")
            uds.set(0, forKey: "lastLoad")
        }
        /*-------------**************ПЕРВАЯ ЗАГРУЗКА**************-------------*/

        
        // Do any additional setup after loading the view.
        updateTop()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print("any")
        // Dispose of any resources that can be recreated.
    }
    
    func checkAggregator() {
        //проверяем какие агрегаторы включены и делаем по ним загрузку
        if Int(NSDate().timeIntervalSince1970) - (uds.value(forKey: "lastLoad") as! Int) > 28800 {
            if uds.bool(forKey: "switchKudaGO") == true {
                manageKudaGo.loadEventKudaGO()
            }
            if uds.bool(forKey: "switchPonaminalu") == true {
                managePonaminalu.loadEventPonaminalu()
            }
            if uds.bool(forKey: "switchTimaPad") == true {
                print("TimePad is ON")
            }
            uds.set(Int(NSDate().timeIntervalSince1970), forKey: "lastLoad")
        }
    }
    
    func reloadKeyCity() {
        refEvent.child(uds.value(forKey: "city") as! String).observeSingleEvent(of: .value, with: { (snapshot) in
            if let tmpName = snapshot.value as? NSDictionary {
                if uds.value(forKey: "city") as! String == tmpName["Name"] as? String ?? "" {
                    if tmpName["Slug"] as? String ?? "" != "" {
                        uds.set(tmpName["Slug"] as? String ?? "", forKey: "citySlug")
                    } else {
                        uds.set("", forKey: "citySlug")
                    }
                    if tmpName["Region_id"] as? String ?? "" != "" {
                        uds.set(tmpName["Region_id"] as? String ?? "", forKey: "regionId")
                    } else {
                        uds.set("", forKey: "regionId")
                    }                    
                }
            }
        })
    }
    
    func updateTop() {
        ref.child("Update").observeSingleEvent(of: .value, with: {(snapshot) in
            if let update = snapshot.children.allObjects as? [DataSnapshot] {
                for item in update {
                    if String(describing: item.value!) == "1" {
                        refTop.observeSingleEvent(of: .value, with: { (snapshot) in
                            if let topItem = snapshot.children.allObjects as? [DataSnapshot] {
                                for (index, item) in topItem.enumerated() {
                                    self.utils.loadHotEvent(topId: String(describing: item.childSnapshot(forPath: "id").value!), itemNum: index + 1)
                                }
                                updateTopGroup.notify(queue: DispatchQueue.main, execute: {
                                    ref.child("Update/Top").setValue("false")
                                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "segue"), object: nil)
                                })
                            }
                        })
                    } else {
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "segue"), object: nil)
                    }
                }
            }
        })
    }
    
    func segue() {
        performSegue(withIdentifier: "startApp", sender: self)
    }
}
