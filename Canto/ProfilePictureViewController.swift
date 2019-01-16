//
//  ProfilePictureViewController.swift
//  Canto
//
//  Created by WhoTan on 12/3/17.
//  Copyright © 2017 WhoTan. All rights reserved.
//

import UIKit
import Alamofire

class ProfilePictureViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var pictureButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    var retry = 3
    public var isFirstTime = true
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var doneButtonOutlet: UIButton!
	@IBOutlet weak var errorView: UIView!
	@IBOutlet weak var invalidInputView: UIView!
	
	override func viewWillAppear(_ animated: Bool) {
		imageView.sd_setImage(with: URL(string: AppManager.sharedInstance().userInfo.avatar.link), placeholderImage: UIImage(named: "userPH") )
		if (nameTF.text?.isEmpty)!{
			nameTF.text = AppManager.sharedInstance().userInfo.username
		}
	}
	
	
	override func viewDidLoad() {
		doneButtonOutlet.layer.cornerRadius = 5
		imageView.layer.cornerRadius = 10
		
		nameTF.addTarget(self, action: "textFieldDidChange:", for: UIControlEvents.editingChanged)
		nameTF.attributedPlaceholder = NSAttributedString(string: "نام کاربری",
																   attributes: [NSAttributedStringKey.foregroundColor: UIColor.lightGray])
		
		nameTF.delegate = self
		
		if isFirstTime{
			navigationItem.hidesBackButton = true
		}
		navigationController?.navigationBar.prefersLargeTitles = false
	}
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		next(doneButtonOutlet)
		return true
	}
	
	
	@objc func textFieldDidChange(_ textField: UITextField) {
		errorView.isHidden = true
		
		if textField.text != nil{
			if !AppManager.isValidUsernamePassword(str: textField.text!){
				invalidInputView.isHidden = false
				doneButtonOutlet.setBackgroundImage(nil, for: .normal)
				invalidInputView.shake()
			}else if (textField.text?.isEmpty)!{
				invalidInputView.isHidden = true
				doneButtonOutlet.setBackgroundImage(nil, for: .normal)
			}else{
				invalidInputView.isHidden = true
				doneButtonOutlet.isEnabled = true
				doneButtonOutlet.setBackgroundImage(UIImage(named: "button"), for: .normal)
			}
		}else{
			invalidInputView.isHidden = true
			doneButtonOutlet.setBackgroundImage(nil, for: .normal)
		}
	}
	
	
    @IBAction func photoTapped(_ sender: Any) {
		let avatarPicker = storyboard?.instantiateViewController(withIdentifier: "AvatarPickerViewController")
		navigationController?.pushViewController(avatarPicker!, animated: true)
    }
    

    
    @IBAction func next(_ sender: Any) {
		
		if AppManager.sharedInstance().userInfo.avatar.id == -1 {
			photoTapped(self)
			return
		}
		
		let params = ["username" : nameTF.text!, "avatar" : AppManager.sharedInstance().userInfo.avatar.id.description]
		
		let request = RequestHandler(type: .updateUserInfo, requestURL: AppGlobal.UserProfileURL + "/" , params: params, shouldShowError: true, timeOut: 8, retry: 0, sender: self, waiting: true, force: false)
		request.sendRequest(completionHandler: { data, success, msg in
			if success {
				let user = data as! user
				AppManager.sharedInstance().userInfo = user
				self.done()
			}else if msg != nil{
				self.errorView.isHidden = false
				self.errorView.shake()
			}
		})
		
	}
	
	
    func done(){
        
        if self.isFirstTime{
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "mainTabBar")
            self.present(vc!, animated: true, completion: nil)
//            self.present(vc, animated: true, completion: nil)
        }else{
            navigationController?.popViewController(animated: true)
        }
    }
    
    
}


//    func uploadPhoto(){
//
//        let dialouge = DialougeView()
//        dialouge.waitingBox(vc: self)
//        if self.retry > 0 {
//            self.retry = self.retry - 1
//            let file = UIImageJPEGRepresentation(self.imageView.image!, 0.75)
//            let imageName = self.imageURL?.lastPathComponent
//            print(imageName!)
//            let url = try! URLRequest(url: URL(string: AppGlobal.UploadProfilePicture)!, method: .post, headers: ["Content-Type": "multipart/form-data" , "USERTOKEN" : UserDefaults.standard.value(forKey: AppGlobal.Token) as! String])
//
//        Alamofire.upload(multipartFormData: { (multipartFormData) in
//            multipartFormData.append(file!, withName: "profile-image", fileName: imageName! , mimeType: "image/jpeg")
//        }, with: url, encodingCompletion: { encodingResult in
//
//            switch encodingResult {
//
//            case .success(let upload, _, _):
//                upload.response { response in
//                    let statCode = response.response?.statusCode
//                    if statCode == 201 {
//                        print("profile pic uploaded successfuly!")
//                        if self.isFirstTime{
//                            let vc = self.storyboard?.instantiateViewController(withIdentifier: "genreSelection")
//                            self.present(vc!, animated: true, completion: nil)
//                        }else{
//                            self.dismiss(animated: true, completion: nil)
//                        }
//                    }else{
//                        print("problem with uploading file, retrying... statusCode : \(String(describing: statCode))")
//                        self.uploadPhoto()
//                    }
//                }
//                break
//            case .failure(_):
//                print("problem with uploading file, retrying...")
//                self.uploadPhoto()
//                break
//            }
//        })
//
//        }else{
//            dialouge.hide()
//            print("Error occured while uploading photo, retries failed")
//            let retryDialogue = DialougeView()
//            retryDialogue.internetConnectionError(vc: self, completionHandler: { retry in
//                retryDialogue.hide()
//                if retry{
//                    self.retry = 3
//                    self.uploadPhoto()
//                }else{
//            if self.isFirstTime {
//                let vc = self.storyboard?.instantiateViewController(withIdentifier: "genreSelection")
//                self.present(vc!, animated: true, completion: nil)
//            }else{
//                self.dismiss(animated: true, completion: nil)
//            }
//        }
//        })
//        }
//    }

