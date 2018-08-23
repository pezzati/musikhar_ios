//
//  CameraHandler.swift
//  theappspace.com
//
//  Created by Dejan Atanasov on 26/06/2017.
//  Copyright © 2017 Dejan Atanasov. All rights reserved.
//
import Foundation
import UIKit


class CameraHandler: NSObject{
    static let shared = CameraHandler()
    
    fileprivate var currentVC: UIViewController!
    
    //MARK: Internal Properties
    var imagePickedBlock: ((URL, UIImage) -> Void)?
    
    func camera()
    {
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            let myPickerController = UIImagePickerController()
            myPickerController.delegate = self;
            myPickerController.sourceType = .camera
            currentVC.present(myPickerController, animated: true, completion: nil)
        }
        
    }
    
    func photoLibrary()
    {
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            let myPickerController = UIImagePickerController()
            myPickerController.delegate = self;
            myPickerController.sourceType = .photoLibrary
            currentVC.present(myPickerController, animated: true, completion: nil)
        }
        
    }
    
    func showActionSheet(vc: UIViewController, sender : UIView) {
        currentVC = vc
        self.photoLibrary()
//        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
//
//        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (alert:UIAlertAction!) -> Void in
//            self.camera()
//        }))
//
//        actionSheet.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { (alert:UIAlertAction!) -> Void in
//            self.photoLibrary()
//        }))
//
//        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
//
//        if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad ){
//            actionSheet.popoverPresentationController?.sourceView = sender
//        }
//
//        vc.present(actionSheet, animated: true, completion: nil)
    }
    
}


extension CameraHandler: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        currentVC.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let OriginalImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            if let imageURL = info[UIImagePickerControllerReferenceURL] as? URL{
                picker.dismiss(animated: true, completion: nil)
                self.imagePickedBlock?( imageURL, OriginalImage)
            }
        }else{
            print("Something went wrong")
        }
        
//        currentVC.dismiss(animated: true, completion: nil)
    }
    
}
