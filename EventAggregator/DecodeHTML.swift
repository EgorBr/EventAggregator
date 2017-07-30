//
//  DecodeHTML.swift
//  EventAggregator
//
//  Created by Egor Bryzgalov on 12.07.17.
//  Copyright © 2017 Egor Bryzgalov. All rights reserved.
//

import Foundation
import WebKit

class DecodeHTML {
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
//    func nsDate(time: String) -> String {
//        let startTimeString = "2015-06-26T00:10:00+01:00"
//        
//        // First convert the original formatted date/time to a string:
//        let deFormatter = DateFormatter()
//        deFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
//        let startTime = deFormatter.date(from: startTimeString)
//        print(startTime!) // 2015-06-25 23:10:00 +0000
//        
//        // Note that `println` use the `description` method which defaults to UTC.
//        // Then convert the date/time to the desired formatted string:
//        let formatter = DateFormatter()
//        formatter.dateFormat = "HH:mm"
//        let timeString = formatter.string(from: startTime!)
//        print(timeString) // 2015-06-25 19:10:00
//        // Note that `NSDateFormatter` defaults to the local time zone.
//    return timeString
    }
}
