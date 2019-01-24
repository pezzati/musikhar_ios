//
//  LoginViewController.swift
//  Canto
//
//  Created by Whotan on 12/4/18.
//  Copyright © 2018 WhoTan. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate{
	
	override var prefersStatusBarHidden: Bool {
		return true
	}
	
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var tfBackgroundView: UIView!
	@IBOutlet weak var textField: UITextField!
	
	public var method : loginMethod = .phone

    override func viewDidLoad() {
        super.viewDidLoad()
		navigationController?.isNavigationBarHidden = false
		tfBackgroundView.clipsToBounds = true
		tfBackgroundView.layer.cornerRadius = 5
		textField.delegate = self
		navigationController?.navigationItem.title = "ورود"
		textField.addTarget(self, action: "textFieldDidChange:", for: UIControlEvents.editingChanged)
    }
	
	override func viewWillAppear(_ animated: Bool) {
		titleLabel.text = method == .phone ? "شماره موبایل خود را وارد کنید" : "آدرس ایمیل خود را وارد کنید"
		let placeHolderText = method == .phone ? "۰۹*********" : "me@canto-app.ir"
		textField.attributedPlaceholder = NSAttributedString(string: placeHolderText,
															 attributes: [NSAttributedStringKey.foregroundColor: UIColor.lightGray])
		textField.becomeFirstResponder()
	}
	
	@objc func textFieldDidChange(_ textField: UITextField) {
		if textField.text?.count == 11 && method == .phone{
			textFieldShouldReturn(textField)
		}
	}
	
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		
		let input = textField.text
		var params = ["mobile" : "" , "email" : ""]
		
		if method == .phone{
			if input!.englishDigits.characters.count != 11 || input!.englishDigits.prefix(2) != "09" {
				textField.shake()
				ShowMessage.message(title: "شماره همراه", message: "باید با ۰۹ شروع شود و ۱۱ شماره باشد.", vc: self)
				return false
			}
			params["mobile"] = input!.englishDigits
		}else{
			if !AppManager.isValidEmail(testStr: input!){
				textField.shake()
				ShowMessage.message(title: "ایمیل", message: "معتبر نیست.", vc: self)
				return false
			}
			params["email"] = input!
		}
		
		textField.resignFirstResponder()
		let dialog = DialougeView()
		dialog.waitingBox(vc: self)
		
		var signUpRequest : RequestHandler? = RequestHandler(type: .signUp , requestURL: AppGlobal.UserSignupURL, params: params, timeOut: 10, retry: 1, sender: self)
		signUpRequest?.sendRequest(completionHandler: { Data, Success, message in
			dialog.hide()
			if Success {
				
				let dialog = DialougeView()
				dialog.showUserAgreement(sender: self, completionHandler: {
					accepted in
					if accepted{
						AppManager.sharedInstance().addAction(action: "Agreed Agreement", session: "Signup", detail: "")
						let vc = self.storyboard?.instantiateViewController(withIdentifier: "SMSVerification") as? CodeVerificationViewController
						vc?.email = params["email"]!
						vc?.mobile = params["mobile"]!
						self.navigationController?.pushViewController(vc!, animated: true)
					}else{
						AppManager.sharedInstance().addAction(action: "Disagreed Agreement", session: "Signup", detail: "")
					}
				})
			}else if message != nil{
				ShowMessage.message(message: message!, vc: self)
			}else{
				dialog.internetConnectionError(vc: self, completionHandler: {
					retry in
					if retry{
						dialog.hide()
						self.textFieldShouldReturn(textField)
					}else{
						dialog.hide()
					}
				})
				if let err = message{
					print("error is : " + err)
				}else{
					print("request failed")
				}
			}
			signUpRequest = nil
		})
		return true
	}
	
}
