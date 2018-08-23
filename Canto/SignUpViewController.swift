//
//  SignUpViewController.swift
//  Canto
//
//  Created by WhoTan on 12/3/17.
//  Copyright © 2017 WhoTan. All rights reserved.
//

import UIKit
import GoogleSignIn

class SignUpViewController: UIViewController , GIDSignInUIDelegate, GIDSignInDelegate{

    @IBOutlet weak var header_Image: UIImageView!
    @IBOutlet weak var header_Top_Constraint: NSLayoutConstraint!
    @IBOutlet weak var lineXConstraint: NSLayoutConstraint!
    @IBOutlet weak var emailOrPhone: UITextField!
    @IBOutlet weak var emailOrPhone_View: UIView!
    @IBOutlet weak var singInButton: GIDSignInButton!
    
    var gestureRecognizer : UITapGestureRecognizer?
    var isTyping = false
    var byPhone = true
    
    override func viewDidLoad() {
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
        
            NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardNotification(notification:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
        lineXConstraint.constant = view.frame.width/4
        emailOrPhone.placeholder = "موبایل (۰۹)"
        emailOrPhone_View.round()
        gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(resignResponders))
        self.view.addGestureRecognizer(gestureRecognizer!)
        singInButton.style = .wide
        
        gestureRecognizer?.cancelsTouchesInView = false
        GIDSignIn.sharedInstance().signOut()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        AppManager.sharedInstance().addAction(action: "View Did Appear", session: "Signup", detail: "")
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        AppManager.sharedInstance().addAction(action: "View Did Disappear", session: "Signup", detail: "")
    }
    
    
    
    
    //MARK: - Actions
    @IBAction func emailTapped(_ sender: Any) {
        AppManager.sharedInstance().addAction(action: "Email Tapped", session: "Signup", detail: "")
        
        self.byPhone = false
        emailOrPhone.placeholder = "ایمیل"
        emailOrPhone.text = ""
        emailOrPhone_View.shake()
        lineXConstraint.constant = -view.frame.width / 4
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    @IBAction func mobileTapped(_ sender: Any) {
        AppManager.sharedInstance().addAction(action: "Mobile Tapped", session: "Signup", detail: "")
        self.byPhone = true
        emailOrPhone.placeholder = "موبایل (۰۹)"
        emailOrPhone.text = ""
        emailOrPhone_View.shake()
        lineXConstraint.constant = view.frame.width/4
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    
    @IBAction func nextTapped(_ sender: Any) {
        
        
        AppManager.sharedInstance().addAction(action: "Next Tapped", session: "Signup", detail: byPhone ? "Mobile" : "Email")
        
        if(!byPhone && !isValidEmail(testStr: (emailOrPhone?.text)!)){
            emailOrPhone_View.shake()
            ShowMessage.message(title: "ایمیل", message: "معتبر نیست.", vc: self)
        }else if(byPhone && (emailOrPhone?.text?.englishDigits.characters.count != 11 || (emailOrPhone?.text?.englishDigits.prefix(2) != "09" ) ) ){
            emailOrPhone_View.shake()
            ShowMessage.message(title: "شماره همراه", message: "باید با ۰۹ شروع شود و ۱۱ شماره باشد.", vc: self)
        }else{
            resignResponders()
            
            var params = ["mobile" : "" , "email" : ""]
            if self.byPhone{
                params["mobile"] = emailOrPhone.text?.englishDigits
            }else{
                params["email"] = emailOrPhone.text
            }

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
                            self.present(vc!, animated: true, completion: nil)
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
                            self.nextTapped(self)
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
        }
    }
    
    @objc func resignResponders(){
        emailOrPhone.resignFirstResponder()
    }
    
    //MARK: - Entry Validation
    func isValidUsernamePassword(str: String) -> Bool{
        let characterset = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-_.")
        if str.rangeOfCharacter(from: characterset.inverted) != nil {
            return false
        }else{
            return true
        }
    }
    
    func isValidEmail(testStr:String) -> Bool {
        // print("validate calendar: \(testStr)")
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    @objc func keyboardNotification(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            if (endFrame?.origin.y)! < UIScreen.main.bounds.size.height {
               header_Top_Constraint.constant = -100
                header_Image.alpha = 0.3
                UIView.animate(withDuration: 1.5, animations: {() -> Void in
                   self.view.layoutIfNeeded()
                    })
            } else {
                header_Top_Constraint.constant = 0
                header_Image.alpha = 1
                UIView.animate(withDuration: 1.5, animations: {() -> Void in
                   self.view.layoutIfNeeded()
                    })
            }
        }
    }
    
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
            
            AppManager.sharedInstance().addAction(action: "Sign in with google", session: "Signup", detail: "")
            
            let request = RequestHandler(type: .googleSignIn , requestURL: AppGlobal.GoogleSignIn , params: params, shouldShowError: true, timeOut: 10, retry: 1, sender: self, waiting: true, force: false)
            
            request.sendRequest(completionHandler: {
                data, success, message in
                if success{
                    let json = data as? [String:Any]
                    print(json!["token"] as! String )
                    UserDefaults.standard.set(json!["token"] as! String, forKey: AppGlobal.Token)
                    AppManager.sharedInstance().fetchHomeFeed(sender:(UIApplication.shared.keyWindow?.rootViewController)! , force: false, all: true, completionHandler: {_ in })
                    
                    if json!["new_user"] as! Bool {
                        
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "PhotoPicker")
                        UIApplication.topViewController()?.present(vc!, animated: true, completion: nil)
                    }else{
                       
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "mainTabBar")
                        UIApplication.topViewController()?.present(vc!, animated: true, completion: nil)
                        
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
