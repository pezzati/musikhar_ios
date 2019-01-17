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
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		loadVideo()
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		NotificationCenter.default.removeObserver(self)
	}
	
	func loadVideo(){
		playerItem = AVPlayerItem(url: AppManager.videoURL())
		mainPlayer = AVPlayer(playerItem: playerItem)
		movie = GPUImageMovie(playerItem: playerItem)
		movie.addTarget(videoView)
		movie.startProcessing()
		audioPlayerItem = AVPlayerItem(url: AppManager.karaURL())
		audioPlayer = AVPlayer(playerItem: audioPlayerItem)
		NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidPlayToEndTime), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
	}
	
	func setFilter(){
		
		
		
	}
	
	override func viewDidAppear(_ animated: Bool) {
		mainPlayer.play()
		audioPlayer.play()
		do{
			try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback , with: .defaultToSpeaker)
			try AVAudioSession.sharedInstance().setActive(true)
		}catch{
			print(error)
		}
	}
	
	@IBAction func saveTapped(_ sender: Any) {
		saveVideo()
	}
	
	@IBAction func closeTapped(_ sender: Any) {
		audioPlayer.pause()
		mainPlayer.pause()
		navigationController?.popToRootViewController(animated: true)
	}
	
	@objc func playerItemDidPlayToEndTime(){
		mainPlayer.seek(to: kCMTimeZero)
		audioPlayer.seek(to: kCMTimeZero)
		mainPlayer.play()
		audioPlayer.play()
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
					if status == .authorized{
						
						PHPhotoLibrary.shared().performChanges({
							let creationRequest = PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: finalURL )
							placeHolder = creationRequest?.placeholderForCreatedAsset
						}, completionHandler: { one, two in
							let deadlineTime = DispatchTime.now() + .milliseconds(1)
							DispatchQueue.main.asyncAfter(deadline: deadlineTime, execute: {
								//saved to gallery !
							})
						})
					} else {
						//gallery access not granted
					}
				})
			}
			self.closeTapped(self)
		})
	}
	
}
