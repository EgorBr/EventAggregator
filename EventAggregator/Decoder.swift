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
    //выбрасываем HTML текст
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
    //изменяем формат даты yyyy-MM-dd'T'HH:mm:ssZ -> dd.MM.yyyy HH:mm
    func dfTP(date: String!) -> String {
        
        let deFormatter = DateFormatter()
        deFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        let startTime = deFormatter.date(from: date)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy HH:mm"
        let timeString = formatter.string(from: startTime!)
        
        return timeString
    }
    //изменяем формат даты yyyy-MM-dd'T'HH:mm:ss -> dd.MM.yyyy HH:mm
    func dfPonam(date: String!) -> String {
        if date != "" {
            let deFormatter = DateFormatter()
            deFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            let startTime = deFormatter.date(from: date)
        
            let formatter = DateFormatter()
            formatter.dateFormat = "dd.MM.yyyy HH:mm"
            let timeString = formatter.string(from: startTime!)
            return timeString
        } else {
            return "-"
        }
        
        
    }
    //переводим из секунд в dd.MM.yyyy HH:mm для кудаго
    func timeConvert(sec: String) -> String {
        if sec != "" {
            let seconds = NSDate(timeIntervalSince1970: Double(sec)!)
            let formatter = DateFormatter()
            formatter.dateFormat = "dd.MM.yyyy HH:mm"
            let time = formatter.string(from: seconds as Date)
            return time
        } else {
            return "-"
        }
    }
    // переводим dd.MM.yyyy HH:mm -> СЕК
    func timeConvertToSec(startTime: String) -> Int {
        let datef = DateFormatter()
        datef.dateFormat = "yyy-MM-dd'T'HH:mm:ss"
        let date = datef.date(from: startTime)
        let timestamp = date!.timeIntervalSince1970
        return Int(timestamp)
    }
    
}
