//
//  AudioMixer.swift
//  Canto
//
//  Created by WhoTan on 5/6/18.
//  Copyright © 2018 WhoTan. All rights reserved.
//

import UIKit
import AudioKit

class AudioMixer: NSObject {

    var karaPlayer : AKPlayer!
    var voicePlayer : AKPlayer!
    var mixer : AKMixer!
    var reverb : AKReverb!
    var multiEcho : AKFlanger!
    var helium : AKTimePitch!
    var smooth : AKAutoWah!
    var booster : AKBooster!
    var isPlaying = false
    var fakePitch : AKTimePitch!
	var currentEffect : soundFx = .none
	
    
    init(recordedFileURL: URL, karaFileURL: URL) {
        
		try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback , with: .defaultToSpeaker)
		try? AVAudioSession.sharedInstance().setActive(true)
    
//        AKSettings.enableCategoryChangeHandling = false
//        try? AKSettings.setSession(category: AKSettings.SessionCategory.playback, with: .defaultToSpeaker )
        
        karaPlayer = AKPlayer(url: karaFileURL)
        voicePlayer = AKPlayer(url: recordedFileURL)
        
        booster = AKBooster(voicePlayer, gain: 2)
        
        reverb = AKReverb(booster)
        reverb.loadFactoryPreset(.largeHall)
        reverb.dryWetMix = 0.3
        multiEcho = AKFlanger(booster)
        
        helium = AKTimePitch(booster)
        helium.pitch = 1200
        
        smooth = AKAutoWah(booster)
        smooth.wah = 1
        smooth.amplitude = 1
        smooth.mix = 1
        
        fakePitch = AKTimePitch(karaPlayer)
        fakePitch.pitch = 0
        
        mixer = AKMixer()
        mixer.connect(input: booster, bus: 0)
        mixer.connect(input: karaPlayer, bus: 1)
        
        AudioKit.output = mixer
        
        do{
            try AudioKit.start()
            
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback , with: .defaultToSpeaker)
            try AVAudioSession.sharedInstance().setActive(true)
         
        } catch{
            print("Initializing AudioMixer (AudioKit) Failed" + error.localizedDescription)
        }
    }
    
    func noEffect(){
        
    }
    
    func setEffect(effect : soundFx){
		currentEffect = effect
		
        self.mixer.disconnectInput(bus: 0)
 
        
        switch effect {
            
        case .none :
            
            self.mixer.connect(input: booster, bus: 0)
            
            break
        case .helium:

            self.mixer.connect(input: helium, bus: 0)
            
            break
        case .reverb:
            
            self.mixer.connect(input: reverb, bus: 0)
            
            break
        case .grunge:

            self.mixer.connect(input: smooth, bus: 0)
            
            break
        case .multiline:
            
            self.mixer.connect(input: multiEcho, bus: 0)
            
            break
        }
		
    }
    
    
    func play(){
        if AudioKit.engine.isRunning{
            karaPlayer?.play()
            voicePlayer?.play()
            self.isPlaying = true
        }
    }
    
    func pause(){
        karaPlayer?.pause()
        voicePlayer?.pause()
        self.isPlaying = false
    }
    
    func resume(){
        karaPlayer?.resume()
        voicePlayer?.resume()
        self.isPlaying = true
    }
    
    func setPlaybackVol(vol : Float){
        self.karaPlayer.volume = Double(vol)
    }
    
    func setVoiceVol(vol : Float){
        self.voicePlayer.volume = Double(vol)
    }
    
    func seekTo(time: Double){
        
        karaPlayer.pause()
        voicePlayer.pause()
        let sampleTimeZero = AVAudioTime(sampleTime: 0, atRate: AudioKit.format.sampleRate)
		
        voicePlayer.setPosition(time + 0.1)
		if currentEffect == .helium{
			voicePlayer.setPosition(time + 0.2)
		}
		karaPlayer.setPosition(time)
    }
    
//    public func setNotification(){
//
//        NotificationCenter.default.addObserver(self, selector: #selector(configurationChanged), name: NSNotification.Name.AVAudioEngineConfigurationChange , object: AudioKit.engine)
//    }
//
//    public func removeNotification(){
//        NotificationCenter.default.removeObserver(self)
//    }
	
//    @objc func configurationChanged(){
//
//        do{
//            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord , with: .defaultToSpeaker)
//            try AVAudioSession.sharedInstance().setActive(true)
//            try AudioKit.start()
//            if self.isPlaying{
//                self.pause()
//            }
//
//
//        } catch {
//            print(error)
//        }
//
//        if self.isPlaying{
//            self.pause()
//        }
//
//    }
	
    func render(url: URL){
        
        try? FileManager.default.removeItem(at: url)
        
        do{
//            if #available(iOS 11, *) {
            let outputFile = try AKAudioFile(forWriting: url, settings: [:])
                _ = AudioKit.engine.isRunning
            
            
                try AudioKit.renderToFile(outputFile, duration: karaPlayer.duration, prerender: {
                    self.seekTo(time: 0)
                    self.play()
                })
			
			AudioKit.disconnectAllInputs()
            try? AudioKit.stop()
            
            
//            }else{
//
//                let offlineNode = AKOfflineRenderNode(self.mixer)
//                AudioKit.output = offlineNode
//                offlineNode.internalRenderEnabled = false
////                try AudioKit.start()
//
//                self.seekTo(time: 0)
//                try offlineNode.renderToURL(url, duration: self.karaPlayer.duration)
//
//                self.karaPlayer.stop()
//                self.voicePlayer.stop()
//                offlineNode.internalRenderEnabled = true
//                
//            }
        }catch{
            print(error)
            print("Couldn't render output file")
        }
    }
    
    
    
    
}
 
