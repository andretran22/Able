//
//  categoryButton.swift
//  Able
//
//  Created by Andre Tran on 11/3/20.
//

import Foundation
import UIKit

protocol SelectedButtonDelegate {
    func setCategory (name: String)
    func removeCategory(name:String)
}

class SelectionButton: UIButton {

    // Allows developer to add own text in storyboard for the button
    @IBInspectable var selectedText:String = "Selected"
    var borderColorSelected:UIColor = UIColor.black
    var selectDelegate: SelectedButtonDelegate!
    var cornerRadius:CGFloat = 5
    var borderWidth:CGFloat = 3
    var backColor: UIColor!
    var active:Bool = false
    
    // Custom Border to the UIButton
    private let border = CAShapeLayer()
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.backColor = backgroundColor
    }
    
    override func draw(_ rect: CGRect) {
        
        // Setup CAShape Layer (Dashed/Solid Border)
        border.lineWidth = borderWidth
        border.frame = self.bounds
        border.fillColor = nil
        border.path = UIBezierPath(roundedRect: self.bounds, cornerRadius: cornerRadius).cgPath
        
        self.layer.addSublayer(border)
        self.layer.cornerRadius = cornerRadius
        self.layer.masksToBounds = true

        // Setup the Button Depending on What State it is in
        if active {
            setSelected()
        } else {
            setDeselected()
        }

        // Respond to touch events by user
        self.addTarget(self, action: #selector(onPress), for: .touchUpInside)
    }
    
    @objc func onPress() {
        active = !active
        if active {
            setSelected()
            selectDelegate.setCategory(name: selectedText)
        } else {
            setDeselected()
            selectDelegate.removeCategory(name: selectedText)
        }
    }
    
    func setSelected() {
        border.strokeColor = borderColorSelected.cgColor
        backgroundColor = backColor.adjust(by: -30)
    }
    
    func setDeselected(){
        border.strokeColor = nil
        backgroundColor = backColor
    }

}


// Extension to make buttons darker or lighter
extension UIColor {

    func lighter(by percentage: CGFloat = 30.0) -> UIColor? {
        return self.adjust(by: abs(percentage) )
    }

    func darker(by percentage: CGFloat = 30.0) -> UIColor? {
        return self.adjust(by: -1 * abs(percentage) )
    }

    func adjust(by percentage: CGFloat = 30.0) -> UIColor? {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        if self.getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
            return UIColor(red: min(red + percentage/100, 1.0),
                           green: min(green + percentage/100, 1.0),
                           blue: min(blue + percentage/100, 1.0),
                           alpha: alpha)
        } else {
            return nil
        }
    }
}
