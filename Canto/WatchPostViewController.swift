//
//  WatchPostViewController.swift
//  Canto
//
//  Created by WhoTan on 1/30/18.
//  Copyright © 2018 WhoTan. All rights reserved.
//

import UIKit
import AVFoundation
import SDWebImage

class WatchPostViewController: UIViewController {

    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var playerView: UIView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var playImageView: UIImageView!
    @IBOutlet weak var timeSlider: UISlider!
    
    var post = userPost()
    var index = Int(0)
    var playerLayer : AVPlayerLayer? = nil
    var Player : AVPlayer? = nil
    var playerItem : AVPlayerItem? = nil
    var isMovingSlider = false
    var isPlaying = true
    var fileURL : URL!
    var timer : Timer? = nil
    
    
    override func viewDidLoad() {
        
//        if let jsonString = UserDefaults.standard.value(forKey: AppGlobal.UserPostsList) as? String{
//            let previous = userPostsList(json: jsonString)
//            self.post = previous.posts[index]
//        }else{ self.close(self) }
        
        self.post = AppManager.sharedInstance().getUserPostsList().posts[index]
        
        let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let pathArray = [dirPath, self.post.file.link]
        self.fileURL = NSURL.fileURL(withPathComponents: pathArray)
        
        self.playerView.isHidden = true
        self.playerView.clipsToBounds = true
        self.playerView.layer.cornerRadius = 15
        self.timeLabel.layer.cornerRadius = 5
        playerItem = AVPlayerItem(url: self.fileURL!)
        Player = AVPlayer(playerItem: playerItem)
        playerLayer = AVPlayerLayer(player: Player)
        playerLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        playerLayer?.frame = playerView.bounds
        playerLayer?.masksToBounds = true
        playerView.layer.addSublayer(playerLayer!)
        playerView.addSubview(timeLabel)
        
        self.timeLabel.text = "00:00"
        NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidPlayToEndTime), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
        
        self.timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(updateSlider) , userInfo: nil, repeats: true)
//        self.Player?.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main , using: {
//            elapsedTime in
//
//            if !self.isMovingSlider{
//                self.timeLabel.text = elapsedTime.durationText
//                self.timeSlider.setValue(Float(Double((self.playerItem?.currentTime().seconds)!)/Double((self.playerItem?.duration.seconds)!)) , animated: true)
//            }
//        })
        headerView.headerViewCornerRounding()
    }
    

    
    
    @objc func updateSlider(){
        
        if !self.isMovingSlider{
            self.timeLabel.text = self.playerItem?.currentTime().durationText
            self.timeSlider.setValue(Float(Double((self.playerItem?.currentTime().seconds)!)/Double((self.playerItem?.duration.seconds)!)) , animated: true)
        }else{
            if self.timeSlider.value == 0.0{
                self.sliderTouchDown(self)
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let userInfo = AppManager.sharedInstance().getUserInfo()
        self.userImageView.image = AppManager.sharedInstance().userAvatar
        self.userNameLabel.text = userInfo.first_name 
        self.playerView.isHidden = false
        self.headerView.alpha = 1
        Player?.play()
        
        do{
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback , with: .defaultToSpeaker)
            try AVAudioSession.sharedInstance().setActive(true)
        }catch{
            print(error)
        }
        
        AppManager.sharedInstance().addAction(action: "View Did Appear", session: "User Post", detail: "")
    }
    
    override func viewWillLayoutSubviews() {
        playerView.layer.cornerRadius = 15
        playerLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        playerLayer?.frame = playerView.bounds
        userImageView.layer.cornerRadius = userImageView.frame.width/2
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.headerView.alpha = 0
        NotificationCenter.default.removeObserver(self)
        if self.timer != nil {
            self.timer?.invalidate()
            self.timer = nil
        }
        self.playerItem = nil
        self.playerLayer = nil
        self.Player = nil
        AppManager.sharedInstance().addAction(action: "View Did Disappear", session: "User Post", detail: "")
    }
    
    @objc func playerItemDidPlayToEndTime(){
        self.Player?.seek(to: kCMTimeZero)
        self.timeLabel.text = kCMTimeZero.durationText
        self.timeSlider.setValue(0.0, animated: false)
        self.Player?.play()
    }
    
    
    @IBAction func sliderTouchDown(_ sender: Any) {
        self.isMovingSlider = true
        Player?.pause()
    }
    
    @IBAction func sliderTouchUpInside(_ sender: Any) {
        let seekTime = CMTime(seconds: Double(self.timeSlider.value)*(self.Player?.currentItem?.duration.seconds)! , preferredTimescale: (Player?.currentTime().timescale)! )
        
        playerItem?.seek(to: seekTime, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero)
        Player?.play()
        self.isPlaying = true
        self.playImageView.image = UIImage(named: "post_pause")
        self.isMovingSlider = false
    }
    
    
    @IBAction func play_pause(_ sender: Any) {
        if self.isPlaying{
            self.Player?.pause()
            self.playImageView.image = UIImage(named: "post_play")
            self.isPlaying = false
            AppManager.sharedInstance().addAction(action: "Pause Tapped", session: "User Post", detail: "")
        }else{
            self.Player?.play()
            self.isPlaying = true
            self.playImageView.image = UIImage(named: "post_pause")
            AppManager.sharedInstance().addAction(action: "Play Tapped", session: "User Post", detail: "")
        }
    }
    @IBAction func removePost(_ sender: Any) {
        AppManager.sharedInstance().addAction(action: "Remove Tapped", session: "User Post", detail: "")
//        if let jsonString = UserDefaults.standard.value(forKey: AppGlobal.UserPostsList) as? String{
//            let posts = userPostsList(json: jsonString)
//            posts.posts.remove(at: self.index)
//             UserDefaults.standard.set(posts.toJsonString(), forKey: AppGlobal.UserPostsList)
//            do{ try? FileManager.default.removeItem(at: self.fileURL) }
//        }
//        self.close(self)
        
        let dialog = DialougeView()
        dialog.shouldRemove(vc: self, completionHandler: {
            sure in
            if sure{
                AppManager.sharedInstance().removeUserPost(index: self.index, fileURL: self.fileURL)
                dialog.hide()
                self.close(self)
            }else{
                dialog.hide()
            }
        })
        
    }
    
    @IBAction func share(_ sender: Any) {
        
        DispatchQueue.main.async {
            
            self.Player?.pause()
            self.playImageView.image = UIImage(named: "post_play")
            self.isPlaying = false
            
        AppManager.sharedInstance().addAction(action: "Share Tapped", session: "User Post", detail: "")
        let objectsToShare = [self.fileURL!] as [Any]
        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        activityVC.setValue("Video", forKey: "subject")
        
        //New Excluded Activities Code
        activityVC.excludedActivityTypes = [UIActivityType.airDrop, UIActivityType.addToReadingList, UIActivityType.assignToContact, UIActivityType.copyToPasteboard, UIActivityType.mail, UIActivityType.message, UIActivityType.postToTencentWeibo, UIActivityType.postToVimeo, UIActivityType.postToWeibo, UIActivityType.print ]
        
        if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad ){
            activityVC.popoverPresentationController?.sourceView = sender as? UIView
                }
        
        self.present(activityVC, animated: true, completion: nil)
        }
    }
    
    @IBAction func close(_ sender: Any) {
        AppManager.sharedInstance().addAction(action: "Close Tapped", session: "User Post", detail: "")
        Player?.pause()
        self.dismiss(animated: true, completion: nil)
    }
    
}
