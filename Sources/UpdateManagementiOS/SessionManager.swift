//
//  SessionManager.swift
//  
//
//  Created by Marina Andricic on 17/05/2023.
//

public struct SessionManager {
    private var sessionData: [String: Any] = [:]
     
    public mutating func setValue(_ value: Any, forKey key: String) {
        sessionData[key] = value
    }
    
    public func getValue(forKey key: String) -> Any? {
        return sessionData[key]
    }
     
    public mutating func removeValue(forKey key: String) {
        sessionData.removeValue(forKey: key)
    }
}
