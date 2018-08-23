//
//  ProfilePictureViewController.swift
//  Canto
//
//  Created by WhoTan on 12/3/17.
//  Copyright © 2017 WhoTan. All rights reserved.
//

import UIKit
import Alamofire

class ProfilePictureViewController: UIViewController {
    
    @IBOutlet weak var pictureButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    var imageURL : URL?
    var retry = 3
    public var isFirstTime = true
    var hasImage = false
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var lastNameTF: UITextField!
    @IBOutlet weak var purpleNextButton: UIButton!
    @IBOutlet weak var purpleNextImageView: UIImageView!
    @IBOutlet weak var doneButtonOutlet: UIButton!
    
    @IBOutlet weak var backButton: UIButton!
    override func viewWillLayoutSubviews() {
        self.imageView.layer.cornerRadius = 30
//        self.doneButtonOutlet.isHidden = isFirstTime
//        self.purpleNextButton.isHidden = !isFirstTime
//        self.purpleNextImageView.isHidden = !isFirstTime
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.backButton.isHidden = isFirstTime
        if !isFirstTime{
            imageView.image = AppManager.sharedInstance().userAvatar
            hasImage = true
            nameTF.text = AppManager.sharedInstance().getUserInfo().first_name
            lastNameTF.text = AppManager.sharedInstance().getUserInfo().last_name
        }
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        AppManager.sharedInstance().addAction(action: "View Did Disappear", session: "Profile Info", detail: "")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if isFirstTime{
            AppManager.sharedInstance().fetchHomeFeed(sender: self, force: false, completionHandler: {_ in })
            AppManager.sharedInstance().fetchBanners(sender: self, completionHandler: {_ in })
        }
        
        AppManager.sharedInstance().addAction(action: "View Did Appear", session: "Profile Info", detail: "")
    }
    
    
    @IBAction func photoTapped(_ sender: Any) {
        AppManager.sharedInstance().addAction(action: "Photo Tapped", session: "Profile Info", detail: "")
        CameraHandler.shared.showActionSheet(vc: self, sender : self.pictureButton)
        CameraHandler.shared.imagePickedBlock = { imageURL, image in
            self.imageView.image = image
            self.imageURL = imageURL
            self.hasImage = true
            let file = UIImageJPEGRepresentation(image, 1)
            UserDefaults.standard.setValue(file, forKey: "UserImage")
            AppManager.sharedInstance().updateUserPhoto()
            AppManager.sharedInstance().addAction(action: "Photo Selected", session: "Profile Info", detail: "")
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
    
    
    @IBAction func next(_ sender: Any) {
        
        
        if (nameTF.text?.isEmpty)!{
            nameTF.shake()
            AppManager.sharedInstance().addAction(action: "Next Tapped", session: "Profile Info", detail: "Error: Name field was empty")
        }else{
            let params = ["first_name" : nameTF.text , "last_name" : lastNameTF.text]
            let request = RequestHandler(type: .updateUserInfo, requestURL: AppGlobal.UserProfileURL + "/" , params: params, shouldShowError: true, timeOut: 8, retry: 1, sender: self, waiting: true, force: false)
            request.sendRequest(completionHandler: { data, success, msg in
                if success {
                    let user = data as! user
                    UserDefaults.standard.setValue(user.toJsonString(), forKey: AppGlobal.userInfoCache)
                    AppManager.sharedInstance().getUserInfo()
                    self.done()
                }
            })
        }
        
    }
    
    
    @IBAction func back(_ sender: Any) {
        AppManager.sharedInstance().addAction(action: "Back Tapped", session: "Profile Info", detail: "")
        self.dismiss(animated: true, completion: nil)
    }
    
    func done(){
        
        if self.isFirstTime{
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "genreSelection") as! GenreSelectionViewController
            vc.firstTime = true
            self.present(vc, animated: true, completion: nil)
        }else{
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    
}
