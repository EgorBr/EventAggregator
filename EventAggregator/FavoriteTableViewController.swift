//
//  FavoriteTableViewController.swift
//  EventAggregator
//
//  Created by Egor Bryzgalov on 26.08.17.
//  Copyright © 2017 Egor Bryzgalov. All rights reserved.
//

import UIKit
import RealmSwift
import FirebaseDatabase
import SWRevealViewController
import Realm

class FavoriteTableViewController: UITableViewController {

    let realm = try! Realm()
    
    var favoriteId: [String] = []
    var favoriteTitle: [String] = []
    var favoriteDescription: [String] = []
    var favoriteStart: [Int] = []
    var img: [NSData] = []
    var favoriteTarget: [String] = []
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(load), name: NSNotification.Name(rawValue: "loadFavorite"), object: nil)
        self.tableView.estimatedRowHeight = 15
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.navigationItem.title = "Избранное"
        sideMenu()
        load()
    }
    func sideMenu() {
        if revealViewController() != nil {
            menuButton.target = revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            revealViewController().rearViewRevealWidth = 250
            tableView.addGestureRecognizer(self.revealViewController().tapGestureRecognizer())
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
    
    func load(){
        favoriteId = []
        favoriteTitle = []
        favoriteDescription = []
        favoriteStart = []
        img = []
        favoriteTarget = []
        let valueCityName = realm.objects(FavoriteEvent.self)
        for value in valueCityName {
            refEvent.child("\(value.region)/Events/\(value.target)/\(value.id)").observeSingleEvent(of: .value, with: { (snapshot) in
                if let val = snapshot.value as? NSDictionary {
                    self.favoriteTitle.append(val["short_title"] as? String ?? "")
                    self.favoriteId.append(val["id"] as? String ?? "")
                    self.favoriteDescription.append(val["description"] as? String ?? "")
                    self.favoriteStart.append((val["start_event"] as? Int)!)
                    self.img.append(Utils().loadImage(url: val["image"] as? String ?? ""))
                    self.favoriteTarget.append(value.target)
                    self.tableView.reloadData()
                }
            })
        }
        return
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return favoriteId.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let favoriteCell = tableView.dequeueReusableCell(withIdentifier: "favoriteCell", for: indexPath) as! FavoriteCell
        favoriteCell.favoriteName.text = self.favoriteTitle[indexPath.row]
        favoriteCell.favoriteDesc.text = self.favoriteDescription[indexPath.row]
        favoriteCell.favoriteST.text = Decoder().timeConvert(sec: String(self.favoriteStart[indexPath.row]))
        favoriteCell.img.image = UIImage(data: img[indexPath.row] as Data)
        return favoriteCell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            try! realm.write {
                realm.delete(realm.objects(FavoriteEvent.self).filter("id=%@",favoriteId[indexPath.row]))
            }
            favoriteId.remove(at: indexPath.item)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detailsFavorite" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let destinationVC = segue.destination as! DetailsViewController
                destinationVC.idEvent = favoriteId[indexPath.row]
                destinationVC.targetName = favoriteTarget[indexPath.row]
            }
        }
    }
}

class FavoriteCell: UITableViewCell {
    @IBOutlet weak var favoriteName: UILabel!
    @IBOutlet weak var favoriteDesc: UILabel!
    @IBOutlet weak var favoriteST: UILabel!
    @IBOutlet weak var img: UIImageView!
}
