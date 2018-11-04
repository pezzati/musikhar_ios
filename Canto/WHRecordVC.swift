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
    
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var fullScreenConstraint: NSLayoutConstraint!
    @IBOutlet weak var squareConstraint: NSLayoutConstraint!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var recordingToolbarView: UIView!
    @IBOutlet weak var darkLayerView: UIView!
    @IBOutlet weak var downloadStateLabel: UILabel!
	@IBOutlet weak var playerToolbar: UIView!
	@IBOutlet weak var playerToolbarHeightCons: NSLayoutConstraint!
	@IBOutlet weak var recordToobarHeightConst: NSLayoutConstraint!
	@IBOutlet weak var playButton: UIButton!
	@IBOutlet weak var playerElapsedTimeLabel: UILabel!
	@IBOutlet weak var playerRemainingTimeLabel: UILabel!
	@IBOutlet weak var playerTimeSlider: mySlider!
	@IBOutlet weak var controllersToolbarView: UIView!
	@IBOutlet weak var lyricsEffectView: UIVisualEffectView!
	
	@IBOutlet weak var line1: UILabel!
	@IBOutlet weak var line2: UILabel!
	@IBOutlet weak var line3: UILabel!
	
	
	
	@IBOutlet weak var rateSlider: WHSlider!
	@IBOutlet weak var pitchSlider: WHSlider!
	@IBOutlet weak var micVolSlider: WHSlider!
	@IBOutlet weak var reverbSlider: WHSlider!
	
    public var post : karaoke!
    var mode : Modes!
	var cameraHelper : CameraHelper?
    var audioHelper : AudioHelper?
    var isSquare = true
    var isFrontCamera = true
	var songDuration : Double = 0
	
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
	}
	
	func setup(){
		closeButton.setImage(#imageLiteral(resourceName: "close").maskWithColor(color: UIColor.white), for: .normal)
		if mode != .karaoke {
			cameraHelper = CameraHelper(inView: cameraView)
			cameraView.isHidden = false
			darkLayerView.isHidden = false
			recordToobarHeightConst.constant = 60
			recordingToolbarView.alpha = 1
		}else{
			recordToobarHeightConst.constant = 0
			recordingToolbarView.alpha = 0
			micVolSlider.setup(of: .micVolume)
			reverbSlider.setup(of: .reverb)
			micVolSlider.delegate = self
			reverbSlider.delegate = self
		}
		rateSlider.setup(of: .rate)
		pitchSlider.setup(of: .pitch)
		rateSlider.delegate = self
		pitchSlider.delegate = self
		playerToolbarHeightCons.constant = 0
		playerToolbar.alpha = 0
		prepareAudio()
	}
	
	func prepareAudio(){
		if audioHelper != nil {
			audioHelper!.getAudioFile(post: post)
		}
	}
	
    @IBAction func closeTapped(_ sender: Any) {
        
        navigationController?.popViewController(animated: true)
        navigationController?.isNavigationBarHidden = false
		audioHelper!.close()
		audioHelper = nil
    }
	
    //MARK: -Recording Toolbar Actions
    @IBAction func recordTapped(_ sender: UIButton) {
    }
    
    @IBAction func rotateTapped(_ sender: UIButton) {
        cameraHelper?.rotateCamera(front: !isFrontCamera, inView: cameraView)
        isFrontCamera = !isFrontCamera
    }
    
    @IBAction func toggleRatioTapped(_ sender: UIButton) {
        if self.isSquare{
            self.squareConstraint.priority = UILayoutPriority(rawValue: 998)
            self.fullScreenConstraint.priority = UILayoutPriority(rawValue: 999)
            sender.setTitle("Square", for: .normal)
        }else{
            self.squareConstraint.priority = UILayoutPriority(rawValue: 999)
            self.fullScreenConstraint.priority = UILayoutPriority(rawValue: 998)
            sender.setTitle("Full", for: .normal)
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
		audioHelper?.seekTo(time: sender.value)
	}
}

extension WHRecordVC: AudioHelperDelegate{

	func updatePlayerTime(elapsed: Double) {
		playerElapsedTimeLabel.text = elapsed.durationText
		playerRemainingTimeLabel.text = (songDuration - elapsed).durationText
		if !playerTimeSlider.isTouchInside{
			playerTimeSlider.value = Float(elapsed/songDuration)
		}
		
		if mode != .dubsmash{
			let lives = post.content.liveLyrics
			if let current = lives.last(where: {$0.time < Float(elapsed)}) {
				line2.text = current.text.replacingOccurrences(of: "\\n", with: "", options: .literal , range: nil)
				if let currentIndex = lives.lastIndex(of: current){
				line3.text = currentIndex + 1 < lives.count ? lives[currentIndex+1].text.replacingOccurrences(of: "\\n", with: "", options: .literal , range: nil) : ""
					line1.text = currentIndex == 0 ? "" :  lives[currentIndex-1].text.replacingOccurrences(of: "\\n", with: "", options: .literal , range: nil)
				}else{
					line3.text = ""
				}
			}
		}
	}
	

	func playerToggled() {
		if audioHelper!.filePlayer != nil && audioHelper!.fileIsRead {
			playButton.setTitle(audioHelper?.filePlayer.isPlaying ?? false ? "Pause" : "Play", for: .normal)
		}
	}
	
	func fileIsReady(duration : Double) {
		songDuration = duration
		playerRemainingTimeLabel.text = duration.durationText
		playerElapsedTimeLabel.text = Double(0).durationText
        downloadStateLabel.text = "File is ready"
		UIView.animate(withDuration: 1, animations: {
			self.playerToolbarHeightCons.constant = 90
			self.playerToolbar.alpha = 1
		})
		
		controllersToolbarView.isHidden = false
    }

    func downloadProgress(percent: Float) {
        downloadStateLabel.text = Int(100*percent).description + "% Downloaded"
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
			break
		case .pitch :
			audioHelper?.setPitch(pitch: percent)
			break
		case .micVolume :
			audioHelper?.setMicVolume(volume: percent)
			break
		case .reverb :
			audioHelper?.setMicReverb(reverb: percent)
			break
		}
	}
}
























