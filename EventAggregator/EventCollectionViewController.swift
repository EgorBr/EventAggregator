//
//  EventCollectionViewController.swift
//  EventAggregator
//
//  Created by Egor Bryzgalov on 20.07.17.
//  Copyright © 2017 Egor Bryzgalov. All rights reserved.
//

import UIKit

private let reuseIdentifier = "eventCell"

class EventCollectionViewController: UICollectionViewController {

    var city: String = ""
    var nameEvent: [String] = []
    var eventDescription: [String] = []
    var startEventTime: [String] = []
    var stopEventTime: [String] = []
    let loadDB: LoadDB = LoadDB()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        print(city)
        let eventDB = loadDB.loadDBDetailsEvent(name: city)
        for value in eventDB[0].eventList {
            nameEvent.append(value.name)
            eventDescription.append(value.event_description)
            startEventTime.append(value.start_time)
            stopEventTime.append(value.end_time)
        }
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
//        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return nameEvent.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        let labelName: UILabel = cell.viewWithTag(1) as! UILabel
        labelName.text = nameEvent[indexPath.row]
        let labelDetails: UILabel = cell.viewWithTag(2) as! UILabel
        labelDetails.text = eventDescription[indexPath.row]
//        let labelStopTime :UILabel = cell.viewWithTag(5) as! UILabel
//        labelStopTime.text = stopEventTime[indexPath.row]
        let labelStartTime :UILabel = cell.viewWithTag(4) as! UILabel
        labelStartTime.text = startEventTime[indexPath.row]
        let labelStopTime :UILabel = cell.viewWithTag(5) as! UILabel
        labelStopTime.text = stopEventTime[indexPath.row]
        
        
    
        // Configure the cell
    
        return cell
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}
