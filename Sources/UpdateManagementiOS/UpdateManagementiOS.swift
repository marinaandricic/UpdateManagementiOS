//
//  UpdateManagementiOS.swift
//
//
//  Created by Marina Andricic on 17/05/2023.
//
 
import UIKit

@objcMembers
public class UpdateManagementiOS: NSObject {
    
    var sessionManager = SessionManager()
    let updateManagerFields = UpdateManagerFields();
    let localizedText = LocalizedText();
    
    public var isMandatory = false;
    
    var brand: String
    var localVersion: String
    var checkBoxSelected_Image: String
    var checkBoxUnSelected_Image: String
     
    public init(brand: String, localVersion: String, checkBoxSelected_Image: String, checkBoxUnSelected_Image: String) {
        self.brand = brand
        self.localVersion = localVersion
        self.checkBoxSelected_Image = checkBoxSelected_Image
        self.checkBoxUnSelected_Image = checkBoxUnSelected_Image
    }
    
    @objc(StartUpdateProcessWithcompletion:)
    public func Start( completion: @escaping (Bool) -> Void)  {
        
        //URL USED FOR TEST ONLY
        let urlForBrand = String(format: NSLocalizedString(localizedText.JSONUrl, comment: ""), self.brand)
        if let fileURL = URL(string: urlForBrand) {
            
            let session = URLSession.shared
            let task = session.dataTask(with: fileURL) { [self] (data, response, error) in
                if let error = error {
                    print( "error with jSON file \(error.localizedDescription)" )
                    return
                }
                
                do {
                    guard let manifestData = data else {
                        print("\(fileURL).json missing for brand \(self.brand)")
                        return
                    }
                    guard let jsonObject = try JSONSerialization.jsonObject(with: manifestData, options: .allowFragments) as? [String: String]
                    else {
                        print("\(fileURL).json file is not in the correct format")
                        return
                    }
                    if let manifestValues = jsonObject as? [String: String] {
                        for (key, value) in manifestValues {
                            self.updateManagerFields.updateValues(key: key, value: value)
                        }
                    }
                    self.Update(completion: completion)
                } catch {
                    print("Error with data in jSON file \(fileURL): \(error)" )
                }
            }
            task.resume()
        }
    }
    
    private func Update(completion: @escaping (Bool) -> Void) {
        
        if self.updateManagerFields.version.compare(self.localVersion, options: .numeric) == .orderedDescending {
            var WaitTime = 3.0;
             
            // check device iOS version
            let deviceVersion = UIDevice.current.systemVersion
            if let platformMinTarget = self.updateManagerFields.platformMinTarget, platformMinTarget > deviceVersion {
                if self.updateManagerFields.type == UpdateMode.Mandatory.rawValue {
                    completion(true)
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + WaitTime) {
                    self.showUpdateiOSDialog(brand: self.brand)
                }
            } else {
                // Check for updates only if we have updateType set to Optional or Mandatory else return to app
                // Update Type is mandatory
                if self.updateManagerFields.type == UpdateMode.Mandatory.rawValue {
                    // check if end date is set and if it is greater that today - Upgrade is not mandatory until isMandatoryOptional is set to false
                    if isMandatoryOptional {
                        // Check if alert message should be displayed today
                        if getOptionalReminderDate() {
                            // display optional alert
                            self.showUpdateOptionalDialog(brand: self.brand)
                        }
                    } else {
                        // display mandatory alert
                        // logout user if Mandatory update
                        completion(true)
                        DispatchQueue.main.asyncAfter(deadline: .now() + WaitTime) {
                            // display mandatory alert
                            self.showUpdateMandatoryDialog(brand: self.brand)
                        }
                    }// Update Type is optional
                } else if self.updateManagerFields.type == UpdateMode.Optional.rawValue {
                    // check if previous mandatory version was installed
                    if self.updateManagerFields.previousMandatoryVersion?.compare(self.localVersion, options: .numeric) == .orderedDescending {
                        // logout user if Mandatory update
                        completion(true)
                      
                        DispatchQueue.main.asyncAfter(deadline: .now() + WaitTime) {
                            // display mandatory alert
                            self.showUpdateMandatoryDialog(brand: self.brand)
                        }
                    } else {
                        // Check if alert message should be displayed today
                        if getOptionalReminderDate()  {
                            // display optional alert
                            self.showUpdateOptionalDialog(brand: self.brand)
                        }
                    }
                } else {
                    return
                }
            }
        } else {
            // if version on server is greater than local we clear session for recurring Update alerts and re-set UpdateManagerReminderShow to true
            self.sessionManager.clearSession(key: self.sessionManager.UpdateManagerReminderDateKey)
            self.sessionManager.UpdateManagerReminderShow = "true"
        }
    }
}
