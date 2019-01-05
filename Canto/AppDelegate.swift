//
//  AppDelegate.swift
//  Canto
//
//  Created by WhoTan on 8/11/17.
//  Copyright © 2017 WhoTan. All rights reserved.
//

import UIKit
import OneSignal
import GoogleSignIn
import Fabric
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    
    func application(_ application: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any])
        -> Bool {
            return GIDSignIn.sharedInstance().handle(url,
                                                        sourceApplication:options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String,
                                                        annotation: [:])
    }
    
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        GIDSignIn.sharedInstance().clientID = "243773746715-ahsopgmn3jfvqthmkn32mi75lbc69hso.apps.googleusercontent.com"
        
        AppManager.initialize()
        let customFont = UIFont(name: "IRANYekanMobile", size: 17.0)!
        UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedStringKey.font: customFont], for: .normal)
        self.window = UIWindow.init(frame: UIScreen.main.bounds)
        let storyBoard = UIStoryboard.init(name: "Main", bundle: nil)
        var vc : UIViewController!
        
        if (UserDefaults.standard.value(forKey: "110Cache") as? Bool) == nil {
//            AppManager.sharedInstance().clearGenresCache()
            UserDefaults.standard.setValue(true, forKey: "110Cache")
        }
        
        
        if let token = UserDefaults.standard.value(forKey: AppGlobal.Token) as? String{
            if token.characters.count > 10 {
                
//                if AppManager.sharedInstance().getUserInfo().first_name == ""{
//                    vc = storyBoard.instantiateViewController(withIdentifier: "PhotoPicker")
//                }
                vc = storyBoard.instantiateViewController(withIdentifier: "mainTabBar")
            }else{
                vc = storyBoard.instantiateViewController(withIdentifier: "LoginMethod")
            }
        }else{
            vc = storyBoard.instantiateViewController(withIdentifier: "LoginMethod")
        }
		
        self.window!.rootViewController = vc
        self.window!.makeKeyAndVisible()
        AppManager.initialize()
        
        Fabric.with([Crashlytics.self])
        logUser()
        
        UIFont.overrideInitialize()
        // Override point for customization after application launch.
        
        let onesignalInitSettings = [kOSSettingsKeyAutoPrompt: false]
        
        // Replace 'YOUR_APP_ID' with your OneSignal App ID.
        //Nassab version : f0d1c6de-76e1-4353-ac2e-28c8e77e4edb
        //Sibapp Version: 2e88f03c-0769-4b2a-b48f-0a1c1b0a9384
        OneSignal.initWithLaunchOptions(launchOptions,
                                        appId: "f0d1c6de-76e1-4353-ac2e-28c8e77e4edb",
                                        handleNotificationAction: nil,
                                        settings: onesignalInitSettings)
        
        OneSignal.inFocusDisplayType = OSNotificationDisplayType.notification;
        
        // Recommend moving the below line to prompt for push after informing the user about
        //   how your app will use them.
        
        
        var playerId : String = ""
        if let x = OneSignal.getPermissionSubscriptionState().subscriptionStatus.userId {
            playerId = x
        }
        
        OneSignal.promptForPushNotifications(userResponse: { accepted in
            print("User accepted notifications: \(accepted)")
            if accepted{
                if let userId = OneSignal.getPermissionSubscriptionState().subscriptionStatus.userId{
                    playerId = userId
                    print("player id is: \(String(describing: userId))")
                }
            }
        })
        
        var buildVersion = 100
        
        if let version = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            buildVersion = Int(version)! 
        }
        
        let params = ["build_version" : buildVersion, "device_type" : "ios" , "udid" : UIDevice.current.identifierForVendor!.uuidString, "one_signal_id" : playerId, "bundle" : Bundle.main.bundleIdentifier!  ] as [String : Any]
        
        let request = RequestHandler(type: .handShake , requestURL: AppGlobal.HandShake, params: params, shouldShowError: false, retry: 1, sender: vc, waiting: false, force: false)
        
        request.sendRequest(completionHandler: {
            data, success, msg in
            
            if success {
                let result = data as! handShakeResult
                if result.force_update{
                    let dialog = DialougeView()
                    dialog.update(force: true, downloadURL: result.url, vc: vc)
                }else if result.suggest_update{
                    let dialog = DialougeView()
                    dialog.update(force: false, downloadURL: result.url, vc: vc)
                }
            }
            
        })
          
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        AppManager.sharedInstance().addAction(action: "App Closed", session: "", detail: "")
        AppManager.sharedInstance().sendActions()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        AppManager.sharedInstance().addAction(action: "App Launched", session: "", detail: "")
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        AppManager.sharedInstance().sendActions()
    }
    

    func logUser() {
        // TODO: Use the current user's information
        // You can call any combination of these three methods
//        Crashlytics.sharedInstance().setUserIdentifier(AppManager.sharedInstance().getUserInfo().username)
		
    }

}

