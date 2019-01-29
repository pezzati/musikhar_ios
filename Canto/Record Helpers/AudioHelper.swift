//
//  AudioHelper.swift
//  Canto
//
//  Created by Whotan on 10/12/18.
//  Copyright © 2018 WhoTan. All rights reserved.
//

import UIKit
import Alamofire
import AudioKit

protocol AudioHelperDelegate: class {
	func fileIsReady(duration : Double)
	func downloadProgress(percent : Float)
	func playerToggled()
	func updatePlayerTime(elapsed : Double)
	func recordTimeEnded()
	func failedToReadFile()
}

class AudioHelper: NSObject {
	
	weak var delegate : AudioHelperDelegate!
	var fileIsRead = false
	var downloadRequest : Alamofire.Request?
	var downloadPercent : Float = 0.0
	var mic : AKMicrophone!
	var micReverb : AKReverb!
	var monitorBooster : AKBooster!
	var mainMixer : AKMixer!
	var filePlayer : AKPlayer!
	var timePitch : AKTimePitch!
	var fileWriter: AKAudioFile!
	var fileRecorder: AKNodeRecorder!
	var voiceWriter: AKAudioFile!
	var voiceRecorder: AKNodeRecorder!
	var micLowPass: AKLowPassFilter!
	var micBooster: AKBooster!
	var timer : Timer?
	var mode : Modes!
	var maxValue : Float = 1.0
	var minValue : Float = 0.0
	var isRecording = false
	
	init(mode: Modes) {
		
		self.mode = mode
		mainMixer = AKMixer()
		AKSettings.sampleRate = AudioKit.engine.inputNode.inputFormat(forBus: 0).sampleRate
		mic = AKMicrophone()
		micReverb = AKReverb(mic, dryWetMix: mode == .karaoke ? 0.3 : 0.0)
		micLowPass = AKLowPassFilter(micReverb, cutoffFrequency: 2000, resonance: -20)
		micReverb.loadFactoryPreset(AVAudioUnitReverbPreset.largeChamber)
		monitorBooster = AKBooster(micLowPass, gain: mode == .dubsmash ? 0.0 : 1.0)
		mainMixer.connect(input: monitorBooster)
		AudioKit.output = mainMixer
		
		do{
			try AudioKit.start()
			try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord , with: .defaultToSpeaker )
			try AVAudioSession.sharedInstance().setActive(true)
		} catch{
			print("Initializing AudioMixer (AudioKit) Failed" + error.localizedDescription)
		}
	}

	func close(){
		if downloadRequest != nil {
			downloadRequest?.cancel()
		}
		AudioKit.disconnectAllInputs()
		try? AudioKit.stop()
		if timer != nil {
			timer?.invalidate()
			timer = nil
		}
	}
	
	func getAudioFile(post: karaoke) {
		
		let urlString = mode == .dubsmash ? post.content.original_file_url : post.content.karaoke_file_url
		if urlString.isEmpty { return }
		let fileName = (urlString as NSString).lastPathComponent
		var filePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
		filePath.appendPathComponent("karaokes")
		try! FileManager.default.createDirectory(atPath: filePath.path, withIntermediateDirectories: true, attributes: nil)
		filePath.appendPathComponent(fileName)
		
		if FileManager.default.fileExists(atPath: filePath.path){
			readFile(url: filePath)
			return
		}
		
		let url = URL(string: urlString)
		
		let destination: DownloadRequest.DownloadFileDestination = { _, _ in
			return (filePath, [.removePreviousFile])
		}

		downloadRequest = Alamofire.download(url!, to: destination).downloadProgress(closure: { (progress) in
			DispatchQueue.main.async {
				self.downloadPercent = Float(progress.completedUnitCount) / Float(progress.totalUnitCount)
				self.delegate.downloadProgress(percent: self.downloadPercent)
			}}).responseData { response in
				self.readFile(url: filePath)
		}
		
	}
	
	func readFile(url : URL){
		print("reading file at : \(url.absoluteString)")
		if !fileIsRead{
			filePlayer = AKPlayer(url: url)
			timePitch = AKTimePitch(filePlayer)
			mainMixer.connect(input: timePitch)
		}
		if filePlayer != nil{
			fileIsRead = true
			delegate.fileIsReady(duration: filePlayer.duration)
			maxValue = mode == .karaoke ? 1.0 : Float(60.0/filePlayer.duration)
			timer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(updateTimer) , userInfo: nil, repeats: true)
			
		}else{
			try? FileManager.default.removeItem(at: url)
			delegate.failedToReadFile()
		}
	}
	
	func togglePlay(){
		
		do{
			try AudioKit.start()
			try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord , with: .defaultToSpeaker)
			try AVAudioSession.sharedInstance().setActive(true)
		} catch{
			print("Initializing AudioMixer (AudioKit) Failed" + error.localizedDescription)
		}
		if AudioKit.engine.isRunning{
			if filePlayer.isPlaying{ filePlayer.pause() }
			else{ filePlayer.resume() }
		}else{ togglePlay() }
		delegate.playerToggled()
		
	}
	
	func seekTo(time: Float){
		
		if filePlayer != nil && fileIsRead {
			let seekTime = Double(time)*filePlayer.duration
//			filePlayer.setPosition(seekTime)
			filePlayer.pause()
			filePlayer.play(from: seekTime)
//			filePlayer.resume()
		}
		delegate.playerToggled()
	}
	
	func setPitch(pitch: Float){
		let step = (pitch - 0.5)*500
		timePitch.pitch = Double(step)
	}
	
	func setRate(rate: Float){
		timePitch.rate = Double(rate + 0.5)
	}
	
	func setMicVolume(volume : Float){
		monitorBooster.gain = Double(volume*2)
	}
	
	func setMicReverb(reverb: Float){
//		micReverb.loadFactoryPreset(AVAudioUnitReverbPreset(rawValue: Int((reverb*100)/8.33))!)
		switch reverb*100 {
		case 0 ... 5:
			micReverb.dryWetMix = 0
			break
		case 6 ... 15:
			micReverb.loadFactoryPreset(AVAudioUnitReverbPreset.mediumRoom)
			micReverb.dryWetMix = 0.25
			break
		case 16 ... 25:
			micReverb.loadFactoryPreset(AVAudioUnitReverbPreset.largeRoom)
			micReverb.dryWetMix = 0.25
			break
		case 26 ... 35:
			micReverb.loadFactoryPreset(AVAudioUnitReverbPreset.mediumHall)
			micReverb.dryWetMix = 0.25
			break
		case 36 ... 50:
			micReverb.loadFactoryPreset(AVAudioUnitReverbPreset.largeChamber)
			micReverb.dryWetMix = 0.25
			break
		case 51 ... 65:
			micReverb.loadFactoryPreset(AVAudioUnitReverbPreset.largeHall)
			micReverb.dryWetMix = 0.25
			break
		case 66 ... 80:
			micReverb.loadFactoryPreset(AVAudioUnitReverbPreset.largeHall2)
			micReverb.dryWetMix = 0.25
			break
		case 81 ... 100:
			micReverb.loadFactoryPreset(AVAudioUnitReverbPreset.cathedral)
			micReverb.dryWetMix = 0.25
			break
		default:
			break
		}
	}
	
	
	@objc func updateTimer(){
		if filePlayer != nil && filePlayer.isPlaying{
			delegate.updatePlayerTime(elapsed: filePlayer.currentTime)
			let crr = filePlayer.currentTime/filePlayer.duration
			if crr > Double(maxValue) {
				if isRecording{
					delegate.recordTimeEnded()
				}else{
					seekTo(time: minValue)
				}
			}
		}
	}
	
	func prepareToRecord(){
		filePlayer.pause()
		try? FileManager.default.removeItem(at: AppManager.karaURL())
		try? FileManager.default.removeItem(at: AppManager.voiceURL())
		//		fileWriter = try! AKAudioFile(forWriting: AppManager.karaURL(), settings: [AVNumberOfChannelsKey:filePlayer.processingFormat?.channelCount, AVSampleRateKey: filePlayer.processingFormat!.sampleRate], commonFormat: (filePlayer.processingFormat?.commonFormat)!, interleaved: (filePlayer.processingFormat?.isInterleaved)!)
		
		fileWriter = try! AKAudioFile(forWriting: AppManager.karaURL(), settings: [AVNumberOfChannelsKey:filePlayer.processingFormat?.channelCount, AVSampleRateKey: 44100], commonFormat: (filePlayer.processingFormat?.commonFormat)!, interleaved: (filePlayer.processingFormat?.isInterleaved)!)
		
		fileRecorder = try! AKNodeRecorder(node: timePitch, file: fileWriter)
		
		if mode == .singing{
			
			voiceWriter = try! AKAudioFile(forWriting: AppManager.voiceURL(), settings: [AVNumberOfChannelsKey:filePlayer.processingFormat?.channelCount, AVSampleRateKey: 44100], commonFormat: (filePlayer.processingFormat?.commonFormat)!, interleaved: (filePlayer.processingFormat?.isInterleaved)!)
			//				voiceWriter = try! AKAudioFile(forWriting: AppManager.voiceURL(), settings:[AVNumberOfChannelsKey:format.channelCount as Any], commonFormat: format.commonFormat, interleaved: format.isInterleaved)
			voiceRecorder = try! AKNodeRecorder(node: mic, file: voiceWriter)
		}
	}
	
	
	func startRecording(){
		
		let when = DispatchTime.now()
		DispatchQueue.main.asyncAfter(deadline: when, execute: {
			self.filePlayer.play(from: Double(self.minValue)*self.filePlayer.duration)
			try! self.fileRecorder.record()
			if self.mode == .singing {
				try! self.voiceRecorder.record()
			}
		})
		isRecording = true
	}
	
	func stopRecording(){
		togglePlay()
		fileRecorder.stop()
		if mode == .singing{ voiceRecorder.stop() }
		isRecording = false
		self.close()
	}
	
}
