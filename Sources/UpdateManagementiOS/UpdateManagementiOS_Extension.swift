//
//  UpdateManagementiOS_Extension.swift
//  
//
//  Created by Marina Andricic on 17/05/2023.
//

import Foundation
import UIKit
 
extension UpdateManagementiOS {
    
    func showUpdateiOSDialog(brand: String) {
        let alert = UIAlertController(title: self.getDialogTitle(), message: self.getDialogBodyiOSUpgrade(brand:brand), preferredStyle: .alert)
         
        let remindLaterAction = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .cancel, handler:nil)
        alert.addAction(remindLaterAction)
        
        DispatchQueue.main.async {
            self.isMandatory = true
            guard let rootViewController = UIApplication.shared.keyWindow?.rootViewController else {
                return
            }
            rootViewController.present(alert, animated: true, completion: nil)
        }
    }
    
    func showUpdateOptionalDialog(brand: String) {
        
        let alert = UIAlertController(title: self.getDialogTitle(), message: self.getDialogBody(brand:brand), preferredStyle: .alert)
        
        guard let url = URL(string: self.updateManagerFields.updateURL) else {
            return
        }
        let checkbox = CheckBox(frame: CGRect(x: 50, y: 50, width: 20, height: 20), checkedImage: self.checkBoxSelected_Image, uncheckedImage: self.checkBoxUnSelected_Image)
        
        // include "Don't Remind Me Again" option only for optional update
        if (self.updateManagerFields.type == UpdateMode.Optional.rawValue) {
            
            let label = UILabel()
            label.text = "Don't Remind Me Again"
            
            let stackView = UIStackView()
            stackView.axis = .horizontal
            stackView.spacing = 5
            stackView.addArrangedSubview(checkbox)
            stackView.addArrangedSubview(label)
            
            alert.view.addSubview(stackView)
            
            stackView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                stackView.topAnchor.constraint(equalTo: alert.view.topAnchor, constant: 100),
                stackView.leadingAnchor.constraint(equalTo: alert.view.leadingAnchor, constant: 20)
            ])
        }
        
        let updateAction = UIAlertAction(title: "OK", style: .default, handler: { action in
            if (checkbox.isChecked && self.updateManagerFields.type == UpdateMode.Optional.rawValue) {
                self.sessionManager.clearSession(key: self.sessionManager.UpdateManagerReminderDateKey)
                self.sessionManager.UpdateManagerReminderShow = false
            } else {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        })
        
        let remindLaterAction = UIAlertAction(title: "Cancel", style: .default, handler: { action in
            self.setOptionalReminderDate()
        })
        
        DispatchQueue.main.async {
            
            alert.addAction(remindLaterAction)
            alert.addAction(updateAction)
            
            guard let rootViewController = UIApplication.shared.keyWindow?.rootViewController else {
                return
            }
            rootViewController.present(alert, animated: true, completion: nil)
        }
    }
    
    func showUpdateMandatoryDialog(brand: String) {
        let alert = UIAlertController(title: self.getDialogTitle(), message: self.getDialogBody(brand: brand), preferredStyle: .alert)
        guard let url = URL(string: self.updateManagerFields.updateURL) else {
            return
        }
        let updateAction = UIAlertAction(title: "OK", style: .default, handler: { action in
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        })
        
        // include cancel option only if Mandatory update end date is not nil
        if self.isMandatory == false  {
            let remindLaterAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
                self.setOptionalReminderDate()
            })
            alert.addAction(remindLaterAction)
        }
        alert.addAction(updateAction)
        
        DispatchQueue.main.async {
            self.isMandatory = true
            guard let rootViewController = UIApplication.shared.keyWindow?.rootViewController else {
                return
            }
            rootViewController.present(alert, animated: true, completion: nil)
        }
    }
    
    var isMandatoryOptional: Bool {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm.ssZ"
        
        let currentDate = Date()
        if let optionalUpdateEndDateString = self.updateManagerFields.updateBy {
            let optionalUpdateEndDate = dateFormatter.date(from: optionalUpdateEndDateString)!
            
            let resultCompare = currentDate.compare(optionalUpdateEndDate)
           
            if resultCompare == .orderedAscending || resultCompare == .orderedSame {
                return true
            } else {
                self.isMandatory = true
                return false
            }
        } else {
            return false
        }
    }
    
    func getOptionalReminderDate() -> Bool {
        let currentDate = Date()
          
        let reminderDate = sessionManager.UpdateManagerReminderDate ?? currentDate
        let reminderShow = sessionManager.UpdateManagerReminderShow
        
        if  currentDate == reminderDate  {
            return reminderShow
        }
        else if  currentDate < reminderDate  {
            return false
        }  else {
            self.sessionManager.UpdateManagerReminderDate = currentDate
            return reminderShow
        }
    }
    
    // UpdateManagerReminderDate is used to save date for next optional alert
    func setOptionalReminderDate() {
      
        let currentDate = Date()
        let calendar = Calendar.current
        var dateComponents = DateComponents()
        dateComponents.day = self.updateManagerFields.reminders ?? 0
        
        if let reminderDare = calendar.date(byAdding: dateComponents, to: currentDate) {
            self.sessionManager.UpdateManagerReminderDate = reminderDare
        }
    }
    
    // Different title will be displayed for mandatory and optional alerts
    func getDialogTitle() -> String {
        if ((self.updateManagerFields.type == UpdateMode.Optional.rawValue) ) {
            return String(NSLocalizedString("UpdateManagementOptionalTitle", comment: ""))
        }
        else {
            return String(NSLocalizedString("UpdateManagementMandatoryTitle", comment: ""))
        }
    }
    
    // Different message will be displayed for mandatory, madatory with date and optional alerts
    private func getDialogBody(brand: String) -> String {
        if ((self.updateManagerFields.type == UpdateMode.Optional.rawValue) ) {
            return String(format: NSLocalizedString("UpdateManagementOptional", comment: ""), brand, self.updateManagerFields.version, self.updateManagerFields.platformMinTarget!)
        }
        else {
            if self.isMandatory == true {
                return String(format: NSLocalizedString("UpdateManagementMandatory", comment: ""), brand, self.updateManagerFields.version)
            }
            else {
                let updateBy = self.updateManagerFields.updateBy!
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm.ssZ"
                
                let optionalUpdateEndDate = dateFormatter.date(from: updateBy)!
                dateFormatter.dateFormat = "yyyy-MM-dd"
                
                return String(format: NSLocalizedString("UpdateManagementMandatoryWithDate", comment: ""), brand, dateFormatter.string(from: optionalUpdateEndDate), self.updateManagerFields.version)
            }
        }
    }
     
    func getDialogBodyiOSUpgrade(brand: String) -> String {
        if ((self.updateManagerFields.type == UpdateMode.Optional.rawValue) ) {
            return String(format: NSLocalizedString("UpdateiOSForUpdateManagementOptional", comment: ""), brand, self.updateManagerFields.platformMinTarget!)
        }
        else {
            return String(format: NSLocalizedString("UpdateiOSUpdateManagementMandatory", comment: ""), brand, self.updateManagerFields.platformMinTarget!)
        }
    }
    
    
}

enum UpdateMode: String {
    case Optional = "optional"
    case Mandatory = "mandatory"
}
