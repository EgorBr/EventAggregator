//
//  ManagerData.swift
//  EventAggregator
//
//  Created by Egor Bryzgalov on 02.12.2017.
//  Copyright © 2017 Egor Bryzgalov. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON





class ManagerData {
    
    let utils: Utils = Utils()
    
    func loadNews() -> (id: [String], title: [String], description: [String], img: [NSData]) {
        var id: [String] = []
        var title: [String] = []
        var description: [String] = []
        var img: [NSData] = []
        Alamofire.request("https://kudago.com/public-api/v1.2/news/?fields=id,title,description,images&order_by=-publication_date&text_format=text&location=\(uds.value(forKey: "citySlug") as! String)", method: .get).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                for (_, value) in json["results"] {
                    id.append(value["id"].stringValue)
                    print(id)
                    title.append(value["title"].stringValue)
                    description.append(value["description"].stringValue)
                    img.append(self.utils.loadImage(url: value["images"][0]["image"].stringValue))
                }
            case .failure(let error):
                print(error)
            }
        }
        return (id, title, description, img)
    }
}
