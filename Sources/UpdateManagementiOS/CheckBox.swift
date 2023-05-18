//
//  CheckBox.swift
//  
//
//  Created by Marina Andricic on 17/05/2023.
//

import Foundation
import UIKit

class CheckBox: UIButton {
    
    // Images for checkbox states
    var checkedImage: UIImage!
    var uncheckedImage: UIImage!
     
    // Bool property to track the checked state
    var isChecked: Bool = false {
        didSet {
            updateImage()
        }
    }
    
    public init(frame: CGRect, checkedImage: String, uncheckedImage: String) {
        super.init(frame: frame)
        addTarget(self, action: #selector(checkboxTapped), for: .touchUpInside)
        
        self.checkedImage =  UIImage(named: checkedImage)
        self.uncheckedImage = UIImage(named: uncheckedImage)
         
        updateImage()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addTarget(self, action: #selector(checkboxTapped), for: .touchUpInside)
        updateImage()
    }
    
    @objc private func checkboxTapped() {
        isChecked = !isChecked
    }
    
    private func updateImage() {
        let image = isChecked ? checkedImage : uncheckedImage
        setImage(image, for: .normal)
    }
}


