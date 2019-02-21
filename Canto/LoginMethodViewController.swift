//
//  LoginMethodViewController.swift
//  Canto
//
//  Created by Whotan on 12/4/18.
//  Copyright © 2018 WhoTan. All rights reserved.
//

import UIKit
import GoogleSignIn

class LoginMethodViewController: UIViewController {

	@IBOutlet weak var emailButton: UIButton!
	@IBOutlet weak var phoneButton: UIButton!
	@IBOutlet weak var gmailButton: GIDSignInButton!
	
	override var prefersStatusBarHidden: Bool {
		return true
	}
	
	
	override func viewDidLoad() {
        super.viewDidLoad()
		
		phoneButton.layer.borderColor = UIColor(red: 58/255, green: 204/255, blue: 225/255, alpha: 1.0).cgColor
		phoneButton.layer.borderWidth = 1
		phoneButton.layer.cornerRadius = 12
		emailButton.layer.borderColor = UIColor(red: 245/255, green: 76/255, blue: 148/255, alpha: 1.0).cgColor
		emailButton.layer.borderWidth = 1
		emailButton.layer.cornerRadius = 12
		gmailButton.layer.cornerRadius = 12
		gmailButton.colorScheme = .dark
		let subv = UIView()
		subv.backgroundColor = UIColor.red
		subv.frame = gmailButton.bounds
		gmailButton.didAddSubview(subv)
		gmailButton.style = .wide
		GIDSignIn.sharedInstance().uiDelegate = self
		GIDSignIn.sharedInstance().delegate = self
		GIDSignIn.sharedInstance().signOut()
		
		
    }
	
	override func viewWillAppear(_ animated: Bool) {
		navigationController?.isNavigationBarHidden = true
	}

	@IBAction func phoneTapped(_ sender: Any) {
		AppManager.sharedInstance().addAction(action: "Signup", session: "phone", detail: "")
		let vc = storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginViewController
		vc.method = .phone
		navigationController?.pushViewController(vc, animated: true)
	}
	
	@IBAction func emailTapped(_ sender: Any) {
		AppManager.sharedInstance().addAction(action: "Signup", session: "email", detail: "")
		let vc = storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginViewController
		vc.method = .email
		navigationController?.pushViewController(vc, animated: true)
	}
	
}


extension LoginMethodViewController: GIDSignInUIDelegate, GIDSignInDelegate{
	
	
	func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
		
		if let error = error {
			print("\(error.localizedDescription)")
		} else {
			// Perform any operations on signed in user here.
			//            let userId = user.userID                  // For client-side use only!
			let idToken = user.authentication.idToken // Safe to send to the server
			//            let fullName = user.profile.name
			//            let givenName = user.profile.givenName
			//            let familyName = user.profile.familyName
			//            let email = user.profile.email
			// ...
			
			let params = ["token" : idToken! ]
			
			AppManager.sharedInstance().addAction(action: "Signup", session: "Google", detail: "")
			
			let request = RequestHandler(type: .googleSignIn , requestURL: AppGlobal.GoogleSignIn , params: params, shouldShowError: true, timeOut: 10, retry: 1, sender: self, waiting: true, force: false)
			
			request.sendRequest(completionHandler: {
				data, success, message in
				if success{
					let json = data as? [String:Any]
					print(json!["token"] as! String )
					UserDefaults.standard.set(json!["token"] as! String, forKey: AppGlobal.Token)
//					AppManager.sharedInstance().fetchHomeFeed(sender:(UIApplication.shared.keyWindow?.rootViewController)! , force: false, all: true, completionHandler: {_ in })
					
					if json!["new_user"] as! Bool {
						
						let vc = self.storyboard?.instantiateViewController(withIdentifier: "PhotoPicker")
						self.navigationController?.pushViewController(vc!, animated: true)
					}else{
						
						let vc = self.storyboard?.instantiateViewController(withIdentifier: "mainTabBar")
//						UIApplication.topViewController()?.present(vc!, animated: true, completion: nil)
						self.navigationController?.pushViewController(vc!, animated: true)
						
					}
					
				}else{
					if message != nil {
						ShowMessage.message(message: message!, vc: self)
					}
				}
				
			})
			
		}
	}
	
	func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!,
			  withError error: Error!) {
		// Perform any operations when the user disconnects from app here.
		// ...
		
		
	}
	
	func sign(_ signIn: GIDSignIn!, present viewController: UIViewController!) {
		print("presenting")
	}
	
	func sign(inWillDispatch signIn: GIDSignIn!, error: Error!) {
		guard error == nil else {
			
			print("Error while trying to redirect : \(error)")
			return
		}
		
		//        if signIn.currentUser != nil{
		//            self.sign(signIn, didSignInFor: signIn.currentUser, withError: error)
		//        }
		print("Successful Redirection")
	}
	
	func sign(_ signIn: GIDSignIn!, dismiss viewController: UIViewController!) {
		print("dismissing")
	}
}
