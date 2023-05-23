//
//  UpdateManagerFields.swift
//  
//
//  Created by Marina Andricic on 19/05/2023.
//
 
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
            self.version = "12.15.8" // value
        case "type":
            self.type = "optional" //value.lowercased()
        case "updateBy":
            self.updateBy = value
        case "updateURL":
            self.updateURL =  value
        case "reminders":
            self.reminders = Int(value) != nil ? Int(value) : nil
        case "previousMandatoryVersionCode":
            self.previousMandatoryVersion = "12.14" //value
        default:
            break
        }
    }
}
 
