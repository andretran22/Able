//
//  customFilterCell.swift
//  Able
//
//  Created by Andre Tran on 11/4/20.
//

import Foundation
import UIKit

protocol CustomTagDelegate {
    func deleteTagItem(tagToDelete: String)
}

class MyCategoryCell:UICollectionViewCell{
    
    @IBOutlet weak var customTagLabel: UILabel!
    var customTagDelegate: CustomTagDelegate!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        layer.backgroundColor = UIColor.clear.cgColor
        layer.borderColor = UIColor.black.cgColor
        layer.cornerRadius = 8
        layer.borderWidth = 1
    }
    
    @IBAction func deleteItemAction(_ sender: Any) {
        customTagDelegate?.deleteTagItem(tagToDelete: customTagLabel.text!)
    }
    
    
}
