# Mobile.iOS.UpdateManagementFramework

A description of this package.

<a href="https://github.com/marinaandricic/UpdateManagementiOS" target="_blank">
    <img src="https://img.shields.io/badge/platform-iOS%20%7C%20-lightgray.svg?style=flat" alt="Platform: iOS" />
</a> 

## Introduction

**Mobile.iOS.UpdateManagementFramework** is update management framework used for iOS to provide capabilities to the application to keep the application updated with our releases.
 
### Features 
 - [x] The system allows for mandatory updates (stopping the user from using it until updated
 - [x] The system allows to set a grace period for updates (allowing a given amount of time or usage before the update becomes mandatory).
 - [x] The system allows for optional updates.

## Documentation

* [Update Management Flow] (https://github.com/marinaandricic/UpdateManagementiOS/files/11553583/Update.Manager.pdf)

## Quick Start Guide

Using Mobile.iOS.UpdateManagementFramework is incredibly simple out of the box amd can be added to any iOS appliction that requires Update Management.

### Add Mobile.iOS.UpdateManagementFramework to your project

![image](https://github.com/marinaandricic/UpdateManagementiOS/assets/48448852/ba463f93-d575-458d-8813-7e99cf0e947d)

### Import Mobile.iOS.UpdateManagementFramework into AppDelegate file.

```objective-c
    @import Mobile.iOS.UpdateManagementFramework;
```

### include UpdateManagementFramework under applicationDidBecomeActive event

#### Mobile.iOS.UpdateManagementFramework requires 4 parameters - they are all required

* **localVersion** - Current installed version
    * example [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"];
* **brand** 
    * example AppConfiguration.current.brand
* **images** checkBoxSelected and checkBoxUnSelected - Used for optional update, "Dont remind me again
    * images can be set as follows
        * example [UIImage imageNamed:@"CheckBoxSelected"];
    * images can also be set differently based on current brand 
        * example  [UIImage imageNamed:CheckBoxSelected inBundle:AppConfiguration.current.brand compatibleWithTraitCollection:nil];
* **jSON File Location URL**
    * Different file is used for different brand 
    * Naming format of the file is 
        * https://j2-update.netlify.app/**@Brand**_iOS_current.json
    * File contains all required values for upgrade
    * Example of jSON file 
    * ```jSON
        {
          "releaseDate": "2023-05-09 12:00.00+000",
          "platform": "iOS",
          "platformMinTarget": "13",
          "version": "12.14.1",
          "type": "mandatory",
          "updateBy": "2023-05-16 12:00.00+000",
          "reminders": "3",
          "updateURL": "https://apps.apple.com/us/app/line2-second-phone-number/id319185557?itsct=apps_box_link&itscg=30200",
          "previousMandatoryVersionCode": "12.13"
      }
    ```
 
### Basic Configuration 

Simply call configure with 4 parameters mentioned above
```objective-c
    NSString *localVersion = [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"];
    NSString *brand = AppConfiguration.current.brand;
    UIImage *checkBoxSelected_Image = [UIImage imageNamed:@"CheckBoxSelected"]; 
    UIImage *checkBoxUnSelected_Image = [UIImage imageNamed:@"CheckBoxUnSelected"];
    NSString *urlPerBrand = AppConfiguration.current.platform.updateManagementURL;
    
    UpdateManagementFramework *updateManager = [[UpdateManagementFramework alloc] initWithBrand: brand url: urlPerBrand localVersion: localVersion  checkBoxSelected_Image: checkBoxSelected_Image checkBoxUnSelected_Image: checkBoxUnSelected_Image];
    [updateManager StartUpdateProcessWithcompletion:^(BOOL requireLogout) {
        if (requireLogout) { 
          ///// Call Logout [L2KitchenSinkManager.sharedInstance logoutAllAccounts];
        }
    }];
```

### Run Appliction 
By running application UpdateManagementFramework will be hit every time when application become acctive

   
