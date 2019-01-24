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
	
	@IBOutlet weak var playerView: UIView!
	@IBOutlet weak var timeLabel: UILabel!
	@IBOutlet weak var karaImageView: UIImageView!
	@IBOutlet weak var artistNameLbl: UILabel!
	@IBOutlet weak var karaNameLbl: UILabel!
	@IBOutlet weak var bottomShadowBG: UIView!
	@IBOutlet weak var topShadowBG: UIView!
	
	var post = userPost()
	var index = Int(0)
	var playerLayer : AVPlayerLayer? = nil
	var Player : AVPlayer? = nil
	var playerItem : AVPlayerItem? = nil
	var fileURL : URL!
	var timer : Timer? = nil
	
	override var prefersStatusBarHidden: Bool {
		return true
	}
	
	override func viewDidLoad() {
		
		self.post = AppManager.sharedInstance().getUserPostsList().posts[index]
		
		let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
		let pathArray = [dirPath, self.post.file.link]
		self.fileURL = NSURL.fileURL(withPathComponents: pathArray)
		
		self.playerView.clipsToBounds = true
		playerItem = AVPlayerItem(url: self.fileURL!)
		Player = AVPlayer(playerItem: playerItem)
		playerLayer = AVPlayerLayer(player: Player)
		playerLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
		playerLayer?.frame = playerView.bounds
		playerLayer?.masksToBounds = true
		playerView.layer.addSublayer(playerLayer!)
		
		karaImageView.layer.cornerRadius = 10
		
		
		self.timeLabel.text = "00:00"
		NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidPlayToEndTime), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
		
		self.timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(updateSlider) , userInfo: nil, repeats: true)
		
		let tap = UITapGestureRecognizer { (gesture:UIGestureRecognizer?) in
			self.Player?.isMuted.toggle()
		}
		playerView.addGestureRecognizer(tap!)
	}
	
	override func viewWillAppear(_ animated: Bool) {
		karaImageView.sd_setImage(with: URL(string: post.kara.cover_photo.link))
		karaNameLbl.text = post.kara.name
		artistNameLbl.text = post.kara.artist.name
	}
	
	@objc func updateSlider(){
		self.timeLabel.text = self.playerItem?.currentTime().durationText
	}
	
	override func viewDidAppear(_ animated: Bool) {
		Player?.play()
		
		do{
			try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback , with: .defaultToSpeaker)
			try AVAudioSession.sharedInstance().setActive(true)
		}catch{
			print(error)
		}
		
	}
	
	override func viewWillLayoutSubviews() {
		playerLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
		playerLayer?.frame = playerView.bounds
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		self.Player?.replaceCurrentItem(with: nil)
		NotificationCenter.default.removeObserver(self)
		if self.timer != nil {
			self.timer?.invalidate()
			self.timer = nil
		}
		self.playerItem = nil
		self.playerLayer = nil
		self.Player = nil
	}
	
	@objc func playerItemDidPlayToEndTime(){
		self.Player?.seek(to: kCMTimeZero)
		self.timeLabel.text = kCMTimeZero.durationText
		self.Player?.play()
	}
	
	
	
	func removePost() {
		
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
				dialog.hide()
				self.close(self)
				AppManager.sharedInstance().addAction(action: "Remove Tapped", session: "User Post", detail: self.post.kara.id.description)
				AppManager.sharedInstance().removeUserPost(index: self.index, fileURL: self.fileURL)
			}else{
				dialog.hide()
			}
		})
		
	}
	
	@IBAction func forward(_ sender: Any) {
		
		let nextTime = (Player?.currentTime().seconds)! + 10
		if nextTime < (playerItem?.asset.duration.seconds)!{
			Player?.seek(to: CMTime(seconds: nextTime, preferredTimescale: Player!.currentTime().timescale))
			self.timeLabel.text = nextTime.durationText
			self.Player?.play()
		}else{
			playerItemDidPlayToEndTime()
		}
		
	}
	
	@IBAction func backward(_ sender: Any) {
		let nextTime = (Player?.currentTime().seconds)! - 10
		if nextTime < (playerItem?.asset.duration.seconds)!{
			Player?.seek(to: CMTime(seconds: nextTime, preferredTimescale: Player!.currentTime().timescale))
			self.timeLabel.text = nextTime.durationText
			self.Player?.play()
		}else{
			playerItemDidPlayToEndTime()
		}
	}
	
	
	@IBAction func share(_ sender: Any) {
		
		DispatchQueue.main.async {
			
			
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
