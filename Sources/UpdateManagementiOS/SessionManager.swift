//
//  SessionManager.swift
//  
//
//  Created by Marina Andricic on 17/05/2023.
//

import Foundation
 
public struct  SessionManager {
    private let userDefaults: UserDefaults
    let UpdateManagerReminderDateKey = "UpdateManagerReminderDateKey"
    let UpdateManagerReminderShowKey = "UpdateManagerReminderShowKey"

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    var UpdateManagerReminderDate: Date? {
        get {
            return userDefaults.string(forKey: UpdateManagerReminderDateKey) as? Date
        }
        set {
            userDefaults.set(newValue, forKey: UpdateManagerReminderDateKey)
        }
    }
    
    var UpdateManagerReminderShow: Bool? {
        get {
            return userDefaults.string(forKey: UpdateManagerReminderShowKey) as? Bool
        }
        set {
            userDefaults.set(newValue, forKey: UpdateManagerReminderShowKey)
        }
    }

    func clearSession(key: String) {
        userDefaults.removeObject(forKey: key)
    }
}



//public struct SessionManager {
   // private var sessionData: [String: Any] = [:]
     
   /// public mutating func setValue(_ value: Any, forKey key: String) {
   //     sessionData[key] = value
   // }
    
   // public func getValue(forKey key: String) -> Any? {
   //     return sessionData[key]
   // }
     
   // public mutating func removeValue(forKey key: String) {
   //     sessionData.removeValue(forKey: key)
  //  }
//}
