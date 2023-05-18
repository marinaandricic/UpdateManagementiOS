//
//  UpdateManagament.swift
//  
//
//  Created by Marina Andricic on 17/05/2023.
//
 
import UIKit

@objcMembers
public class UpdateManagament: NSObject {
    
    var sessionManager = SessionManager()
    let updateManagerFields = UpdateManagerFields().self;
    let localisedText = LocalisedText().self;
    
    public var requireLogout = false;
    
    enum UpdateMode: String {
        case Optional = "optional"
        case Mandatory = "mandatory"
    }
    
    @objc(StartUpdateProcessWithBrand:localVersion:completion:)
    public func Start(brand: String, localVersion: String, completion: @escaping (Bool) -> Void)  {
        //URL USED FOR TEST ONLY
        let urlForBrand = String(format: NSLocalizedString("https://j2-update.netlify.app/%@_iOS_current.json", comment: ""), brand)
        if let fileURL = URL(string: urlForBrand) {
            
            let session = URLSession.shared
            let task = session.dataTask(with: fileURL) { [self] (data, response, error) in
                if let error = error {
                    print( "error with jSON file \(error.localizedDescription)" )
                    return
                }
                
                do {
                    guard let manifestData = data else {
                        print("\(fileURL).json missing for brand \(brand)")
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
                    self.Update(brand: brand, localVersion: localVersion, completion: completion)
                } catch {
                    print("Error with data in jSON file \(fileURL): \(error)" )
                }
            }
            task.resume()
        }
    }
    
    private func Update(brand: String, localVersion: String, completion: @escaping (Bool) -> Void) {
        
        //guard let localVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String  else {
        //    return
        // }
         
        if self.updateManagerFields.version.compare(localVersion, options: .numeric) == .orderedDescending {
            var WaitTime = 0.0;
            if (self.updateManagerFields.type == UpdateMode.Mandatory.rawValue) {
                WaitTime = 2.0
            }
            // check device iOS version
            let deviceVersion = UIDevice.current.systemVersion
            if let platformMinTarget = self.updateManagerFields.platformMinTarget, platformMinTarget > deviceVersion {
                if self.updateManagerFields.type == UpdateMode.Mandatory.rawValue {
                    completion(true)
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + WaitTime) {
                    self.showUpdateiOSDialog(brand: brand)
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
                            self.showUpdateOptionalDialog(brand: brand)
                        }
                    } else {
                        // display mandatory alert
                        // logout user if Mandatory update
                        completion(true)
                        DispatchQueue.main.asyncAfter(deadline: .now() + WaitTime) {
                            // display mandatory alert
                            self.showUpdateMandatoryDialog(brand: brand)
                        }
                    }// Update Type is optional
                } else if self.updateManagerFields.type == UpdateMode.Optional.rawValue {
                    // check if previous mandatory version was installed
                    if self.updateManagerFields.previousMandatoryVersion?.compare(localVersion, options: .numeric) == .orderedDescending {
                        // logout user if Mandatory update
                        completion(true)
                        DispatchQueue.main.asyncAfter(deadline: .now() + WaitTime) {
                            // display mandatory alert
                            self.showUpdateMandatoryDialog(brand: brand)
                        }
                    } else {
                        // Check if alert message should be displayed today
                        if getOptionalReminderDate()  {
                            // display optional alert
                            self.showUpdateOptionalDialog(brand: brand)
                        }
                    }
                } else {
                    return
                }
            }
        } else {
            // NOTE if version on server is greater we need to clear session for recurring Update alerts and re-set UpdateManagerReminderShow to true
            sessionManager.removeValue(forKey: "UpdateManagerReminderDate")
            sessionManager.setValue("true", forKey: "UpdateManagerReminderShow")
            // UserDefaults.sharedGroup?.clearUpdateManagerRecurringAlert();
            // UserDefaults.sharedGroup?.UpdateManagerReminderShow = true
        }
    }
}
