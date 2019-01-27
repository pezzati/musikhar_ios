//
//  LauncherViewController.swift
//  Canto
//
//  Created by Whotan on 1/25/19.
//  Copyright © 2019 WhoTan. All rights reserved.
//

import UIKit
import OneSignal

class LauncherViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
		
		
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
		
		var buildVersion = 0
		
		if let version = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
			buildVersion = Int(version)!
		}
		
		let params = ["build_version" : buildVersion, "device_type" : "ios" , "udid" : UIDevice.current.identifierForVendor!.uuidString, "one_signal_id" : playerId, "bundle" : Bundle.main.bundleIdentifier!  ] as [String : Any]
		
		let request = RequestHandler(type: .handShake , requestURL: AppGlobal.HandShake, params: params, shouldShowError: true, retry: 1, sender: self, waiting: true, force: true)
		
		request.sendRequest(completionHandler: {
			data, success, msg in
			
			if success {
				let result = data as! handShakeResult
				if result.force_update{
					let dialog = DialougeView()
					dialog.update(force: true, downloadURL: result.url, vc: self)
				}else if result.suggest_update{
					let dialog = DialougeView()
					dialog.update(force: false, downloadURL: result.url,validToken: result.is_token_valid , vc: self)
				}else{
					let nextVC = self.storyboard!.instantiateViewController(withIdentifier: result.is_token_valid ?  "mainTabBar" : "LoginMethod" )
					self.present(nextVC, animated: true, completion: nil)
				}
			}
			
		})
		
    }

}
