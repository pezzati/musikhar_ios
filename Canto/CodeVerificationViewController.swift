//
//  CodeVerificationViewController.swift
//  Canto
//
//  Created by WhoTan on 12/3/17.
//  Copyright © 2017 WhoTan. All rights reserved.
//

import UIKit

class CodeVerificationViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var code: UITextField!
    @IBOutlet weak var code_View: UIView!
    var gestureRecognizer : UITapGestureRecognizer?
	@IBOutlet weak var titleLbl: UILabel!
	@IBOutlet weak var descLbl: UILabel!
	@IBOutlet weak var addressLbl: UILabel!
	
    var email = ""
    var mobile = ""
    
    override func viewDidLoad() {
        code_View.round()
		code.delegate = self
		code.attributedPlaceholder = NSAttributedString(string: "1234", attributes: [NSAttributedStringKey.foregroundColor: UIColor.lightGray, NSAttributedString.Key(rawValue: NSAttributedString.Key.kern.rawValue) : 30.0])
		AppManager.sharedInstance().addAction(action: "View Did Appear", session: "Code Verification", detail: "")
		titleLbl.text = mobile.count == 0 ? "تایید آدرس ایمیل" : "تایید شماره همراه"
		descLbl.text = mobile.count == 0 ? "کد تایید برای آدرس ایمیل زیر ارسال شد" : "کد تایید برای شماره موبایل زیر ارسال شد"
		code.defaultTextAttributes.updateValue(30.0,forKey: NSAttributedString.Key.kern.rawValue)
		addressLbl.text = mobile + email
		code.becomeFirstResponder()
		navigationController?.title = "تایید کد"
		navigationController?.navigationItem.title = "تایید کد"
    }

	
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		nextTapped(textField)
		return false
	}
	
    
    override func viewDidDisappear(_ animated: Bool) {
        AppManager.sharedInstance().addAction(action: "View Did Disappear", session: "Code Verification", detail: "")
    }
    
    @IBAction func nextTapped(_ sender: Any) {
        
        AppManager.sharedInstance().addAction(action: "Next Tapped", session: "Code Verification", detail: "")
        
        if code.text?.englishDigits.characters.count != 4 {
            ShowMessage.message(message: "کد تایید ۴ رقم است", vc: self)
            code_View.shake()
            AppManager.sharedInstance().addAction(action: "Wrong Code", session: "Code Verification", detail: "Not 4 Digits")
        }else{
            let params = ["code" : code.text!.englishDigits, "mobile" : self.mobile , "email" : self.email, "udid" : UIDevice.current.identifierForVendor!.uuidString, "bundle" : Bundle.main.bundleIdentifier! ]  as [String : Any]
            
            let request = RequestHandler(type: .codeVerification , requestURL: AppGlobal.SubmitVerificationCode, params: params, shouldShowError: true, timeOut: 10, retry: 1, sender: self, waiting: true, force: false)
            
            request.sendRequest(completionHandler: {
                data, success, message in
                if success{
                    let json = data as? [String:Any]
                    print(json!["token"] as! String )
                    UserDefaults.standard.set(json!["token"] as! String, forKey: AppGlobal.Token)
                    
//                    AppManager.sharedInstance().fetchBanners(sender: self, force: false, completionHandler: {_ in })
//                    AppManager.sharedInstance().fetchHomeFeed(sender: self, force: false, all: true, completionHandler: {_ in })
//                    AppManager.sharedInstance().fetchUserInfo(sender: self, force: false, completionHandler: {_ in })
					
                    
                    if json!["new_user"] as! Bool {
                        AppManager.sharedInstance().addAction(action: "Code verified", session: "Code Verification", detail: "Signup")
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "PhotoPicker")
                        self.present(vc!, animated: true, completion: nil)
                    }else{
                        AppManager.sharedInstance().addAction(action: "Code verified", session: "Code Verification", detail: "Login")
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "mainTabBar")
                        self.present(vc!, animated: true, completion: nil)
                    }
                    
                }else{
                    if message != nil {
                        ShowMessage.message(message: message!, vc: self)
                        AppManager.sharedInstance().addAction(action: "Wrong Code", session: "Code Verification", detail: message!)
                    }
                }
                
            })
        }
    }
    
    @IBAction func didNotRecieve(_ sender: Any) {
        
        AppManager.sharedInstance().addAction(action: "Resend code", session: "Code Verification", detail: "")
        
        let dialouge = DialougeView()
        dialouge.waitingBox(vc: self)
        API_Handler.resendVerificationCode(mobile: self.mobile, email: self.email ,completionHandler: {result, status in
            dialouge.hide()
            switch status{
            case .InternetConnection:
                print("check internet connection")
                let retryDialogue = DialougeView()
                retryDialogue.internetConnectionError(vc: self, completionHandler: { retry in
                    retryDialogue.hide()
                    if retry{
                        self.didNotRecieve(self)
                    }
                })
                break
            case .ServerError:
                print("There was an error" + result)
                ShowMessage.message(title: "خطا", message: result, vc: self)
                break
            case .Success:
                dialouge.hide()
                break
            default:
                dialouge.hide()
                break
//                let vc = self.storyboard?.instantiateViewController(withIdentifier: "mainTabBar")
//                self.present(vc!, animated: true, completion: nil)
            }} )
    }
	
    
}
