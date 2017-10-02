//
//  ViewController.swift
//  EventAggregator
//
//  Created by Egor Bryzgalov on 24.08.17.
//  Copyright © 2017 Egor Bryzgalov. All rights reserved.
//

import UIKit
import RealmSwift
import SWRevealViewController


class RootTableViewController: UITableViewController//, UICollectionViewDelegate, UICollectionViewDataSource 
{
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    let manageTimepad: ManageEventTimepad = ManageEventTimepad()
    let manageKudaGo: ManageEventKudaGO = ManageEventKudaGO()
    let managePonaminalu: ManagePonaminaluEvent = ManagePonaminaluEvent()
    let utils: Utils = Utils()
    
    var topKGImage: [String] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(reloadKeyCity), name: NSNotification.Name(rawValue: "reloadKeyCity"), object: nil)
        //Очистака от старых эвентов и формарование массива актуальных мероприятий
        if uds.value(forKey: "city") != nil {
            startUtils()
        }
        //При первой загрузке задаётся город
        if uds.value(forKey: "city") == nil {
            uds.set("Москва", forKey: "city")
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadKeyCity"), object: nil)
        }
//        manageKudaGo.eventsOfTheDays()
        
        
//        ref.child("Top/KudaGo/\(uds.value(forKey: "cityKey") as! String)").observeSingleEvent(of: .value, with: { (snapshot) in
//            for item in 0 ... snapshot.childrenCount {
//                ref.child("Top/KudaGo/\(uds.value(forKey: "cityKey") as! String)/\(item)").observeSingleEvent(of: .value, with: { (snapshot) in
//                    if let value = snapshot.value as? NSDictionary {
//                        print(value["image"] as? String ?? "")
//                        self.topKGImage.append(value["image"] as? String ?? "")
//                    }
//                })
//            }
//            
//        })

        sideMenu()
        customizeNavBar()

        print(Realm.Configuration.defaultConfiguration.fileURL!)
        //создаём отмтку первого запуска чтобы вести отчёт когда почистить события
        if uds.value(forKey: "lastLoad") == nil {
            uds.set(Int(NSDate().timeIntervalSince1970), forKey: "lastLoad")
        }
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    func startUtils() {
        concurrentQueue.async(qos: .userInitiated) {
            self.utils.removeEvent() // чистит старое
            self.utils.getKeyEvents() // делаем список актуальных
        }
    }
    
    func reloadKeyCity() {
        utils.getKeyCity(name: uds.value(forKey: "city") as! String) // получаем ключ города чтобы работать с ним
    }
    
    func sideMenu() {
        if revealViewController() != nil {
            menuButton.target = revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            revealViewController().rearViewRevealWidth = 250
            view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
    }
    //Разрисовываем navigationBar
    func customizeNavBar() {
        //Цвет кнопки меню
        navigationController?.navigationBar.tintColor = UIColor(colorLiteralRed: 255/255, green: 255/255, blue: 255/255, alpha: 1)
        //Цвет navigationBar
        navigationController?.navigationBar.barTintColor = UIColor(colorLiteralRed: 42/255, green: 26/255, blue: 25/255, alpha: 1)
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
     }
    

}

//class PonaminaluUICollectionViewCell: UICollectionViewCell, UICollectionViewDelegate, UICollectionViewDataSource {
//    
//    
//    func numberOfSections(in collectionView: UICollectionView) -> Int {
//        return 1
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return 2
//        
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cellPonaminalu = collectionView.dequeueReusableCell(withReuseIdentifier: "cellPonaminalu", for: indexPath) as! PonaminaluUICollectionViewCell
//        
//        
//        return cellPonaminalu
//    }
//}
//
//class KudaGoUICollectionViewCell: UICollectionViewCell, UICollectionViewDelegate, UICollectionViewDataSource {
//
//    func numberOfSections(in collectionView: UICollectionView) -> Int {
//        return 1
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return 4
//        
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cellKudaGo = collectionView.dequeueReusableCell(withReuseIdentifier: "cellKudaGo", for: indexPath) as! PonaminaluUICollectionViewCell
//        
//        
//        return cellKudaGo
//    }
//}
