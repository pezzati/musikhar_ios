//
//  ShowMessage.swift
//  NoheKhan
//
//  Created by WhoTan on 8/31/17.
//  Copyright © 2017 WhoTan. All rights reserved.
//

import UIKit

class ShowMessage: NSObject {

    private static var sharedShowMessage: ShowMessage = {
        let showMessage = ShowMessage()
        return showMessage
    }()
    
    class func shared() -> ShowMessage{
        return sharedShowMessage
    }
    
    public static func message(message: String, vc: UIViewController){
        let alert = UIAlertController(title: "", message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "باشه", style: UIAlertActionStyle.default, handler: nil))
        vc.present(alert, animated: true, completion: nil)

    }
    
    public static func message(title: String, message: String, vc: UIViewController){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "باشه", style: UIAlertActionStyle.default, handler: nil))
        vc.present(alert, animated: true, completion: nil)
    }
    
    
    
    
}
