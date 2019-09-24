//
//  AppDelegate.swift
//  Fitbit
//
//  Created by MOJAVE on 12/09/19.
//  Copyright © 2019 Partnerpeople. All rights reserved.
//

import UIKit
import CoreData
import FBSDKCoreKit

extension UIViewController{
    
    func validateEmail(_ enteredEmail:String, alertText:String) -> Bool{
        
        return validateEmail(enteredEmail, alertTitle: "Alert!", alertText: alertText)
    }
    
    func validateEmail(_ enteredEmail:String, alertTitle:String, alertText:String) -> Bool{
        
        let emailFormat = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailFormat)
        
        if !emailPredicate.evaluate(with: enteredEmail)
        {
            let alert = UIAlertController(title: alertTitle, message: alertText, preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return false
        }
        return true //emailPredicate.evaluate(with: enteredEmail)
    }
    
    func validateText(_ enteredText:String, alertText:String) -> Bool{
        
        return self.validateText(enteredText, alertTitle: "Alert!", alertText: alertText)
    }
    
    func validateText(_ enteredText:String, alertTitle:String, alertText:String) -> Bool{
        
        if enteredText.replacingOccurrences(of: " ", with: "").count == 0
        {
            let alert = UIAlertController(title: alertTitle, message: alertText, preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return false
        }
        
        return true
    }
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        return true
    }

    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return ApplicationDelegate.shared.application(
            application,
            open: url,
            sourceApplication: sourceApplication,
            annotation: annotation
        )
    }

    @available(iOS 9.0, *)
    func application(_ application: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any]) -> Bool {
        return ApplicationDelegate.shared.application(application, open: url, options: options)
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        AppEvents.activateApp()
    }
    
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

