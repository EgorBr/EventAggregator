//
//  SetFilterViewController.swift
//  EventAggregator
//
//  Created by Egor Bryzgalov on 02.11.2017.
//  Copyright © 2017 Egor Bryzgalov. All rights reserved.
//

import UIKit

class SetFilterViewController: UIViewController {
    @IBOutlet weak var switchCost: UISwitch!
    @IBOutlet weak var lableCost: UILabel!
    @IBOutlet weak var maxCost: UITextField!
    @IBOutlet weak var dateField: UITextField!
    
    let datePicker = UIDatePicker()
    
    var date: String!
    var switchStatus: Bool!
    var cost: String!    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if switchStatus == nil {
            maxCost.isEnabled = false
            switchCost.isOn = false
        } else {
            maxCost.isEnabled = true
            switchCost.isOn = true
            maxCost.text = cost
        }
        if date != nil {
            dateField.text = date
        }
        self.switchCost.addTarget(self, action: #selector(freeOrNotFree), for: .valueChanged)
        createDatePicker()
    }

    func freeOrNotFree() {
        if switchCost.isOn {
            lableCost.text = "Платные мероприятия"
            maxCost.isEnabled = true
        } else {
            lableCost.text = "Бесплатные мероприятия"
            maxCost.isEnabled = false
            maxCost.text = nil
        }
    }
    
    func createDatePicker() {
        datePicker.datePickerMode = .date
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donePressed))
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancleButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: nil, action: #selector(canclePressed))
        toolbar.setItems([cancleButton, spacer, doneButton], animated: false)
        
        dateField.inputAccessoryView = toolbar
        dateField.inputView = datePicker
    }

    func donePressed() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateField.text = dateFormatter.string(from: datePicker.date)
        date = dateFormatter.string(from: datePicker.date)
        self.view.endEditing(true)
    }
    
    func canclePressed() {
        self.view.endEditing(true)
    }
    
}
