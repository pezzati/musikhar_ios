//
//  AudioManager.swift
//  Canto
//
//  Created by WhoTan on 4/29/18.
//  Copyright © 2018 WhoTan. All rights reserved.
//

import UIKit
import AVFoundation

class RecordManager: NSObject {

    private let engine = AVAudioEngine()
    private var node = AVAudioPlayerNode()
    private let pitch = AVAudioUnitTimePitch()
    private var recordMixer = AVAudioMixerNode()
    private var inputFile: AVAudioFile!
    private var karaOutputFile : AVAudioFile!
    private var recordOutputFile : AVAudioFile!
    private var fakeEngine = AVAudioEngine()
    private var buffer : AVAudioPCMBuffer!
    var monitor = false
    var playing = false
    var duration : Double = 0.0
    var elapsedTime : Double = 0.0
    
    init(karaOutputURL: URL, recordOutputURL: URL, duration: Double ) {
        
        self.duration = duration

        do{
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord , with: .defaultToSpeaker)
            try AVAudioSession.sharedInstance().setActive(true)
        }catch{ }
        
        self.engine.attach(self.node)
        self.engine.attach(self.recordMixer)
        self.engine.attach(pitch)
        
        let input = engine.inputNode
        input.volume = 1.0
        recordMixer.outputVolume = 1.0
        engine.connect(input, to:self.recordMixer , format: input.outputFormat(forBus: 0))
        engine.connect(self.recordMixer, to: engine.outputNode , format: input.outputFormat(forBus: 0))
        
        engine.stop()
        engine.mainMixerNode.removeTap(onBus: 0)
        do{
           
            try engine.start()
            try self.karaOutputFile = AVAudioFile(forWriting: karaOutputURL, settings: engine.mainMixerNode.outputFormat(forBus: 0).settings)
            try self.recordOutputFile = AVAudioFile(forWriting: recordOutputURL, settings: recordMixer.outputFormat(forBus: 0).settings)
        } catch {
            print(error)
            
        }
        
        if AVAudioSession.sharedInstance().currentRoute.outputs.count == 0 {
            self.fakeEngine.connect(fakeEngine.inputNode, to: fakeEngine.mainMixerNode, format: fakeEngine.inputNode.inputFormat(forBus: 0))
            try? fakeEngine.start()
        }
    }
    
    public func read(fileUrl: URL, completionHandler: @escaping (Bool) -> ()){
        
        do{
            try inputFile = AVAudioFile(forReading: fileUrl)
        } catch{
            print("failed to read file")
            completionHandler(false)
            return
        }
        
        let format = inputFile.processingFormat
        let capacity = AVAudioFrameCount(inputFile.length)
        buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: capacity)
        
        do{
            try inputFile.read(into: buffer!)
        }catch{
            print("failed to read file")
            completionHandler(false)
        }
        print(format.channelCount)
//        node.scheduleBuffer(buffer!, at: nil, options: [], completionHandler: nil)

        engine.connect(node, to: pitch, format: format)
        engine.connect(pitch, to: engine.mainMixerNode, format: format)
        completionHandler(true)
        engine.stop()
        do{
            try engine.start()
            self.play()
            self.pause()
        }catch{print("failed to read file")
            completionHandler(false)
        }
    }
    
    public func startRecording(){
        let tapBuffer : AVAudioFrameCount = 4096 / 4
        engine.mainMixerNode.removeTap(onBus: 0)
        recordMixer.removeTap(onBus: 0)
//        self.pause()
        
        self.play()
        self.playing = true
        engine.mainMixerNode.installTap(onBus: 0, bufferSize: tapBuffer , format:engine.mainMixerNode.outputFormat(forBus: 0), block:{ buffer, when in
            do{
                if self.node.isPlaying{
                try self.karaOutputFile.write(from: buffer)
                }else{
                    print("Node not playing")
                }
            }
            catch { print(NSString(string: "Kara Write failed"))
            }})
        recordMixer.installTap(onBus: 0, bufferSize: tapBuffer , format:recordMixer.outputFormat(forBus: 0), block:{ buffer, when in
            do{ try self.recordOutputFile.write(from: buffer)}
            catch { print(NSString(string: "Kara Write failed"))
            }})

    }
    
    public func setNotification(){
        
        NotificationCenter.default.addObserver(self, selector: #selector(configurationChanged), name: NSNotification.Name.AVAudioEngineConfigurationChange , object: self.engine)
           NotificationCenter.default.addObserver(self, selector: #selector(configurationChanged), name: NSNotification.Name.AVAudioEngineConfigurationChange , object: self.fakeEngine)
//        NotificationCenter.default.addObserver(self, selector: #selector(configurationChanged), name: NSNotification.Name.AVAudioSessionRouteChange , object: nil)
    }
    
    @objc func configurationChanged(){
        
        do{
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord , with: .defaultToSpeaker)
            try AVAudioSession.sharedInstance().setActive(true)
            try engine.start()
            if self.node.isPlaying{
                seekToNow()
            }
            
        } catch {
            print(error)
        }
        
    
        self.setMonitor()
    }
    
    func seekToNow(){
        
            if let Nodetime: AVAudioTime  = node.lastRenderTime{
                
                
                let length = Float(duration) - Float(elapsedTime)
                let PlayerTime: AVAudioTime = node.playerTime(forNodeTime: Nodetime)!
                let SampleRate = PlayerTime.sampleRate
                
                let Newsampletime = AVAudioFramePosition(SampleRate * elapsedTime)
                let Framestoplay = AVAudioFrameCount(Float(PlayerTime.sampleRate) * length)
                
                node.stop()
                
                if Framestoplay > 1000 && Newsampletime >= 0{
                    node.scheduleSegment(inputFile, startingFrame: Newsampletime, frameCount: Framestoplay, at: nil,completionHandler: nil)
                }
            }
        self.play()
    }

    
    
    public func removeNotification(){
        NotificationCenter.default.removeObserver(self)
    }
    
    public func currentTime() -> TimeInterval {
        if let nodeTime: AVAudioTime = node.lastRenderTime, let playerTime: AVAudioTime = node.playerTime(forNodeTime: nodeTime) {
            let result =  Double(Double(playerTime.sampleTime) / playerTime.sampleRate)
            self.elapsedTime = result
            
            return result
        }
        return 0
    }
    
    public func stopRecording(){
        if engine != nil{
            engine.mainMixerNode.removeTap(onBus: 0)
            recordMixer.removeTap(onBus: 0)
            self.node.stop()
            engine.stop()
            self.fakeEngine.stop()
        }
    }
    
    public func set(pitch: Float){
        self.pitch.pitch = pitch
    }
    
    public func set(volume: Float){
        self.node.volume = volume
    }
    
    public func set(rate: Float){
        self.pitch.rate = rate
    }
    
    public func pause(){
        self.node.stop()
        self.playing = false
        node.scheduleBuffer(buffer!, at: nil, options: [], completionHandler: nil)
    }
    
    public func play(){
        
        if self.engine.isRunning {
            self.node.play(at: nil)
            self.playing = true
        }else{
            do{ try self.engine.start() }
            catch{}
        }
    }
    
    public func setMonitor(){
        
        var on = false
        
        let currentRoute = AVAudioSession.sharedInstance().currentRoute
        if currentRoute.outputs.count != 0 {
            for item in currentRoute.outputs{
                if item.portType == AVAudioSessionPortHeadphones{
                    on = true
                }else if item.portType == AVAudioSessionPortHeadsetMic{
                    on = true
                }
            }
        }
        
        if on{
//             AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 1)
            self.fakeEngine.connect(fakeEngine.inputNode, to: fakeEngine.mainMixerNode, format: fakeEngine.inputNode.inputFormat(forBus: 0))
            try? fakeEngine.start()
            fakeEngine.mainMixerNode.volume = 1
            self.monitor = true
        }else{
//            self.fakeEngine.stop()
//            self.fakeEngine = AVAudioEngine()
            fakeEngine.mainMixerNode.volume = 0
            self.monitor = false
        }
    }
    
    
}
