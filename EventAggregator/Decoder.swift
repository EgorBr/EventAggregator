//
//  DecodeHTML.swift
//  EventAggregator
//
//  Created by Egor Bryzgalov on 12.07.17.
//  Copyright © 2017 Egor Bryzgalov. All rights reserved.
//

import Foundation
import WebKit

class Decoder {
    func decodehtmltotxt(htmltxt: String) -> String {
        let encodedString = htmltxt
        guard let data = encodedString.data(using: .utf8) else {
            return "nil"
        }
        
        let options: [String: Any] = [
            NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
            NSCharacterEncodingDocumentAttribute: String.Encoding.utf8.rawValue
        ]
        
        guard let attributedString = try? NSAttributedString(data: data, options: options, documentAttributes: nil) else {
            return "nil"
        }
        
        let decodedString = attributedString.string
        return decodedString
    }
    
    func dateformatter(date: String!) -> String {
        
        let deFormatter = DateFormatter()
        deFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        let startTime = deFormatter.date(from: date)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy HH:mm"
        let timeString = formatter.string(from: startTime!)
        
        return timeString
    }
    
    func timeConvert(sec: String) -> String {
        let seconds = NSDate(timeIntervalSince1970: Double(sec)!)
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy HH:mm"
        let time = formatter.string(from: seconds as Date)
        return time
    }
    
    func timeConvertToSec(startTime: String) -> Int {
        let datef = DateFormatter() // formatter
        datef.dateFormat = "dd.MM.yyyy HH:mm" // format
        let date = datef.date(from: startTime) // date "May 8, 2015, 5:25 PM"
//        let offset:NSTimeInterval = 3 * 3600 // (+3 hours) // hours offset
        let timestamp = date!.timeIntervalSince1970// + offset //1431105930
        return Int(timestamp)
    }
    
}
