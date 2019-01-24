//
//  EditVC.swift
//  Canto
//
//  Created by Whotan on 11/14/18.
//  Copyright © 2018 WhoTan. All rights reserved.
//

import UIKit
import GPUImage
import Photos
import AVFoundation

class EditVC: UIViewController {
	
	@IBOutlet weak var videoView: GPUImageView!
	
	public var mode : Modes!
	var movie : GPUImageMovie!
	var playerItem: AVPlayerItem!
	var mainPlayer: AVPlayer!
	var audioPlayer: AVPlayer!
	var audioPlayerItem: AVPlayerItem!
	var post: karaoke!
	var mixer: AudioMixer!
	let waitingView = DialougeView()
	
	@IBOutlet weak var mixerBoxView: UIView!
	
	@IBOutlet weak var mixerBoxSuperView: UIVisualEffectView!
	@IBOutlet weak var actionsSeparatorView: UIView!
	@IBOutlet weak var saveWidthConstraint: NSLayoutConstraint!
	@IBOutlet weak var mixWidthConstraint: NSLayoutConstraint!
	
	
	
	@IBOutlet weak var effect0IV: UIImageView!
	@IBOutlet weak var effect1IV: UIImageView!
	@IBOutlet weak var effect2IV: UIImageView!
	@IBOutlet weak var effect3IV: UIImageView!
	@IBOutlet weak var effect4IV: UIImageView!
	
	@IBOutlet weak var playbackWHSlider: WHSlider!
	@IBOutlet weak var micWHSlider: WHSlider!
	
	@IBOutlet weak var mixPanelHeightConstraint: NSLayoutConstraint!
	
	
	override var prefersStatusBarHidden: Bool {
		return true
	}
	
	override func viewDidLoad() {
		let tap = UITapGestureRecognizer { (gesture:UIGestureRecognizer?) in
			self.playerItemDidPlayToEndTime()
		}
		
		videoView.addGestureRecognizer(tap!)
	}
	
	override func viewWillAppear(_ animated: Bool) {
		loadVideo()
		loadAudio()
		mixWidthConstraint.constant = 0
		saveWidthConstraint.constant = view.bounds.width
		actionsSeparatorView.isHidden = true
		
		if mode == Modes.singing{
			setupSliders()
			setupEffectTaps()
			mixerBoxView.layer.cornerRadius = 15
			mixerBoxSuperView.layer.cornerRadius = 15
			
			mixWidthConstraint.constant = view.bounds.width/2
			saveWidthConstraint.constant = view.bounds.width/2
			actionsSeparatorView.isHidden = false
		}
		
	}
	
	override func viewDidAppear(_ animated: Bool) {
		mainPlayer.play()
		
		if mode == .singing{
			mixer.seekTo(time: 0)
			mixer.play()
		}else{
			audioPlayer.play()
		}
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		if mode == .singing{
			if mixer != nil{
				mixer.pause()
				NotificationCenter.default.removeObserver(mixer)
				mixer = nil
			}
		}else{
			audioPlayer.pause()
		}
		mainPlayer.pause()
		NotificationCenter.default.removeObserver(self)
	}
	
	func loadVideo(){
		playerItem = AVPlayerItem(url: AppManager.videoURL())
		mainPlayer = AVPlayer(playerItem: playerItem)
		movie = GPUImageMovie(playerItem: playerItem)
		movie.addTarget(videoView)
		movie.startProcessing()
		NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidPlayToEndTime), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
	}
	
	func loadAudio(){
		if mode == .singing{
			mixer = AudioMixer(recordedFileURL: AppManager.voiceURL(), karaFileURL: AppManager.karaURL())
			mixer.setNotification()
			mixer.seekTo(time: 0.0)
			mixer.setVoiceVol(vol: 0.5)
			mixer.setPlaybackVol(vol: 0.5)
		}else{
			audioPlayerItem = AVPlayerItem(url: AppManager.karaURL())
			audioPlayer = AVPlayer(playerItem: audioPlayerItem)
			do{
				try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback , with: .defaultToSpeaker)
				try AVAudioSession.sharedInstance().setActive(true)
			}catch{
				print(error)
			}
		}
	}
	
	func setupSliders(){
		playbackWHSlider.delegate = self
		micWHSlider.delegate = self
		
		playbackWHSlider.setup(of: .playback)
		micWHSlider.setup(of: .micVolume)
	}
	
	func disableEffects(){
		effect0IV.isHighlighted = false
		effect1IV.isHighlighted = false
		effect2IV.isHighlighted = false
		effect3IV.isHighlighted = false
		effect4IV.isHighlighted = false
	}
	
	func setupEffectTaps(){
		
		let effect0Tap = UITapGestureRecognizer { (gesture:UIGestureRecognizer?) in
			self.disableEffects()
			self.effect0IV.isHighlighted = true
			self.mixer.setEffect(effect: .none )
			self.playerItemDidPlayToEndTime()
		}
		effect0IV.addGestureRecognizer(effect0Tap!)
		
		let effect1Tap = UITapGestureRecognizer { (gesture:UIGestureRecognizer?) in
			self.disableEffects()
			self.effect1IV.isHighlighted = true
			self.mixer.setEffect(effect: .reverb )
			self.playerItemDidPlayToEndTime()
		}
		effect1IV.addGestureRecognizer(effect1Tap!)
		
		let effect2Tap = UITapGestureRecognizer { (gesture:UIGestureRecognizer?) in
			self.disableEffects()
			self.effect2IV.isHighlighted = true
			self.mixer.setEffect(effect: .multiline )
			self.playerItemDidPlayToEndTime()
		}
		effect2IV.addGestureRecognizer(effect2Tap!)
		
		let effect3Tap = UITapGestureRecognizer { (gesture:UIGestureRecognizer?) in
			self.disableEffects()
			self.effect3IV.isHighlighted = true
			self.mixer.setEffect(effect: .helium )
			self.playerItemDidPlayToEndTime()
		}
		effect3IV.addGestureRecognizer(effect3Tap!)
		
		let effect4Tap = UITapGestureRecognizer { (gesture:UIGestureRecognizer?) in
			self.disableEffects()
			self.effect4IV.isHighlighted = true
			self.mixer.setEffect(effect: .grunge )
			self.playerItemDidPlayToEndTime()
		}
		effect4IV.addGestureRecognizer(effect4Tap!)
		
		self.effect0IV.isHighlighted = true
	}
	
	
	@IBAction func mixerTapped(_ sender: Any) {
		self.mixPanelHeightConstraint.constant = self.mixPanelHeightConstraint.constant == 0 ? 330 : 0
		UIView.animate(withDuration: 1.5){
			self.view.layoutSubviews()
		}
	}
	
	
	@IBAction func saveTapped(_ sender: Any) {
		pause()
		waitingView.waitingBox(vc: self)
		
		if mode == .singing{
			mixer.render(url: AppManager.mixedAudioURL())
		}
		
		
		saveVideo()
	}
	
	@IBAction func closeTapped(_ sender: Any) {
		navigationController?.popToRootViewController(animated: true)
	}
	
	func pause(){
		mainPlayer.pause()
		if mode == .singing{
			mixer.pause()
		}else{
			audioPlayer.pause()
		}
		
	}
	
	@objc func playerItemDidPlayToEndTime(){
		mainPlayer.seek(to: kCMTimeZero)
		mainPlayer.play()
		if mode == .singing{
			mixer.seekTo(time: 0)
			mixer.play()
		}else{
			audioPlayer.seek(to: kCMTimeZero)
			audioPlayer.play()
		}
	}
	
	func saveVideo(){
		
		let finalURL = AppManager.finalOutputURL()
		MediaHelper.mixAudioVideo(audio: mode == .dubsmash ? AppManager.karaURL() : AppManager.mixedAudioURL() , video: AppManager.videoURL(), output: finalURL, completionHandler: {
			
			success in
			
			if success {
				let userPostObject = userPost()
				userPostObject.kara = self.post
				userPostObject.file.link = (finalURL.lastPathComponent)
				AppManager.sharedInstance().addUserPost(post: userPostObject)
				var placeHolder : PHObjectPlaceholder?
				PHPhotoLibrary.requestAuthorization({status in
					
					PHPhotoLibrary.shared().performChanges({
						let creationRequest = PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: finalURL )
						placeHolder = creationRequest?.placeholderForCreatedAsset
					}, completionHandler: { one, two in
						let deadlineTime = DispatchTime.now() + .milliseconds(1)
						DispatchQueue.main.asyncAfter(deadline: deadlineTime, execute: {
							//saved to gallery !
							self.waitingView.hide()
							self.closeTapped(self)
						})
					})
					
				})
			}
			
		})
	}
}

extension EditVC: WHSliderDelegate{
	
	func valueChanged(sender: WHSlider, percent: Float) {
		
		if sender.type == controller.playback{
			mixer.setPlaybackVol(vol: percent)
		}else{
			mixer.setVoiceVol(vol: percent)
		}
		
	}
	
}
