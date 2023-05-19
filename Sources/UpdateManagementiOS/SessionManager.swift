//
//  SessionManager.swift
//  
//
//  Created by Marina Andricic on 17/05/2023.
//

import Foundation
 
struct SessionManager {
    private let userDefaults: UserDefaults
    let UpdateManagerReminderDateKey = "UpdateManagerReminderDateKey"
    let UpdateManagerReminderShowKey = "UpdateManagerReminderShowKey"

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    var UpdateManagerReminderDate: Any? {
        get {
            return userDefaults.string(forKey: UpdateManagerReminderDateKey)
        }
        set {
            userDefaults.set(newValue, forKey: UpdateManagerReminderDateKey)
        }
    }
    
    var UpdateManagerReminderShow: Any? {
        get {
            return userDefaults.string(forKey: UpdateManagerReminderShowKey)
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
