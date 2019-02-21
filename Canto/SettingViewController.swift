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
	
    @IBAction func bugReport(_ sender: Any) {
		 UIApplication.shared.openURL( URL(string: "http://t.me/cantoapp" )!)
    }
    
    
	
    
    @IBAction func askForSong(_ sender: Any) {

    }
	
	@IBAction func inviteFriends(_ sender: Any) {
		let objectsToShare = [ URL(string : "http://canto-app.ir")] as [Any]
		let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
		
		if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad ){
			activityVC.popoverPresentationController?.sourceView = sender as! UIView
		}
		self.present(activityVC, animated: true, completion: nil)
	}
	
    @IBAction func contactUs(_ sender: Any) {
        UIApplication.shared.openURL( URL(string: "http://instagram.com/canto_app" )!)
    }
    
    @IBAction func cantoWebsite(_ sender: Any) {
         UIApplication.shared.openURL( URL(string: "http://canto-app.ir" )!)
    }
    
    
    @IBAction func rules(_ sender: Any) {
        
        let dialog = DialougeView()
        dialog.showUserAgreement(sender: self, shouldAsk: false, completionHandler: {_ in })
    }
	
}
