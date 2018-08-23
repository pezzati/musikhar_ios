//
//  SettingViewController.swift
//  Canto
//
//  Created by WhoTan on 6/7/18.
//  Copyright © 2018 WhoTan. All rights reserved.
//

import UIKit

class SettingViewController: UIViewController {

    
    @IBOutlet weak var headerView: UIView!
    
    @IBOutlet weak var formTitle: UILabel!
    @IBOutlet weak var formInput: UITextField!
    @IBOutlet weak var formView: UIView!
    @IBOutlet weak var backgroundLayer: UIView!
    var currentUserAction = ""
    
    override func viewDidLoad() {
        self.headerView.headerViewCornerRounding()
        self.formView.layer.cornerRadius = 35
        self.formView.layer.shadowColor = UIColor.gray.cgColor
        self.formView.layer.shadowRadius = 5
        self.formView.layer.shadowOpacity = 0.7
    }
    
    override func viewDidAppear(_ animated: Bool) {
         self.headerView.alpha = 1
        AppManager.sharedInstance().addAction(action: "View Did Appear", session: "Setting", detail: "")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.headerView.alpha = 0
        AppManager.sharedInstance().addAction(action: "View Did Disappear", session: "Setting", detail: "")
    }

    @IBAction func editProfile(_ sender: Any) {
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "PhotoPicker") as? ProfilePictureViewController
        vc?.isFirstTime = false
        self.present(vc!, animated: true, completion: nil)
    }
    
    
    @IBAction func bugReport(_ sender: Any) {
        
        self.currentUserAction = "Bug Report"
        self.formTitle.text = "گزارش اشکال"
        self.backgroundLayer.isHidden = false
        self.formView.isHidden = false
        self.formInput.becomeFirstResponder()
        AppManager.sharedInstance().addAction(action: "Bug Report Tapped", session: "Setting", detail: "")
    }
    
    
    @IBAction func adviseOrComplain(_ sender: Any) {
        
        self.currentUserAction = "Advise Or Complain"
        self.formTitle.text = "پیشنهاد یا انتقاد"
        self.backgroundLayer.isHidden = false
        self.formView.isHidden = false
        self.formInput.becomeFirstResponder()
        AppManager.sharedInstance().addAction(action: "Advise Or Complain Tapped", session: "Setting", detail: "")
    }
    
    @IBAction func askForSong(_ sender: Any) {
        self.currentUserAction = "Ask For Song"
        self.formTitle.text = "درخواست آهنگ"
        self.backgroundLayer.isHidden = false
        self.formView.isHidden = false
        self.formInput.becomeFirstResponder()
        AppManager.sharedInstance().addAction(action: "Ask For Song Tapped", session: "Setting", detail: "")
    }
    
    @IBAction func contactUs(_ sender: Any) {
        AppManager.sharedInstance().addAction(action: "Instagram Tapped", session: "Setting", detail: "")
        UIApplication.shared.openURL( URL(string: "http://instagram.com/canto_app" )!)
    }
    
    @IBAction func cantoWebsite(_ sender: Any) {
        AppManager.sharedInstance().addAction(action: "Website Tapped", session: "Setting", detail: "")
         UIApplication.shared.openURL( URL(string: "http://canto-app.ir" )!)
    }
    
    
    @IBAction func rules(_ sender: Any) {
        
        let dialog = DialougeView()
        dialog.showUserAgreement(sender: self, shouldAsk: false, completionHandler: {_ in })
        AppManager.sharedInstance().addAction(action: "Rules Tapped", session: "Setting", detail: "")

    }
    
    
    @IBAction func sendAction(_ sender: Any) {
        
        AppManager.sharedInstance().addAction(action: self.currentUserAction, session: "Setting", detail: self.formInput.text ?? "")
        self.backgroundLayer.isHidden = true
        self.formView.isHidden = true
        self.formInput.resignFirstResponder()
        self.formInput.text = ""
    }
    
    
    @IBAction func cancel(_ sender: Any) {
        self.backgroundLayer.isHidden = true
        self.formView.isHidden = true
        self.formInput.resignFirstResponder()
        self.formInput.text = ""
        AppManager.sharedInstance().addAction(action: "Canceled Report", session: "Setting", detail: self.currentUserAction)
        
    }
    
    
    
    @IBAction func close(_ sender: Any) {
        AppManager.sharedInstance().addAction(action: "Close Tapped", session: "Setting", detail: "")
        self.dismiss(animated: true, completion: nil)
    }
    
}
