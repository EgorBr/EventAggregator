//
//  BuyWebViewController.swift
//  EventAggregator
//
//  Created by Egor Bryzgalov on 10.10.2017.
//  Copyright © 2017 Egor Bryzgalov. All rights reserved.
//

import UIKit

class BuyWebViewController: UIViewController {

    @IBOutlet weak var buyTicketFromWeb: UIWebView!
    @IBAction func closeButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func backPageButton(_ sender: Any) {
        buyTicketFromWeb.goBack()
    }
    @IBAction func reloadPageButton(_ sender: Any) {
        buyTicketFromWeb.reload()
    }
    
    var event: String = ""
//    var date: String = ""
//    var time: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let urlBuyTicket = URL(string: "https://ponominalu.ru/event/\(event)?promote=eda0f065aec3fce22d0708362ca67e48")
        buyTicketFromWeb.loadRequest(URLRequest(url: urlBuyTicket!))
        buyTicketFromWeb.reload()
        navigationController?.navigationBar.tintColor = UIColor(colorLiteralRed: 255/255, green: 255/255, blue: 255/255, alpha: 1)
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
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
