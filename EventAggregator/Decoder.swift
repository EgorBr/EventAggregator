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
        guard let data = encodedString.data(using: .utf8) else { return ""}
        
        let options: [String: Any] = [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: String.Encoding.utf8.rawValue]
        
        guard let attributedString = try? NSAttributedString(data: data, options: options, documentAttributes: nil) else { return "" }
        
        let decodedString = attributedString.string
        return decodedString
    }
    //изменяем формат даты yyyy-MM-dd'T'HH:mm:ssZ -> dd.MM.yyyy HH:mm
    func dfTP(time: String!) -> Int {
        let datef = DateFormatter()
        datef.dateFormat = "dd.MM.yyyy HH:mm"
        let date = datef.date(from: time)
        if date == nil {
            return 0
        } else {
            let timestamp = date!.timeIntervalSince1970
            return Int(timestamp)
        }
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
    func timeConvertToSec(startTime: String, from: String) -> Int {
        let datef = DateFormatter()
        if from == "Ponaminalu" {
            datef.dateFormat = "yyy-MM-dd'T'HH:mm:ss"
        }
        if from == "filter" {
            datef.dateFormat = "dd.MM.yyyy"
        }
        if from == "TimePad" {
            datef.dateFormat = "yyyyy-MM-dd'T'HH:mm:ssZ"
        }
        let date = datef.date(from: startTime)
        if date == nil {
            return 0
        } else {
            let timestamp = date!.timeIntervalSince1970
            return Int(timestamp)
        }
        
    }
    
}
