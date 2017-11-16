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
    
    var idCellNews: [String] = []
    var titleCellNews: [String] = []
    var descriptionCellNews: [String] = []
    var imgCellNews: [String] = []
    
    var idTopEvent: [String] = []
    var imgTopEvent: [String] = []
    var seoTopEvent: [String] = []
    var nameTopEvent: [String] = []    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.showNews.estimatedRowHeight = 15
        self.showNews.rowHeight = UITableViewAutomaticDimension
        loadNews()
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
//        hotCell.hotName.text = nameTopEvent[indexPath.row]
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
    /*-------------------------*COLLECTION VIEW*-------------------------*/
                        //-//-//-//-//-//-//-//-//-//-//
    /*----------------------------*TABLE VIEW*---------------------------*/
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return idCellNews.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let newsCell = tableView.dequeueReusableCell(withIdentifier: "newsCell", for: indexPath) as! NewsCellTableViewControllerCell
        newsCell.titleNews.text = self.titleCellNews[indexPath.row]
        newsCell.descriptionNews.text = self.descriptionCellNews[indexPath.row]
        backQueue.async {
            let imgURL: NSURL = NSURL(string: self.imgCellNews[indexPath.row])!
            let imgData: NSData = NSData(contentsOf: imgURL as URL)!
            let image: UIImageView = newsCell.picNews
            DispatchQueue.main.async {
                image.image = UIImage(data: imgData as Data)
            }
        }
        return newsCell
    }
    /*----------------------------*TABLE VIEW*---------------------------*/
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "newsDetails" {
            if let indexPath = showNews.indexPathForSelectedRow {
                let destinationVC = segue.destination as! NewsDetailsViewController
                destinationVC.idNews = idCellNews[indexPath.row]
            }
        }
//        if segue.identifier == "topDetails" {
//            if let indexPath = showTop.indexPathsForSelectedItems {
//                let destinationVC = segue.destination as! DetailsViewController
//                destinationVC.searchId = idTopEvent[indexPath.i]
//            }
//        }
    }
    
    func loadNews() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        Alamofire.request("https://kudago.com/public-api/v1.2/news/?fields=id,title,description,images&order_by=-publication_date&text_format=text&location=\(uds.value(forKey: "citySlug") as! String)", method: .get).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                for (_, value) in json["results"] {
                    self.idCellNews.append(value["id"].stringValue)
                    self.titleCellNews.append(value["title"].stringValue)
                    self.descriptionCellNews.append(value["description"].stringValue)
                    self.imgCellNews.append(value["images"][0]["image"].stringValue)
                    self.showNews.reloadData()
                }
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            case .failure(let error):
                print(error)
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }
    
    func showTopEvent() {
        refTop.observeSingleEvent(of: .value, with: { (snapshot) in
            if let topItem = snapshot.children.allObjects as? [DataSnapshot] {
                for item in topItem {
//                    UIApplication.shared.isNetworkActivityIndicatorVisible = true
                    self.idTopEvent.append(String(describing: item.childSnapshot(forPath: "id").value!))
                    self.seoTopEvent.append(String(describing: item.childSnapshot(forPath: "seo").value!))
                    self.imgTopEvent.append(String(describing: item.childSnapshot(forPath: "img").value!))
                    self.nameTopEvent.append(String(describing: item.childSnapshot(forPath: "title").value!))
                    self.showTop.reloadData()
//                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
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
