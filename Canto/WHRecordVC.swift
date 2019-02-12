//
//  WHRecordVC.swift
//  Canto
//
//  Created by Whotan on 9/19/18.
//  Copyright © 2018 WhoTan. All rights reserved.
//

import UIKit
import GPUImage
import AVFoundation

class WHRecordVC: UIViewController {
	
    @IBOutlet weak var closeButton: UIButton!
	
	//Camera
	@IBOutlet weak var cameraView: UIView!
	@IBOutlet weak var darkLayerView: UIView!
	@IBOutlet weak var squareConstraint: NSLayoutConstraint!
	@IBOutlet weak var fullScreenConstraint: NSLayoutConstraint!
	
	//Recording toolbar
	@IBOutlet weak var recordingToolbarView: UIView!
	@IBOutlet weak var recordDownloadProgress: CircularProgress!
	@IBOutlet weak var recordButton: UIButton!
	@IBOutlet weak var settingButton: UIButton!
	@IBOutlet weak var trimmer: WHTrimmer!
	@IBOutlet weak var rotateButton: UIButton!
	
	
	//Karaoke player bar
	@IBOutlet weak var playerElapsedTimeLabel: UILabel!
	@IBOutlet weak var playerRemainingTimeLabel: UILabel!
	@IBOutlet weak var playerTimeSlider: mySlider!
	@IBOutlet weak var playButton: UIButton!
	@IBOutlet weak var playerToolbar: UIView!
	@IBOutlet weak var karaokeDownloadProgress: CircularProgress!
	
	//Lyrics
	@IBOutlet weak var lyricsEffectView: UIVisualEffectView!
	@IBOutlet weak var lyricsCloseButton: UIButton!
	@IBOutlet weak var line1: UILabel!
	@IBOutlet weak var line2: UILabel!
	@IBOutlet weak var line3: UILabel!
	@IBOutlet weak var lyricBoxHeightConstraint: NSLayoutConstraint!
	@IBOutlet weak var lyricsBoxTopConstraint: NSLayoutConstraint!
	
	//Controllers bar
	@IBOutlet weak var controllersToolbarView: UIView!

	@IBOutlet weak var slider1: WHSlider!
	@IBOutlet weak var slider2: WHSlider!
	@IBOutlet weak var slider3: WHSlider!
	@IBOutlet weak var slider4: WHSlider!
	
	//Background
	@IBOutlet weak var LubiaBackgroundIV: UIImageView!
	
	
	public var post : karaoke!
    var mode : Modes!
	var cameraHelper : CameraHelper?
    var audioHelper : AudioHelper?
    var isSquare = false
    var isFrontCamera = true
	var songDuration : Double = 0
	var nextLyra = 0
	var isRecording = false
	var waitingBox : DialougeView? = nil
	
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = true
        audioHelper = AudioHelper(mode: mode)
		audioHelper?.delegate = self
		lyricsEffectView.layer.cornerRadius = 10
		setup()
    }
	
	override func viewDidAppear(_ animated: Bool) {
		
		
		
		cameraHelper?.updateView(inView: cameraView)
		
		if !AppManager.checkAudioIO() && mode != .dubsmash{
			let dialog = DialougeView()
			dialog.plugHeadphones(sender: self, mode: mode)
		}
	}
	
	override func viewWillAppear(_ animated: Bool) {
		if mode != .karaoke{
			trimmer.updateLayout()
		}
	}
	
	func setup(){
		closeButton.setImage(#imageLiteral(resourceName: "close").maskWithColor(color: UIColor.white), for: .normal)
		playerTimeSlider.setThumbImage(UIImage(named: "thumb"), for: .normal)
		cameraHelper = mode == .karaoke ? nil : CameraHelper(inView: cameraView)
		cameraView.isHidden = mode == .karaoke
		darkLayerView.isHidden = mode == .karaoke
		recordingToolbarView.alpha = mode == .karaoke ? 0 : 1
		playerToolbar.alpha = mode == .karaoke ? 145 : 0
		LubiaBackgroundIV.isHidden = mode != .karaoke
		LubiaBackgroundIV.rotate(duration: 40)
		controllersToolbarView.isHidden = mode != .karaoke
		lyricsCloseButton.isHidden = true
		lyricBoxHeightConstraint.constant = 100
		lyricsBoxTopConstraint.constant = 8
		line1.adjustsFontSizeToFitWidth = true
		line2.adjustsFontSizeToFitWidth = true
		line3.adjustsFontSizeToFitWidth = true
		
		line2.text = "در حال آماده سازی"
		setupSliders()
		prepareAudio()
	}
	
	func setupSliders(){
		slider1.delegate = self
		slider2.delegate = self
		slider3.delegate = self
		slider4.delegate = self
		
		
		if mode != .dubsmash{
			slider1.setup(of: .pitch)
			slider2.setup(of: .rate)
			slider3.setup(of: .reverb)
			slider4.setup(of: .micVolume)
			slider1.inactivate()
			slider2.inactivate()
		}else{
			slider2.setup(of: .rate)
			slider3.setup(of: .pitch)
			slider2.inactivate()
			slider3.inactivate()
		}
		
		if mode != .karaoke{
			trimmer.delegate = self
		}
	}
	
	func prepareAudio(){
		if audioHelper != nil {
			audioHelper!.getAudioFile(post: post)
		}
	}
	
    @IBAction func closeTapped(_ sender: Any) {
		audioHelper!.close()
		audioHelper = nil
		LubiaBackgroundIV.isHidden = true
		navigationController?.popViewController(animated: true)
		navigationController?.isNavigationBarHidden = false
    }
	
	//MARK: -Lyrics box action
	
	@IBAction func closeLyrics(_ sender: UIButton) {
		if lyricBoxHeightConstraint.constant == 0 {
			lyricBoxHeightConstraint.constant = 100
			lyricsBoxTopConstraint.constant = 8
			lyricsCloseButton.setImage( UIImage(named: "minimize_lyrics") , for: .normal)
		}else{
			lyricBoxHeightConstraint.constant = 0
			lyricsBoxTopConstraint.constant = 58
			lyricsCloseButton.setImage( UIImage(named: "expand_lyrics") , for: .normal)
		}
//		if sender == lyricsCloseButton{
			UIView.animate(withDuration: 1, animations: {
				self.view.layoutIfNeeded()
			})
//		}
	}
	
    //MARK: -Recording Toolbar Actions
    @IBAction func recordTapped(_ sender: UIButton) {
		
		if !isRecording{
			
			
			
			trimmer.inactivate()
			prepareLyricsToStart()
			rotateButton.isHidden = true
			isRecording = true
			sender.setImage(UIImage(named: "stop"), for: .normal)
			audioHelper?.prepareToRecord()
			cameraHelper!.initiateRecorder()
			
			let when = DispatchTime.now() + 0.1
			DispatchQueue.main.asyncAfter(deadline: when, execute: {
				self.cameraHelper?.startRecording()
				self.audioHelper?.startRecording()
			})
		}else{
			waitingBox = DialougeView()
			waitingBox!.waitingBox(vc: self)
			let when = DispatchTime.now() + 0.1
			DispatchQueue.main.asyncAfter(deadline: when, execute: {
				self.cameraHelper?.stopRecording()
				self.audioHelper?.stopRecording()
				self.proceedToEdit()
			})
		}
    }
	
	func proceedToEdit(){
		isRecording = false
		audioHelper = nil
		let editVC = storyboard?.instantiateViewController(withIdentifier: "EditVC") as! EditVC
		editVC.mode = mode
		editVC.post = post
		waitingBox!.hide()
		waitingBox = nil
		navigationController?.pushViewController(editVC, animated: true)
	}
    
    @IBAction func rotateTapped(_ sender: UIButton) {
        cameraHelper?.rotateCamera(front: !isFrontCamera, inView: cameraView)
        isFrontCamera = !isFrontCamera
    }
    
    @IBAction func toggleRatioTapped(_ sender: UIButton) {
        if self.isSquare{
            self.squareConstraint.priority = UILayoutPriority(rawValue: 998)
            self.fullScreenConstraint.priority = UILayoutPriority(rawValue: 999)
            sender.setImage(UIImage(named: "cam_square"), for: .normal)
        }else{
            self.squareConstraint.priority = UILayoutPriority(rawValue: 999)
            self.fullScreenConstraint.priority = UILayoutPriority(rawValue: 998)
            sender.setImage(UIImage(named: "cam_story"), for: .normal)
        }
        self.isSquare = !self.isSquare
        self.view.layoutIfNeeded()
        self.cameraHelper?.updateView(inView: self.cameraView)
    }
    
    @IBAction func settingTapped(_ sender: UIButton) {
		if audioHelper!.fileIsRead{
			controllersToolbarView.isHidden.toggle()
		}
    }
	
	//MARK: -Player Toolbar Actions
	
	@IBAction func playerTapped(_ sender: UIButton) {
		audioHelper?.togglePlay()
	}
	
	@IBAction func playerSliderTouchUpInside(_ sender: mySlider) {
		print(sender.value)
		audioHelper?.seekTo(time: sender.value)
		
	}
	
	func prepareLyricsToStart(){
		
		if mode != .dubsmash {
			lyricsCloseButton.isHidden = false
		}else{
			self.closeLyrics(lyricsCloseButton)
		}
		
		line1.text = ""
		line2.text = ""
		line3.text = ""
		
		let startTime = (audioHelper?.minValue)! * Float((audioHelper?.filePlayer.duration)!)
		
		let lives = post.content.liveLyrics
		
		if let nextLine = lives.first(where: {$0.time > startTime}) {
			line3.text = nextLine.text
			if let currentIndex = lives.lastIndex(of: nextLine){
				nextLyra = currentIndex
			}
		}
	}
	
}

extension WHRecordVC: AudioHelperDelegate{
	
	func updatePlayerTime(elapsed: Double) {
		
		if mode == .karaoke {
			playerElapsedTimeLabel.text = elapsed.durationText
			playerRemainingTimeLabel.text = (songDuration - elapsed).durationText
			if !playerTimeSlider.isTouchInside{
				playerTimeSlider.value = Float(elapsed/songDuration)
			}
		}else{
			trimmer.updatePlayLine(end: elapsed/songDuration)
		}
		
		if mode == .dubsmash { return }
		let lyrics = post.content.liveLyrics
		if nextLyra > lyrics.count {
			if Float(elapsed) > lyrics[nextLyra].time{
				if isRecording{
					updateLyrics()
				}
			}
		}
	}
	
	func recordTimeEnded() {
		recordTapped(recordButton)
	}
	
	func updateLyrics() {
		
		if !(audioHelper?.fileIsRead)! { return }
		
		let lives = post.content.liveLyrics
		if let next = lives.first(where: {$0.time > Float((audioHelper?.filePlayer.currentTime)!)}) {
			line3.text = next.text
			
			if let nextIndex = lives.lastIndex(of: next){
				nextLyra = nextIndex
				line2.text = nextIndex - 1 >= 0 ? lives[nextIndex-1].text : ""
				line1.text = nextIndex - 2 >= 0 ? lives[nextIndex - 2].text : ""
			}
		}else{
			if !(line3.text?.isEmpty)!{
				line1.text = line2.text
				line2.text = line3.text
				line3.text = ""
			}
		}
	}
	
	func playerToggled() {
		if audioHelper!.filePlayer != nil && audioHelper!.fileIsRead {
			playButton.setImage(UIImage(named: audioHelper?.filePlayer.isPlaying ?? false ? "pause" : "play"), for: .normal)
		}
		if isRecording{
			updateLyrics()
		}
	}
	
	func fileIsReady(duration : Double) {
		songDuration = duration
		
		line2.text = "۶۰ ثانیه مورد نظر از آهنگ را انتخاب کنید"
		line3.text = "برای شروع دکمه ضبط را لمس کنید"
		if controllersToolbarView.isHidden && mode != .karaoke{
			settingTapped(settingButton)
		}
		
		
		if mode == .karaoke{
			playerRemainingTimeLabel.text = duration.durationText
			playerElapsedTimeLabel.text = Double(0).durationText
			slider1.activate()
			slider2.activate()
			UIView.animate(withDuration: 1.5, animations: {
				self.playerElapsedTimeLabel.alpha = 1
				self.playerRemainingTimeLabel.alpha = 1
				self.playerTimeSlider.alpha = 1
				self.playButton.alpha = 1
				self.karaokeDownloadProgress.alpha = 0
			})
		}else{
			slider2.activate()
			slider3.activate()
			if mode == .singing{
				slider1.activate()
			}
			
			DispatchQueue.main.async {
				let trimLenght = 60.0/duration
				self.trimmer.setup(max: trimLenght, min: trimLenght)
			}
			UIView.animate(withDuration: 1.5, animations: {
				self.settingButton.alpha = 1
				self.recordButton.alpha = 1
				self.recordDownloadProgress.alpha = 0
			})
			
		}
		
//		controllersToolbarView.isHidden = false
		if !(audioHelper?.filePlayer.isPlaying)!{ audioHelper?.togglePlay()}
	}

    func downloadProgress(percent: Float) {
		line1.text = "در حال آماده سازی"
		line2.text = "در حال دانلود فایل"
		
		if mode == .karaoke{
			karaokeDownloadProgress.setProgressWithAnimation(duration: 0, value: percent)
		}else{
			recordDownloadProgress.setProgressWithAnimation(duration: 0, value: percent)
		}
    }
	
	func failedToReadFile() {
		prepareAudio()
	}
}


extension WHRecordVC: WHSliderDelegate {
	func valueChanged(sender: WHSlider, percent: Float) {
		
		switch sender.type! {
		case .rate :
			audioHelper?.setRate(rate: percent)
			if !(audioHelper?.filePlayer.isPlaying)!{ audioHelper?.togglePlay()}
			break
		case .pitch :
			audioHelper?.setPitch(pitch: percent)
			if !(audioHelper?.filePlayer.isPlaying)!{ audioHelper?.togglePlay()}
			break
		case .micVolume :
			audioHelper?.setMicVolume(volume: percent)
			break
		case .reverb :
			audioHelper?.setMicReverb(reverb: percent)
			break
		default:
			break
		}
	}
}

extension WHRecordVC: WHTrimmerDelegate {
	
	func valueChanged(sender: WHTrimmer, minVal: Float, maxVal: Float) {
		audioHelper?.seekTo(time: minVal)
		audioHelper?.minValue = minVal
		audioHelper?.maxValue = maxVal
		line1.text = "۶۰ ثانیه مورد نظر از آهنگ را انتخاب کنید"
		line2.text = "برای شروع دکمه ضبط را لمس کنید"
		line3.text = ""
	}
	
	
	
}
























