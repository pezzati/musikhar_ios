//
//  DialougeView.swift
//  Canto
//
//  Created by WhoTan on 12/30/17.
//  Copyright © 2017 WhoTan. All rights reserved.
//

import UIKit
import Lottie

class DialougeView {

    var dialougeView : UIView!
    var shadowView : UIView!
    let scrWidth = UIScreen.main.bounds.width
    let scrHeight = UIScreen.main.bounds.height

    func showBackgroundView(vc: UIViewController){
        self.shadowView = UIView(frame: CGRect(x: -scrWidth, y: -scrHeight, width: scrWidth*3, height: scrHeight*3))
        self.shadowView.backgroundColor = UIColor.white
        self.shadowView.alpha = 0.7
        vc.view.addSubview(shadowView)
    }
    
    func waitingBox(vc: UIViewController){
        showBackgroundView(vc: vc)
        self.dialougeView = UIView(frame: CGRect(x: scrWidth/2 - 60 , y: scrHeight/2 - 60, width: 120, height: 120))
        self.dialougeView.layer.cornerRadius = 15
        self.dialougeView.clipsToBounds = true
//        self.shadowDialogue()
        let loadingView = LOTAnimationView(name: "loading")
        loadingView.backgroundColor = UIColor.purple
        loadingView.frame = CGRect(x: 0, y: 0, width: 120, height: 120)
        loadingView.loopAnimation = true
        loadingView.play()
        
        self.dialougeView.addSubview(loadingView)
        vc.view.addSubview(dialougeView!)
    }
    
    func internetConnectionError(vc: UIViewController, completionHandler: @escaping (Bool) -> ()){
        
        showBackgroundView(vc: vc)
        self.dialougeView = UIView(frame: CGRect(x: scrWidth/2 - 150 , y: scrHeight/2 - 130, width: 300, height: 260))
        self.dialougeView.backgroundColor = UIColor.white
        self.dialougeView.layer.cornerRadius = 15
        self.dialougeView.clipsToBounds = true
        self.shadowDialogue()
        
        let image = UIImageView(frame: CGRect(x: 0, y: 30, width: 300, height: 70))
        image.image = UIImage(named: "dinasure")
        image.contentMode = .scaleAspectFit
        self.dialougeView.addSubview(image)
        
        let title = UILabel(frame: CGRect(x: 0, y: 120, width: 300, height: 20))
        title.text = "قطعی اینترنت"
        title.adjustsFontSizeToFitWidth = true
        title.textAlignment = .center
        title.textColor = UIColor.black
        self.dialougeView.addSubview(title)
        
        let subTitle = UILabel(frame: CGRect(x: 0, y: 150, width: 300, height: 40))
        subTitle.text = "لطفا از اتصال خود به اینترنت اطمینان حاصل فرمایید"
        subTitle.textColor = UIColor.black
        subTitle.numberOfLines = 1
        subTitle.font = UIFont.systemFont(ofSize: 14)
        subTitle.textAlignment = .center
        self.dialougeView.addSubview(subTitle)
        
        
        let tryButton = UILabel(frame: CGRect(x: 0 , y: 0, width: 180, height: 40))
        tryButton.text = "باشه"
        tryButton.textColor = UIColor.white
        tryButton.font = UIFont.systemFont(ofSize: 14)
        tryButton.numberOfLines = 1
        tryButton.textAlignment = .center
        let tryButtonView = UIImageView(frame: CGRect(x: 60, y: 200, width: 180 , height: 40))
        tryButtonView.image = UIImage(named: "button3")
        tryButtonView.layer.shadowColor = UIColor.lightGray.cgColor
        tryButtonView.layer.shadowOffset = CGSize(width: 0, height: 2)
        tryButtonView.layer.shadowRadius = 5
        tryButtonView.layer.shadowOpacity = 0.3
        tryButtonView.contentMode = .scaleAspectFill
        tryButtonView.isUserInteractionEnabled = true
        tryButtonView.addSubview(tryButton)
        self.dialougeView.addSubview(tryButtonView)
        
        let tap = UITapGestureRecognizer { (gesture:UIGestureRecognizer?) in
            completionHandler(true)
        }
        tryButtonView.addGestureRecognizer(tap!)
        
        let cancelTap =  UITapGestureRecognizer { (gesture:UIGestureRecognizer?) in
            completionHandler(false)
        }
        self.shadowView.addGestureRecognizer(cancelTap!)
        self.shadowView.isUserInteractionEnabled = true
        
        vc.view.addSubview(dialougeView!)
    }
    
    func hide(){
        
        self.dialougeView.removeFromSuperview()
        self.shadowView.removeFromSuperview()
    }
    
    func chooseKaraType(kara: karaoke, sender: UIViewController) {
        
        if !AppManager.sharedInstance().getUserInfo().is_premium && kara.is_premium {
            let vc = sender.storyboard?.instantiateViewController(withIdentifier: "PurchaseTableViewController") as! PurchaseTableViewController
            sender.present(vc, animated: true, completion: nil)
            return
        }else{
        
            AppManager.sharedInstance().getContent(url: kara.link, sender: sender, completionHandler: { success, post in
                
                if success{
                    
                    
                        let _kara = post as! karaoke
                
                        self.showBackgroundView(vc: sender)
                        self.dialougeView = UIView(frame: CGRect(x: self.scrWidth/2 - 150 , y: self.scrHeight/2 - 145, width: 300, height: 290))
                        self.dialougeView.backgroundColor = UIColor.white
                        self.dialougeView.layer.cornerRadius = 15
                        self.dialougeView.clipsToBounds = true
                        self.shadowDialogue()
                    
                        let image = UIImageView(frame: CGRect(x: 0, y: 30, width: 300, height: 70))
                        image.image = UIImage(named: "fileType")
                        image.contentMode = .scaleAspectFit
                        self.dialougeView.addSubview(image)
                    
                        let title = UILabel(frame: CGRect(x: 0, y: 120, width: 300, height: 20))
                        title.textColor = UIColor.blue
                        title.text = "انتخاب موزیک"
                        title.textAlignment = .center
                        self.dialougeView.addSubview(title)
                    
                        let subTitle = UILabel(frame: CGRect(x: 0 , y: 150, width:300 , height: 20))
                        subTitle.textColor = UIColor.darkGray
                        subTitle.text = "موسیقی مورد نظر را در کدام حالت میخواهید؟"
                        subTitle.textAlignment = .center
                        subTitle.numberOfLines = 1
                        subTitle.font = UIFont.systemFont(ofSize: 14)
                        self.dialougeView.addSubview(subTitle)
                    
                    
                        let originalLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 180, height: 40))
                        originalLabel.text = "با صدای خواننده"
                        originalLabel.textColor = UIColor.white
                        originalLabel.textAlignment = .center
                        originalLabel.font = UIFont.systemFont(ofSize: 12)
                    
                        let originalView = UIImageView(frame: CGRect(x: 60 , y: 180, width: 180 , height: 40))
                        originalView.image = UIImage(named: "button3")
                        originalView.contentMode = .scaleAspectFill
                        originalView.isUserInteractionEnabled = true
                        originalView.addSubview(originalLabel)
                        self.dialougeView.addSubview(originalView)
                    
                        let originalTap =  UITapGestureRecognizer { (gesture:UIGestureRecognizer?) in
                            AppManager.sharedInstance().addAction(action: "Tapped Original File", session: "", detail: kara.id.description)
                            let vc = sender.storyboard?.instantiateViewController(withIdentifier: "Record") as! Record_VC
                            vc.post = _kara
                            vc.original = true
                            sender.present(vc, animated: true, completion: nil)
                            self.hide()
                            self.hide()
                        }
                        originalView.addGestureRecognizer(originalTap!)
                        originalView.isUserInteractionEnabled = _kara.content.original_file_url != ""
                        if _kara.content.original_file_url == ""{
                            originalView.alpha = 0.5
                        }
                    
                    
                        let karaLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 180, height: 40))
                        karaLabel.text = "بدون صدای خواننده"
                        karaLabel.textColor = UIColor.white
                        karaLabel.textAlignment = .center
                        karaLabel.font = UIFont.systemFont(ofSize: 12)
                        let karaView = UIImageView(frame: CGRect(x: 60 , y: 230 , width: 180 , height: 40))
                        karaView.image = UIImage(named: "button3")
                        karaView.isUserInteractionEnabled = true
                        karaView.contentMode = .scaleAspectFill
                        karaView.addSubview(karaLabel)
                        self.dialougeView.addSubview(karaView)
                    
                        let karaTap =  UITapGestureRecognizer { (gesture:UIGestureRecognizer?) in
                            AppManager.sharedInstance().addAction(action: "Tapped Karaoke File", session: "" , detail: _kara.id.description)
                            let vc = sender.storyboard?.instantiateViewController(withIdentifier: "Record") as! Record_VC
                            vc.post = _kara
                            vc.original = false
                            sender.present(vc, animated: true, completion: nil)
                            self.hide()
                            self.hide()
                        }
                        karaView.addGestureRecognizer(karaTap!)
                        karaView.isUserInteractionEnabled = _kara.content.karaoke_file_url != ""
                        if _kara.content.karaoke_file_url == ""{
                            karaView.alpha = 0.5
                        }
                    
                        let cancelTap =  UITapGestureRecognizer { (gesture:UIGestureRecognizer?) in
                            self.hide()
                        }
                    
                        self.shadowView.addGestureRecognizer(cancelTap!)
                        self.shadowView.isUserInteractionEnabled = true
                    
                            sender.view.addSubview(self.dialougeView!)
                }
            })
            
        }
    }
    
    
    func videoSaved(sender: UIViewController){
        
        showBackgroundView(vc: sender)
        self.dialougeView = UIView(frame: CGRect(x: scrWidth/2 - 150 , y: scrHeight/2 - 130, width: 300, height: 260))
        self.dialougeView.backgroundColor = UIColor.white
        self.dialougeView.layer.cornerRadius = 15
        self.dialougeView.clipsToBounds = true
        self.shadowDialogue()
        
        let image = UIImageView(frame: CGRect(x: 0, y: 30, width: 300, height: 70))
        image.image = UIImage(named: "photos")
        image.contentMode = .scaleAspectFit
        self.dialougeView.addSubview(image)
        
        let title = UILabel(frame: CGRect(x: 0, y: 120, width: 300, height: 20))
        title.text = "ذخیره شد"
        title.adjustsFontSizeToFitWidth = true
        title.textAlignment = .center
        title.textColor = UIColor.black
        self.dialougeView.addSubview(title)
        
        let subTitle = UILabel(frame: CGRect(x: 50, y: 150, width: 200, height: 40))
        subTitle.text = "موزیک ویدیو شما در گالری و صفحه کاربری شما ذخیره شد"
        subTitle.textColor = UIColor.black
        subTitle.numberOfLines = 2
        subTitle.font = UIFont.systemFont(ofSize: 12)
        subTitle.textAlignment = .center
        self.dialougeView.addSubview(subTitle)
        
        
        let tryButton = UILabel(frame: CGRect(x: 0 , y: 0, width: 180, height: 40))
        tryButton.text = "باشه"
        tryButton.textColor = UIColor.white
        tryButton.font = UIFont.systemFont(ofSize: 14)
        tryButton.numberOfLines = 1
        tryButton.textAlignment = .center
        let tryButtonView = UIImageView(frame: CGRect(x: 60, y: 200, width: 180 , height: 40))
        tryButtonView.image = UIImage(named: "button3")
        tryButtonView.layer.shadowColor = UIColor.lightGray.cgColor
        tryButtonView.layer.shadowOffset = CGSize(width: 0, height: 2)
        tryButtonView.layer.shadowRadius = 5
        tryButtonView.layer.shadowOpacity = 0.3
        tryButtonView.contentMode = .scaleAspectFill
        tryButtonView.isUserInteractionEnabled = true
        tryButtonView.addSubview(tryButton)
        self.dialougeView.addSubview(tryButtonView)
        
        let tap = UITapGestureRecognizer { (gesture:UIGestureRecognizer?) in
            sender.dismiss(animated: true, completion: nil)
            self.hide()
        }
        tryButtonView.addGestureRecognizer(tap!)
        
        let cancelTap =  UITapGestureRecognizer { (gesture:UIGestureRecognizer?) in
            self.hide()
            sender.dismiss(animated: true, completion: nil)
        }
//        self.shadowView.addGestureRecognizer(cancelTap!)
//        self.shadowView.isUserInteractionEnabled = true
        
        sender.view.addSubview(dialougeView!)
    }
    
    func plugHeadphones(sender: UIViewController){
        
        showBackgroundView(vc: sender)
        self.dialougeView = UIView(frame: CGRect(x: scrWidth/2 - 150 , y: scrHeight/2 - 130, width: 300, height: 260))
        self.dialougeView.backgroundColor = UIColor.white
        self.dialougeView.layer.cornerRadius = 15
        self.dialougeView.clipsToBounds = true
        self.shadowDialogue()
        
        let image = UIImageView(frame: CGRect(x: 0, y: 30, width: 300, height: 60))
        image.image = UIImage(named: "headphone")
        image.contentMode = .scaleAspectFit
        self.dialougeView.addSubview(image)
        
//        let title = UILabel(frame: CGRect(x: 0, y: 120, width: 300, height: 20))
//        title.text = "هشدار!"
//        title.adjustsFontSizeToFitWidth = true
//        title.textAlignment = .center
//        title.textColor = UIColor.black
//        self.dialougeView.addSubview(title)
        
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 5
        style.alignment = .center
        let attributes = [NSAttributedStringKey.paragraphStyle : style]
        
        let subTitle = UILabel(frame: CGRect(x: 50, y: 100, width: 200, height: 80))
//        subTitle.text = "برای داشتن بهترین تجربه از هدفون استفاده کنید"
        subTitle.textColor = UIColor.black
        subTitle.numberOfLines = 0
        subTitle.font = UIFont.systemFont(ofSize: 17)
        subTitle.textAlignment = .center
        subTitle.attributedText = NSAttributedString(string: "برای داشتن بهترین تجربه از هدفون استفاده کنید", attributes: attributes )
        self.dialougeView.addSubview(subTitle)
        
        
        let tryButton = UILabel(frame: CGRect(x: 0 , y: 0, width: 180, height: 40))
        tryButton.text = "باشه"
        tryButton.textColor = UIColor.white
        tryButton.font = UIFont.systemFont(ofSize: 14)
        tryButton.numberOfLines = 1
        tryButton.textAlignment = .center
        let tryButtonView = UIImageView(frame: CGRect(x: 60, y: 200, width: 180 , height: 40))
        tryButtonView.image = UIImage(named: "button3")
        tryButtonView.layer.shadowColor = UIColor.lightGray.cgColor
        tryButtonView.layer.shadowOffset = CGSize(width: 0, height: 2)
        tryButtonView.layer.shadowRadius = 5
        tryButtonView.layer.shadowOpacity = 0.3
        tryButtonView.contentMode = .scaleAspectFill
        tryButtonView.isUserInteractionEnabled = true
        tryButtonView.addSubview(tryButton)
        self.dialougeView.addSubview(tryButtonView)
        
        let tap = UITapGestureRecognizer { (gesture:UIGestureRecognizer?) in
//            sender.dismiss(animated: true, completion: nil)
            self.hide()
        }
        tryButtonView.addGestureRecognizer(tap!)
        
        let cancelTap =  UITapGestureRecognizer { (gesture:UIGestureRecognizer?) in
            self.hide()
//            sender.dismiss(animated: true, completion: nil)
        }
//        self.shadowView.addGestureRecognizer(cancelTap!)
//        self.shadowView.isUserInteractionEnabled = true
        
        sender.view.addSubview(dialougeView!)
    }
    
    func showUserAgreement(sender: UIViewController, shouldAsk : Bool = true , completionHandler: @escaping (Bool) -> ()){
    
        showBackgroundView(vc: sender)
        self.dialougeView = UIView(frame: CGRect(x: scrWidth/2 - 150 , y: scrHeight/2 - 215, width: 300, height: 430))
        self.dialougeView.backgroundColor = UIColor.white
        self.shadowDialogue()

        let titleLabel = UILabel(frame: CGRect(x: 0, y: 25, width: 270, height: 20))
        titleLabel.textAlignment = .right
        titleLabel.text = "قوانین و شرایط"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        self.dialougeView.addSubview(titleLabel)
        
        let textView = UITextView(frame: CGRect(x: 30, y: 75, width: 240, height: 275))
        textView.isEditable = false
        textView.textAlignment = .right
        let text = "لطفاً متن زیر را به دقت بخوانید و آگاه باشید که با ثبت نام و استفاده از این اپلیکشین، با این موارد موافقت کرده‌اید:\n\n-کاربران حق استفاده از نام و هویت دیگران را ندارند.\n\n-هر گونه توهین و تمسخر مقدسات و اشخاص حقیقی و حقوقی ممنوع است.\n\n-استفاده از کلمات و عبارات رکیک ممنوع است.\n\n-توهین به مقدسات اقلیت‌های دینی و مذهبی و تحریک اذهان عمومی ممنوع است.\n\nشما با ثبت نام و استفاده از این اپلیکیشن با موارد فوق موافقت کرده‌اید و در صورت مشاهده هر گونه تخلف، اکانت کاربری توقیف خواهد شد."
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 4
        style.alignment = .right
        let attributes = [NSAttributedStringKey.paragraphStyle : style]
        textView.attributedText = NSAttributedString(string: text, attributes: attributes)
        textView.font = UIFont.boldSystemFont(ofSize: 13)
        self.dialougeView.addSubview(textView)
        
        let agreeButton = UILabel(frame: CGRect(x: 300 - 30 - 90, y: 370, width: 90, height: 30))
        agreeButton.text = "قبول دارم"
        agreeButton.font = UIFont.boldSystemFont(ofSize: 15)
        agreeButton.textColor = UIColor.white
        agreeButton.backgroundColor = UIColor(red: 20/255, green: 122/255, blue: 243/255, alpha: 1)
        agreeButton.textAlignment = .center
        agreeButton.layer.cornerRadius = 15
        agreeButton.clipsToBounds = true
        agreeButton.isUserInteractionEnabled = true
        let agreeTap =  UITapGestureRecognizer { (gesture:UIGestureRecognizer?) in
            self.hide()
            completionHandler(true)
        }
        agreeButton.addGestureRecognizer(agreeTap!)
        dialougeView.addSubview(agreeButton)
        
        
        let disagreeButton = UILabel(frame: CGRect(x: 30, y: 370, width: 90, height: 30))
        disagreeButton.text = "قبول ندارم"
        disagreeButton.font = UIFont.boldSystemFont(ofSize: 15)
        disagreeButton.textColor = UIColor.black
        disagreeButton.textAlignment = .center
        disagreeButton.isUserInteractionEnabled = true
        let disagreeTap =  UITapGestureRecognizer { (gesture:UIGestureRecognizer?) in
            self.hide()
            completionHandler(false)
        }
        
        let cancelTap =  UITapGestureRecognizer { (gesture:UIGestureRecognizer?) in
            self.hide()
            completionHandler(false)
        }
        
        if shouldAsk{
        self.shadowView.addGestureRecognizer(cancelTap!)
        self.shadowView.isUserInteractionEnabled = true
        
        disagreeButton.addGestureRecognizer(disagreeTap!)
        dialougeView.addSubview(disagreeButton)
        }
        
    
        sender.view.addSubview(dialougeView!)
    }
    
    
    
    
    
    
    func update(force: Bool,downloadURL: String, vc: UIViewController){
        
        showBackgroundView(vc: vc)
        self.dialougeView = UIView(frame: CGRect(x: scrWidth/2 - 150 , y: scrHeight/2 - 130, width: 300, height: 260))
        self.dialougeView.backgroundColor = UIColor.white
        self.dialougeView.layer.cornerRadius = 15
        self.dialougeView.clipsToBounds = true
        self.shadowDialogue()
        
        let image = UIImageView(frame: CGRect(x: 0, y: 30, width: 300, height: 70))
        image.image = UIImage(named: "update")
        if force{ image.image = UIImage(named: "forceUpdate") }
        image.contentMode = .scaleAspectFit
        self.dialougeView.addSubview(image)
        
        let title = UILabel(frame: CGRect(x: 0, y: 120, width: 300, height: 20))
        title.text = "به روز رسانی"
        if force{ title.text = "به روز رسانی اجباری"}
        title.adjustsFontSizeToFitWidth = true
        title.textAlignment = .center
        title.textColor = UIColor.black
        self.dialougeView.addSubview(title)
        
        let subTitle = UILabel(frame: CGRect(x: 0, y: 150, width: 300, height: 40))
        subTitle.text = "نسخه جدید اپلیکیشن کانتو را میتوانید دریافت کنید"
        if force{ subTitle.text = "متاسفانه از این نسخه دیگر پشتیبانی نمیشود" }
        subTitle.textColor = UIColor.black
        subTitle.numberOfLines = 2
        subTitle.font = UIFont.systemFont(ofSize: 13)
        subTitle.textAlignment = .center
        self.dialougeView.addSubview(subTitle)
        
        
        let tryButton = UILabel(frame: CGRect(x: 0 , y: 0, width: 180, height: 40))
        tryButton.text = "دریافت نسخه جدید"
        tryButton.textColor = UIColor.white
        tryButton.font = UIFont.systemFont(ofSize: 14)
        tryButton.numberOfLines = 1
        tryButton.textAlignment = .center
        let tryButtonView = UIImageView(frame: CGRect(x: 60, y: 200, width: 180 , height: 40))
        tryButtonView.image = UIImage(named: "button3")
        tryButtonView.layer.shadowColor = UIColor.lightGray.cgColor
        tryButtonView.layer.shadowOffset = CGSize(width: 0, height: 2)
        tryButtonView.layer.shadowRadius = 5
        tryButtonView.layer.shadowOpacity = 0.3
        tryButtonView.contentMode = .scaleAspectFill
        tryButtonView.isUserInteractionEnabled = true
        tryButtonView.addSubview(tryButton)
        self.dialougeView.addSubview(tryButtonView)
        
        let tap = UITapGestureRecognizer { (gesture:UIGestureRecognizer?) in
            UIApplication.shared.openURL(URL(string: downloadURL)!)
        }
        tryButtonView.addGestureRecognizer(tap!)
        
        let cancelTap =  UITapGestureRecognizer { (gesture:UIGestureRecognizer?) in
            if !force{ self.hide() }
        }
        self.shadowView.addGestureRecognizer(cancelTap!)
        self.shadowView.isUserInteractionEnabled = true
        
        vc.view.addSubview(dialougeView!)
    }
    
    
    
    func shouldRender(vc: UIViewController, completionHandler: @escaping (Bool) -> ()){
        
        showBackgroundView(vc: vc)
        self.dialougeView = UIView(frame: CGRect(x: scrWidth/2 - 150 , y: scrHeight/2 - 155, width: 300, height: 310))
        self.dialougeView.backgroundColor = UIColor.white
        self.dialougeView.layer.cornerRadius = 15
        self.dialougeView.clipsToBounds = true
        self.shadowDialogue()
        
        let image = UIImageView(frame: CGRect(x: 0, y: 30, width: 300, height: 70))
        image.image = UIImage(named: "process")
        
        image.contentMode = .scaleAspectFit
        self.dialougeView.addSubview(image)
        
        let title = UILabel(frame: CGRect(x: 0, y: 120, width: 300, height: 20))
        title.text = "ذخیره سازی"
        
        title.adjustsFontSizeToFitWidth = true
        title.textAlignment = .center
        title.textColor = UIColor.black
        self.dialougeView.addSubview(title)
        
        let subTitle = UILabel(frame: CGRect(x: 0, y: 150, width: 300, height: 40))
        subTitle.text = "آیا مایل به ذخیره کردن هستید؟"
        subTitle.textColor = UIColor.black
        subTitle.numberOfLines = 2
        subTitle.font = UIFont.systemFont(ofSize: 13)
        subTitle.textAlignment = .center
        self.dialougeView.addSubview(subTitle)
        
        
        let tryButton = UILabel(frame: CGRect(x: 0 , y: 0, width: 180, height: 40))
        tryButton.text = "ذخیره"
        tryButton.textColor = UIColor.white
        tryButton.font = UIFont.systemFont(ofSize: 14)
        tryButton.numberOfLines = 1
        tryButton.textAlignment = .center
        let tryButtonView = UIImageView(frame: CGRect(x: 60, y: 200, width: 180 , height: 40))
        tryButtonView.image = UIImage(named: "button3")
        tryButtonView.layer.shadowColor = UIColor.lightGray.cgColor
        tryButtonView.layer.shadowOffset = CGSize(width: 0, height: 2)
        tryButtonView.layer.shadowRadius = 5
        tryButtonView.layer.shadowOpacity = 0.3
        tryButtonView.contentMode = .scaleAspectFill
        tryButtonView.isUserInteractionEnabled = true
        tryButtonView.addSubview(tryButton)
        self.dialougeView.addSubview(tryButtonView)
        
        
        let cancelButton = UILabel(frame: CGRect(x: 0 , y: 0, width: 180, height: 40))
        cancelButton.text = "حذف"
        cancelButton.textColor = UIColor.white
        cancelButton.font = UIFont.systemFont(ofSize: 14)
        cancelButton.numberOfLines = 1
        cancelButton.textAlignment = .center
        let cancelButtonView = UIImageView(frame: CGRect(x: 60, y: 250, width: 180 , height: 40))
        cancelButtonView.image = UIImage(named: "button3")
        cancelButtonView.layer.shadowColor = UIColor.lightGray.cgColor
        cancelButtonView.layer.shadowOffset = CGSize(width: 0, height: 2)
        cancelButtonView.layer.shadowRadius = 5
        cancelButtonView.layer.shadowOpacity = 0.3
        cancelButtonView.contentMode = .scaleAspectFill
        cancelButtonView.isUserInteractionEnabled = true
        cancelButtonView.addSubview(cancelButton)
        self.dialougeView.addSubview(cancelButtonView)
        
        
        
        
        let tap = UITapGestureRecognizer { (gesture:UIGestureRecognizer?) in
            completionHandler(true)
        }
        tryButtonView.addGestureRecognizer(tap!)
        
        let cancelTap =  UITapGestureRecognizer { (gesture:UIGestureRecognizer?) in
        completionHandler(false)
        }
        cancelButtonView.addGestureRecognizer(cancelTap!)
        
        vc.view.addSubview(dialougeView!)
        
        
        
    }
    
    
    func shouldRemove(vc: UIViewController, completionHandler: @escaping (Bool) -> ()){
        
        showBackgroundView(vc: vc)
        self.dialougeView = UIView(frame: CGRect(x: scrWidth/2 - 150 , y: scrHeight/2 - 110, width: 300, height: 220))
        self.dialougeView.backgroundColor = UIColor.white
        self.dialougeView.layer.cornerRadius = 15
        self.dialougeView.clipsToBounds = true
        self.shadowDialogue()
        
      
        
        let title = UILabel(frame: CGRect(x: 0, y: 30, width: 300, height: 20))
        title.text = "حذف ویدیو"
        
        title.adjustsFontSizeToFitWidth = true
        title.textAlignment = .center
        title.textColor = UIColor.black
        self.dialougeView.addSubview(title)
        
        let subTitle = UILabel(frame: CGRect(x: 0, y: 60, width: 300, height: 40))
        subTitle.text = "آیا از حذف ویدیو اطمینان دارید؟"
        subTitle.textColor = UIColor.black
        subTitle.numberOfLines = 2
        subTitle.font = UIFont.systemFont(ofSize: 13)
        subTitle.textAlignment = .center
        self.dialougeView.addSubview(subTitle)
        
        
        let tryButton = UILabel(frame: CGRect(x: 0 , y: 0, width: 180, height: 40))
        tryButton.text = "بله"
        tryButton.textColor = UIColor.white
        tryButton.font = UIFont.systemFont(ofSize: 14)
        tryButton.numberOfLines = 1
        tryButton.textAlignment = .center
        let tryButtonView = UIImageView(frame: CGRect(x: 60, y: 110, width: 180 , height: 40))
        tryButtonView.image = UIImage(named: "button3")
        tryButtonView.layer.shadowColor = UIColor.lightGray.cgColor
        tryButtonView.layer.shadowOffset = CGSize(width: 0, height: 2)
        tryButtonView.layer.shadowRadius = 5
        tryButtonView.layer.shadowOpacity = 0.3
        tryButtonView.contentMode = .scaleAspectFill
        tryButtonView.isUserInteractionEnabled = true
        tryButtonView.addSubview(tryButton)
        self.dialougeView.addSubview(tryButtonView)
        
        
        let cancelButton = UILabel(frame: CGRect(x: 0 , y: 0, width: 180, height: 40))
        cancelButton.text = "خیر" 
        cancelButton.textColor = UIColor.white
        cancelButton.font = UIFont.systemFont(ofSize: 14)
        cancelButton.numberOfLines = 1
        cancelButton.textAlignment = .center
        let cancelButtonView = UIImageView(frame: CGRect(x: 60, y: 160, width: 180 , height: 40))
        cancelButtonView.image = UIImage(named: "button3")
        cancelButtonView.layer.shadowColor = UIColor.lightGray.cgColor
        cancelButtonView.layer.shadowOffset = CGSize(width: 0, height: 2)
        cancelButtonView.layer.shadowRadius = 5
        cancelButtonView.layer.shadowOpacity = 0.3
        cancelButtonView.contentMode = .scaleAspectFill
        cancelButtonView.isUserInteractionEnabled = true
        cancelButtonView.addSubview(cancelButton)
        self.dialougeView.addSubview(cancelButtonView)
        
        let tap = UITapGestureRecognizer { (gesture:UIGestureRecognizer?) in
            completionHandler(true)
        }
        tryButtonView.addGestureRecognizer(tap!)
        
        let cancelTap =  UITapGestureRecognizer { (gesture:UIGestureRecognizer?) in
            completionHandler(false)
        }
        cancelButtonView.addGestureRecognizer(cancelTap!)
        
        vc.view.addSubview(dialougeView!)
    }
    
    func shadowDialogue(){
        self.dialougeView.clipsToBounds = false
        self.dialougeView.layer.cornerRadius = 15
        self.dialougeView.layer.shadowColor = UIColor.gray.cgColor
        self.dialougeView.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.dialougeView.layer.shadowRadius = 5
        self.dialougeView.layer.shadowOpacity = 0.7
    }
    
}
