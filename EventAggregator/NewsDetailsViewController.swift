//
//  NewsDetailsViewController.swift
//  EventAggregator
//
//  Created by Egor Bryzgalov on 17.10.2017.
//  Copyright © 2017 Egor Bryzgalov. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class NewsDetailsViewController: UIViewController {

    var idNews: String = ""
    
    @IBOutlet weak var imgNews: UIImageView!
    @IBOutlet weak var nameNews: UILabel!
    @IBOutlet weak var textNews: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        newsDetails()
        nameNews.sizeToFit()
        textNews.sizeToFit()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func newsDetails() {
        Alamofire.request("https://kudago.com/public-api/v1.3/news/\(self.idNews)/?text_format=text", method: .get).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                if json["images"][0]["image"].stringValue != "" {
                    let imgURL: NSURL = NSURL(string: json["images"][0]["image"].stringValue)!
                    let imgData: NSData = NSData(contentsOf: imgURL as URL)!
                    let image: UIImageView = self.imgNews
                    image.image = UIImage(data: imgData as Data)
                }
                self.nameNews.text = json["title"].stringValue
                self.textNews.text = json["body_text"].stringValue
            case .failure(let error):
                print(error)
//                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
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
