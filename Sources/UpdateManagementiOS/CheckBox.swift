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
    let checkedImage = ImageLoader.loadImage(named: "CheckBoxSelected.png")
    let uncheckedImage = ImageLoader.loadImage(named: "CheckBoxUnSelected.png")
      
    // Bool property to track the checked state
    var isChecked: Bool = false {
        didSet {
            updateImage()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addTarget(self, action: #selector(checkboxTapped), for: .touchUpInside)
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
 
public class ImageLoader {
    public static func loadImage(named name: String) -> UIImage? {
        guard let imageUrl = imageUrl(named: name),
              let imageData = try? Data(contentsOf: imageUrl),
              let image = UIImage(data: imageData) else {
            return nil
        }
        return image
    }

    private static func imageUrl(named name: String) -> URL? {
        let currentFileURL = URL(fileURLWithPath: #file)
        let resourcesDirectory = currentFileURL.deletingLastPathComponent().appendingPathComponent("Resources")
        let imageUrl = resourcesDirectory.appendingPathComponent(name)
        return imageUrl
    }
}

