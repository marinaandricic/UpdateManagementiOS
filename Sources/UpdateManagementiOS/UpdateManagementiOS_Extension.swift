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
            self.requireLogout = true
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
                self.sessionManager.removeValue(forKey: "UpdateManagerReminderDate")
                self.sessionManager.setValue("false", forKey: "UpdateManagerReminderShow")
                //  UserDefaults.sharedGroup?.UpdateManagerReminderShow = false
                //  UserDefaults.sharedGroup?.clearUpdateManagerRecurringAlert()
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
        if let dateEnd = self.updateManagerFields.updateBy, dateEnd != "" {
            let remindLaterAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
                self.setOptionalReminderDate()
            })
            alert.addAction(remindLaterAction)
        }
        alert.addAction(updateAction)
        
        DispatchQueue.main.async {
            self.requireLogout = true
            guard let rootViewController = UIApplication.shared.keyWindow?.rootViewController else {
                return
            }
            rootViewController.present(alert, animated: true, completion: nil)
        }
    }
    
    // Different title will be displayed for mandatory and optional alerts
    func getDialogTitle() -> String {
        if ((self.updateManagerFields.type == UpdateMode.Optional.rawValue) ) {
            return String(NSLocalizedString(localisedText.UpdateManagementOptionalTitle, comment: ""))
        }
        else {
            return String(NSLocalizedString(localisedText.UpdateManagementMandatoryTitle, comment: ""))
        }
    }
    
    // Different body will be displayed for mandatory, madatory with date and optional alerts
    private func getDialogBody(brand: String) -> String {
        if ((self.updateManagerFields.type == UpdateMode.Optional.rawValue) ) {
            return String(format: NSLocalizedString(localisedText.UpdateManagementOptional, comment: ""), brand, self.updateManagerFields.version, self.updateManagerFields.platformMinTarget!)
        }
        else {
            if let updateBy = self.updateManagerFields.updateBy, updateBy != "" {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm.ssZ"
                if let optionalUpdateEndDate = dateFormatter.date(from: updateBy) {
                    dateFormatter.dateFormat = "yyyy-MM-dd"
                    return String(format: NSLocalizedString(localisedText.UpdateManagementMandatoryWithDate, comment: ""), brand, dateFormatter.string(from: optionalUpdateEndDate), self.updateManagerFields.version)
                } else {
                    return String(format: NSLocalizedString(localisedText.UpdateManagementMandatoryWithDate, comment: ""), brand, updateBy, self.updateManagerFields.version)
                }
            } else {
                return String(format: NSLocalizedString(localisedText.UpdateManagementMandatory, comment: ""), brand, self.updateManagerFields.version)
            }
        }
    }
    
    // Different body will be displayed for mandatory
    
    func getDialogBodyiOSUpgrade(brand: String) -> String {
        if ((self.updateManagerFields.type == UpdateMode.Optional.rawValue) ) {
            return String(format: NSLocalizedString(localisedText.UpdateiOSForUpdateManagementOptional, comment: ""), brand, self.updateManagerFields.platformMinTarget!)
        }
        else {
            return String(format: NSLocalizedString(localisedText.UpdateiOSUpdateManagementMandatory, comment: ""), brand, self.updateManagerFields.platformMinTarget!)
        }
    }
    
    var isMandatoryOptional: Bool {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let currentDate = Date()
        if let optionalUpdateEndDateString = self.updateManagerFields.updateBy {
            let optionalUpdateEndDate = dateFormatter.date(from: optionalUpdateEndDateString)
            if let endDate = optionalUpdateEndDate, currentDate <= endDate {
                return true
            } else {
                requireLogout = true
                return false
            }
        } else {
            return false
        }
    }
    
    func getOptionalReminderDate() -> Bool {
        let currentDate = Date()
        var iOptional = true
        self.sessionManager.removeValue(forKey: "UpdateManagerReminderDate")
        self.sessionManager.setValue("false", forKey: "UpdateManagerReminderShow")
         
        if let reminderDate = sessionManager.getValue(forKey: "UpdateManagerReminderDate") {
            if currentDate == reminderDate as! Date {
                iOptional = self.sessionManager.getValue(forKey: "UpdateManagerReminderShow") as? Bool ?? true
            }
            else if currentDate < reminderDate as! Date {
                iOptional = false
            }
        }
        else {
            self.sessionManager.setValue(currentDate, forKey: "UpdateManagerReminderDate")
            iOptional = self.sessionManager.getValue(forKey: "UpdateManagerReminderShow") as? Bool ?? true
        }
        return iOptional
        // if let reminderDate = UserDefaults.sharedGroup?.updateManagerRecurringAlert , currentDate == reminderDate {
        //     return   UserDefaults.sharedGroup?.UpdateManagerReminderShow ?? true
        // } else if let reminderDate = UserDefaults.sharedGroup?.updateManagerRecurringAlert , currentDate < reminderDate {
        //return false
        //}
        //else {
        //     UserDefaults.sharedGroup?.updateManagerRecurringAlert =  currentDate
        //    return UserDefaults.sharedGroup?.UpdateManagerReminderShow  ?? true
        // }
    }
    
    // updateManagerRecurringAlert is used to save date for next alert
    func setOptionalReminderDate() {
        let currentDate = Date()
        let calendar = Calendar.current
        var dateComponents = DateComponents()
        dateComponents.day = self.updateManagerFields.reminders ?? 0
        
        if let reminderDare = calendar.date(byAdding: dateComponents, to: currentDate) {
            self.sessionManager.setValue(reminderDare, forKey: "UpdateManagerReminderDate")
            //UserDefaults.sharedGroup?.updateManagerRecurringAlert =  reminderDare
        }
    }
}

enum UpdateMode: String {
    case Optional = "optional"
    case Mandatory = "mandatory"
}

class UpdateManagerFields {
    
    var releaseDate:                    String?
    var platform:                       String?
    var platformMinTarget:              String?
    var version:                        String = ""
    var type:                           String?
    var updateBy:                       String?
    var reminders:                      Int?
    var updateURL:                      String = ""
    var previousMandatoryVersion:   String?
     
    public func updateValues(key: String, value: String){
        switch key {
        case "releaseDate":
            self.releaseDate = value
        case "platform":
            self.platform =  value
        case "platformMinTarget":
            self.platformMinTarget =  value
        case "version":
            self.version = "12.15.1"//value
        case "type":
            self.type = "optional"//value.lowercased()
        case "updateBy":
            self.updateBy = ""// value //"2023-05-31" //
        case "updateURL":
            self.updateURL =  value
        case "reminders":
            self.reminders = Int(value) != nil ? Int(value) : nil
        case "previousMandatoryVersionCode":
            self.previousMandatoryVersion = value
        default:
            break
        }
    }
}

class LocalisedText {
    let UpdateManagementOptionalTitle = "Update Available"
    let UpdateManagementMandatoryTitle = "Update Required";
    let UpdateManagementOptional = "A new version of %@ is available. Would you like to update to version %@ now? \n\n";
    let UpdateManagementMandatory = "A new version of %@ is available. You must update to version %@ to continue. ";
    let UpdateManagementMandatoryWithDate = "A new version of %@ is available. You must update it before %@. Would you like to update to version %@ now? ";
    let UpdateiOSForUpdateManagementOptional = "A new version of %@ is available. To continue to use the application you will need to upgrade your iOS to at least iOS %@ .";
    let UpdateiOSUpdateManagementMandatory = "A new version of %@ is available. To use the new version, you will need to upgrade your iOS to at least iOS %@ .";
}
