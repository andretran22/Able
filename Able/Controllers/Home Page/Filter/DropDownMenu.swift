//
//  dropDownMenu.swift
//  Able
//
//  Created by Andre Tran on 11/4/20.
//

import Foundation
import UIKit

class DropDownMenu: UIPickerView, UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        <#code#>
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        <#code#>
    }
    
    func createPickerView() -> UIPickerView {
        let pickerView = UIPickerView()
        pickerView.delegate = self
        return pickerView
    }
    
    // Sort By menu, close menu
    func dismissPickerView() {
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let button = UIBarButtonItem(title: "Done", style: .plain, target: self, action: action)
        toolBar.setItems([button], animated: true)
        toolBar.isUserInteractionEnabled = true
//        sortField.inputAccessoryView = toolBar
    }
    // Sort By menu, action to close menu
    func action() {
        view.endEditing(true)
    }
  
}
