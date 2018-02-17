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
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var stausLable: UILabel!
    @IBOutlet weak var loadStage: UILabel!
    
    let manageTimepad: ManageEventTimepad = ManageEventTimepad()
    let manageKudaGo: ManageEventKudaGO = ManageEventKudaGO()
    let managePonaminalu: ManagePonaminaluEvent = ManagePonaminaluEvent()
    let manageData: ManageData = ManageData()
    let utils: Utils = Utils()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //прогресс загрузки
        Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(loadApplication), userInfo: nil, repeats: true)
        progressView.setProgress(0, animated: true)
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadKeyCity), name: NSNotification.Name(rawValue: "reloadKeyCity"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(checkAggregator), name: NSNotification.Name(rawValue: "checkAggregator"), object: nil)
        
        //Очистака от старых эвентов и формарование массива актуальных мероприятий
        if uds.value(forKey: "city") != nil {
            nameLoadStage = "Удаление прошедших мероприятий"
            userQueue.async {self.utils.removeEvent()} // чистит старое
        }
        /*-------------**************ПЕРВАЯ ЗАГРУЗКА**************-------------*/
        //При первой загрузке задаётся город
        if uds.value(forKey: "city") == nil {
            uds.set(true, forKey: "switchKudaGO")
            uds.set(true, forKey: "switchPonaminalu")
            uds.set(true, forKey: "switchTimaPad")
            uds.set("Москва", forKey: "city")
            utils.lastLoad()
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadKeyCity"), object: nil)
        } else {
            utils.lastLoad()
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "checkAggregator"), object: nil)
        }
        /*-------------**************ПЕРВАЯ ЗАГРУЗКА**************-------------*/

        updateTop()
    }
    
    func loadApplication() {
        if progressView.progress != 1 {
            if statusLoad == 0 {
                statusLoad = (1 - statusLoad) / Float(countLoad)
            }
            self.loadStage.text = nameLoadStage
            self.progressView.progress = persentLoad
        }
        else {
            performSegue(withIdentifier: "startApp", sender: self)
        }
    }
    
    func checkAggregator() {
        manageData.loadNews()
        //проверяем какие агрегаторы включены и делаем по ним загрузку
        if Int(NSDate().timeIntervalSince1970) - (uds.value(forKey: "lastLoad") as! Int) > 28800 {
            if uds.bool(forKey: "switchKudaGO") == true {
                manageKudaGo.loadEventKudaGO()
            }
            if uds.bool(forKey: "switchPonaminalu") == true {
                managePonaminalu.loadEventPonaminalu()
            }
            if uds.bool(forKey: "switchTimaPad") == true {
                ManageEventTimepad().loadTimePadEvent()
            }
            refEvent.child("\(uds.value(forKey: "city") as! String)/lastLoad").setValue(Int(NSDate().timeIntervalSince1970))
        }
    }
    
    func reloadKeyCity() {
        countLoad += 1
        refEvent.child(uds.value(forKey: "city") as! String).observeSingleEvent(of: .value, with: { (snapshot) in
            if let tmpName = snapshot.value as? NSDictionary {
                if uds.value(forKey: "city") as! String == tmpName["Name"] as? String ?? "" {
                    if tmpName["Slug"] as? String ?? "" != "" {
                        uds.set(tmpName["Slug"] as? String ?? "", forKey: "citySlug")
                        uds.set(true, forKey: "switchKudaGO")
                    } else {
                        uds.set("", forKey: "citySlug")
                        uds.set(false, forKey: "switchKudaGO")
                    }
                    if tmpName["Region_id"] as? String ?? "" != "" {
                        uds.set(tmpName["Region_id"] as? String ?? "", forKey: "regionId")
                        uds.set(true, forKey: "switchPonaminalu")
                    } else {
                        uds.set("", forKey: "regionId")
                        uds.set(false, forKey: "switchPonaminalu")
                    }
                    if uds.value(forKey: "regionId") as! String != "" || uds.value(forKey: "citySlug") as! String != "" {
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "checkAggregator"), object: nil)
                    }
                }
                persentLoad += statusLoad
            }
        })
    }
    
    func updateTop() {
        nameLoadStage = "Обновляем рекомендации для Вас"
        countLoad += 1
        DispatchQueue.main.async { [unowned self] in
            ref.child("Update").observeSingleEvent(of: .value, with: {(snapshot) in
                if let update = snapshot.children.allObjects as? [DataSnapshot] {
                    for (index, item) in update.enumerated() {
                        if String(describing: item.value!) == "true" {
                            refTop.observeSingleEvent(of: .value, with: { (snapshot) in
                                if let topItem = snapshot.children.allObjects as? [DataSnapshot] {
                                    for (index, item) in topItem.enumerated() {
                                        self.utils.loadHotEvent(topId: String(describing: item.childSnapshot(forPath: "id").value!), itemNum: index + 1)
                                    }
                                    updateTopGroup.notify(queue: DispatchQueue.main, execute: {
                                        ref.child("Update/Top").setValue("false")
                                        
                                    })
                                }
                            })
                        }
                        if index + 1 == update.count {
                            persentLoad += statusLoad
                        }
                    }
                }
            })
        }
    }
}
