//
//  CodeVerificationViewController.swift
//  Canto
//
//  Created by WhoTan on 12/3/17.
//  Copyright © 2017 WhoTan. All rights reserved.
//

import UIKit

class CodeVerificationViewController: UIViewController {

    @IBOutlet weak var numLabel: UILabel!
    @IBOutlet weak var code: UITextField!
    @IBOutlet weak var code_View: UIView!
    var gestureRecognizer : UITapGestureRecognizer?
    var email = ""
    var mobile = ""
    
    override func viewDidLoad() {
        code_View.round()
        gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(resignResponders))
        self.view.addGestureRecognizer(gestureRecognizer!)
        let text = "کد تایید برای " +  email + mobile + "  " + "ارسال شد"
        
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 3
        style.alignment = .center
        let attributes = [NSAttributedStringKey.paragraphStyle : style]
        numLabel.attributedText = NSAttributedString(string: text, attributes: attributes)
        AppManager.sharedInstance().addAction(action: "View Did Appear", session: "Code Verification", detail: "")
    }
    
    @objc func resignResponders(){
        code.resignFirstResponder()
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
            resignResponders()
            let params = ["code" : code.text?.englishDigits , "mobile" : self.mobile , "email" : self.email ]
            
            let request = RequestHandler(type: .codeVerification , requestURL: AppGlobal.SubmitVerificationCode, params: params, shouldShowError: true, timeOut: 10, retry: 1, sender: self, waiting: true, force: false)
            
            request.sendRequest(completionHandler: {
                data, success, message in
                if success{
                    let json = data as? [String:Any]
                    print(json!["token"] as! String )
                    UserDefaults.standard.set(json!["token"] as! String, forKey: AppGlobal.Token)
                    
                    AppManager.sharedInstance().fetchBanners(sender: self, force: false, completionHandler: {_ in })
                    AppManager.sharedInstance().fetchHomeFeed(sender: self, force: false, all: true, completionHandler: {_ in })
                    AppManager.sharedInstance().fetchUserInfo(sender: self, force: false, completionHandler: {_ in })
                    
                    
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
    
    
    @IBAction func close(_ sender: Any) {
        AppManager.sharedInstance().addAction(action: "Back Tapped", session: "Code Verification", detail: "")
        self.dismiss(animated: true, completion: nil)
    
    }
    
}
