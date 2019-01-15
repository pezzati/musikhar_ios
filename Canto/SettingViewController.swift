//
//  SettingViewController.swift
//  Canto
//
//  Created by WhoTan on 6/7/18.
//  Copyright © 2018 WhoTan. All rights reserved.
//

import UIKit

class SettingViewController: UIViewController {

    
    override func viewDidLoad() {
		navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        AppManager.sharedInstance().addAction(action: "View Did Appear", session: "Setting", detail: "")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        AppManager.sharedInstance().addAction(action: "View Did Disappear", session: "Setting", detail: "")
    }

    @IBAction func editProfile(_ sender: Any) {
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "PhotoPicker") as? ProfilePictureViewController
        vc?.isFirstTime = false
        self.present(vc!, animated: true, completion: nil)
    }
    
    
    @IBAction func bugReport(_ sender: Any) {
		
        AppManager.sharedInstance().addAction(action: "Bug Report Tapped", session: "Setting", detail: "")
    }
    
    
    @IBAction func adviseOrComplain(_ sender: Any) {
		
        AppManager.sharedInstance().addAction(action: "Advise Or Complain Tapped", session: "Setting", detail: "")
    }
    
    @IBAction func askForSong(_ sender: Any) {
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
	
}
