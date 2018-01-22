//
//  ViewController.swift
//  EventAggregator
//
//  Created by Egor Bryzgalov on 24.08.17.
//  Copyright © 2017 Egor Bryzgalov. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SWRevealViewController
import FirebaseDatabase
import Firebase


class RootViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var showTop: UICollectionView!
    @IBOutlet weak var showNews: UITableView!
    
    let manageTimepad: ManageEventTimepad = ManageEventTimepad()
    let manageKudaGo: ManageEventKudaGO = ManageEventKudaGO()
    let managePonaminalu: ManagePonaminaluEvent = ManagePonaminaluEvent()
    let utils: Utils = Utils()
    
    var idTopEvent: [String] = []
    var imgTopEvent: [String] = []
    var eventID: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.showNews.estimatedRowHeight = 15
        self.showNews.rowHeight = UITableViewAutomaticDimension

        showTopEvent()
        self.navigationItem.title = "Лучшее"

        // боковое меню
        if revealViewController() != nil {
            menuButton.target = revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            revealViewController().rearViewRevealWidth = 250
            view.addGestureRecognizer(self.revealViewController().tapGestureRecognizer())
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let view = UIView(frame: CGRect(x: 0.0, y: 0.0, width: UIScreen.main.bounds.size.width, height: 20.0))
        view.backgroundColor = UIColor(red: 70/255, green: 59/255, blue: 58/255, alpha: 1)
        self.navigationController?.view.addSubview(view)
        //Цвет кнопок
        navigationController?.navigationBar.tintColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
        //Цвет navigationBar
        navigationController?.navigationBar.barTintColor = UIColor(red: 42/255, green: 26/255, blue: 25/255, alpha: 1)
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
    }
    
    /*-------------------------*COLLECTION VIEW*-------------------------*/
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return idTopEvent.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let hotCell = collectionView.dequeueReusableCell(withReuseIdentifier: "hotCell", for: indexPath) as! HotCellCollectionViewControllerCell
        backQueue.async {
            let imgURL: NSURL = NSURL(string: self.imgTopEvent[indexPath.row])!
            let imgData: NSData = NSData(contentsOf: imgURL as URL)!
            let image: UIImageView = hotCell.topEvent
            DispatchQueue.main.async {
                image.image = UIImage(data: imgData as Data)
            }
            
        }
        return hotCell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let top: DetailsViewController = self.storyboard?.instantiateViewController(withIdentifier: "DetailsViewController") as! DetailsViewController
        top.targetName = "Ponaminalu"
        top.idEvent = eventID[indexPath.row]
        self.navigationController?.pushViewController(top, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        var rowIndex = indexPath.row
        let numberOfRecords = self.imgTopEvent.count - 1
        print(rowIndex, numberOfRecords)
        if rowIndex < numberOfRecords {
            rowIndex = rowIndex + 1
        } else {
            rowIndex = 0
        }
        
        Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(RootViewController.startTimer(timer:)), userInfo: rowIndex, repeats: true)
        
    }
    
    func startTimer(timer: Timer) {
        UIView.animate(withDuration: 1.0, delay: 0, options: .curveEaseOut, animations: {
            self.showTop.scrollToItem(at: IndexPath(row: timer.userInfo! as! Int, section: 0), at: .centeredHorizontally, animated: false)
            }, completion: nil)
    }
    
    /*-------------------------*COLLECTION VIEW*-------------------------*/
                        //-//-//-//-//-//-//-//-//-//-//
    /*----------------------------*TABLE VIEW*---------------------------*/
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return idCellNews.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let newsCell = tableView.dequeueReusableCell(withIdentifier: "newsCell", for: indexPath) as! NewsCellTableViewControllerCell
        newsCell.titleNews.text = titleCellNews[indexPath.row]
        newsCell.descriptionNews.text = descriptionCellNews[indexPath.row]
        newsCell.picNews.image = UIImage(data: imgCellNews[indexPath.row] as Data)
        
        return newsCell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "newsDetails" {
            if let indexPath = showNews.indexPathForSelectedRow {
                let destinationVC = segue.destination as! NewsDetailsViewController
                destinationVC.idNews = idCellNews[indexPath.row]
            }
        }
    }
    
    /*----------------------------*TABLE VIEW*---------------------------*/
    
    
    func showTopEvent() {
        refTop.observeSingleEvent(of: .value, with: { (snapshot) in
            if let topItem = snapshot.children.allObjects as? [DataSnapshot] {
                for item in topItem {
                    self.idTopEvent.append(String(describing: item.childSnapshot(forPath: "id").value!))
                    self.eventID.append(String(describing: item.childSnapshot(forPath: "eventID").value!))
                    self.imgTopEvent.append(String(describing: item.childSnapshot(forPath: "img").value!))
                    self.showTop.reloadData()
                }
                
            }
        })
    }
}

class NewsCellTableViewControllerCell: UITableViewCell {
    @IBOutlet weak var picNews: UIImageView!
    @IBOutlet weak var titleNews: UILabel!
    @IBOutlet weak var descriptionNews: UILabel!
}

class HotCellCollectionViewControllerCell: UICollectionViewCell {
    @IBOutlet weak var topEvent: UIImageView!    
}
