//
//  MixManager.swift
//  Canto
//
//  Created by WhoTan on 5/9/18.
//  Copyright © 2018 WhoTan. All rights reserved.
//

/*
import UIKit
import AVFoundation


class MixManager: NSObject {

    /*
    private var karaNode = AVAudioPlayerNode()
    private var recordedNode = AVAudioPlayerNode()
    private var mixer = AVAudioMixerNode()
    private var pitch : AVAudioUnitTimePitch!
    private var reverb : AVAudioUnitReverb!
    private var fakePitch : AVAudioUnitTimePitch!
    */
    private var karaFile: AVAudioFile!
    private var recordedFile : AVAudioFile!
    private var karaBuffer : AVAudioPCMBuffer!
    private var recordedBuffer : AVAudioPCMBuffer!
//    private var outputFile : AVAudioFile!
    private var fakeMixer = AVAudioMixerNode()
    private var outputFiles: [AVAudioFile] = []

    
    public var engine : AVAudioEngine!
    
    private var records : [AVAudioPlayerNode] = []
    private var reverbs : [AVAudioUnitReverb] = []
    private var pitches : [AVAudioUnitTimePitch] = []
    private var karas: [AVAudioPlayerNode] = []
    private var fakePitches : [AVAudioUnitTimePitch] = []
    private var mixers: [AVAudioMixerNode] = []
    private var distortions : [AVAudioUnitDistortion] = []
    
    
    
    private var renderMode = false
    private var pieces : Int = 1
    
    init(karaURL: URL, recordedFileURL: URL,sound: Bool, pieceCount: Int = 1) {
        
        engine = AVAudioEngine()
        try! karaFile = AVAudioFile(forReading: karaURL)
        try! recordedFile = AVAudioFile(forReading: recordedFileURL)
        let format = karaFile.processingFormat
        let karaCap = AVAudioFrameCount(karaFile.length)
        let recordedCap = AVAudioFrameCount(recordedFile.length)
        karaBuffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: karaCap)
        recordedBuffer = AVAudioPCMBuffer(pcmFormat: recordedFile.processingFormat, frameCapacity: recordedCap)
        try! karaFile.read(into: karaBuffer)
        try! recordedFile.read(into: recordedBuffer)
        self.pieces = pieceCount
        
        engine.attach(fakeMixer)
        
        for i in 0...pieceCount - 1{
            
            //initializing
            mixers.append(AVAudioMixerNode())
            fakePitches.append(AVAudioUnitTimePitch())
            reverbs.append(AVAudioUnitReverb())
            pitches.append(AVAudioUnitTimePitch())
            karas.append(AVAudioPlayerNode())
            records.append(AVAudioPlayerNode())
            outputFiles.append(AVAudioFile())
            distortions.append(AVAudioUnitDistortion())
            distortions[i].bypass = true
            
            //attaching to engine
            engine.attach(mixers[i])
            engine.attach(fakePitches[i])
            engine.attach(reverbs[i])
            engine.attach(pitches[i])
            engine.attach(karas[i])
            engine.attach(records[i])
            engine.attach(distortions[i])
            

            
            
            engine.connect(records[i], to: reverbs[i], format: recordedFile.processingFormat)
            engine.connect(reverbs[i], to: pitches[i], format: recordedFile.processingFormat)
            engine.connect(pitches[i], to: distortions[i], format: recordedFile.processingFormat)
            engine.connect(distortions[i], to: mixers[i], format: recordedFile.processingFormat)
            
            engine.connect(karas[i], to: fakePitches[i], format: karaFile.processingFormat)
            engine.connect(fakePitches[i], to: mixers[i], format: karaFile.processingFormat)
            engine.connect(mixers[i], to: fakeMixer, format: engine.mainMixerNode.inputFormat(forBus: 0))
            engine.connect(fakeMixer, to: engine.mainMixerNode, format: engine.mainMixerNode.inputFormat(forBus: 0))
            karas[i].scheduleBuffer(karaBuffer, at: nil, options: [], completionHandler: nil)
            records[i].scheduleBuffer(recordedBuffer, at: nil, options: [], completionHandler: nil)
            
        }
        
        
        
//          NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidPlayToEndTime), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
        
       
    
        
        /*
        mixer = AVAudioMixerNode()
        pitch = AVAudioUnitTimePitch()
        reverb = AVAudioUnitReverb()
        fakePitch = AVAudioUnitTimePitch()
        engine.attach(fakePitch)
        engine.attach(pitch)
        engine.attach(reverb)
        engine.attach(karaNode)
        engine.attach(recordedNode)
        engine.attach(mixer)
        

        
        engine.connect(recordedNode, to: reverb, format: recordedFile.processingFormat)
        engine.connect(reverb, to: pitch, format: recordedFile.processingFormat)
        engine.connect(pitch, to: mixer, format: recordedFile.processingFormat)
        
        engine.connect(karaNode, to: fakePitch, format: karaFile.processingFormat)
        engine.connect(fakePitch, to: mixer, format: karaFile.processingFormat)
        engine.connect(mixer, to: engine.mainMixerNode, format: engine.mainMixerNode.inputFormat(forBus: 0))
        karaNode.scheduleBuffer(karaBuffer, at: nil, options: [], completionHandler: nil)
        recordedNode.scheduleBuffer(recordedBuffer, at: nil, options: [], completionHandler: nil)
        */
        
        
        self.renderMode = !sound
        if sound{
            fakeMixer.volume = 1
        }else{
            fakeMixer.volume = 0
        }
        
        
        do{
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord , with: .defaultToSpeaker)
            try AVAudioSession.sharedInstance().setActive(true)
            try engine.start()
        } catch {
            print(error)
        }
        
    }
    
    
    public func setNotification(){
        
         NotificationCenter.default.addObserver(self, selector: #selector(configurationChanged), name: NSNotification.Name.AVAudioEngineConfigurationChange , object: self.engine)
    }
    
    @objc func configurationChanged(){
        
        do{
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord , with: .defaultToSpeaker)
            try AVAudioSession.sharedInstance().setActive(true)
            try engine.start()
           
            
        } catch {
            print(error)
        }
        
        if self.karas[0].isPlaying{
            self.pause()
            self.play()
        }
    }
    
    public func removeNotification(){
        NotificationCenter.default.removeObserver(self)
        
    }
    
    func setting(volume: Float, pitch: Float, Speed: Float){
        
        
        for i in 0...pieces - 1 {
//            self.karas[i].volume = volume
            self.fakePitches[i].pitch = pitch
            self.fakePitches[i].rate = Speed
            
        }
        
    }
    
    
        func setMixer(effect : soundFx){
            self.noEffect()
            
            switch effect {
            case .none :
                break
            case .helium:
                for i in 0...pieces-1{
                    pitches[i].pitch = 1200
                }
                break
            case .reverb:
                for i in 0...pieces-1{
                    reverbs[i].wetDryMix = 50
                    
                }
            case .grunge:
                for i in 0...pieces-1{
                   
                    distortions[i].loadFactoryPreset(.speechWaves)
                    distortions[i].bypass = false
                    distortions[i].wetDryMix = 30
                    
                }
            case .multiline:
                for i in 0...pieces-1{
                    distortions[i].loadFactoryPreset(.multiEcho1)
                    distortions[i].bypass = false
                    distortions[i].wetDryMix = 50
                    
                }
            default:
                break
            }
    }
    

    
    private func noEffect(){
        
        for i in 0...self.pieces - 1{
            pitches[i].pitch = 0
            reverbs[i].wetDryMix = 0
            distortions[i].bypass = true
        }
    }
    
    func play(){
        if !engine.isRunning{
            do {
                try engine.start()
                
            }
            catch{
                print(error)
            }
        }
        
        for i in 0...pieces-1{
            karas[i].play()
            records[i].play()
        }
        
    }
    
    func pause(){
        
        for i in 0...pieces-1{
            karas[i].pause()
            records[i].pause()
        }
    }
    
    func stop(){
        
        for i in 0...pieces-1{
            karas[i].stop()
            records[i].stop()
        }
    }
    
    func soundOn(){
        fakeMixer.volume = 1
    }
    
    func soundOff(){
        fakeMixer.volume = 0
    }
    
    func seekTo(second: Double, duration: Float, index: Int = 0){
        
        
        karas[index].play()
        records[index].play()

        if let karaNodetime: AVAudioTime  = karas[index].lastRenderTime{
            if let Nodetime: AVAudioTime  = records[index].lastRenderTime{
                
       
        let length = duration - Float(second)
       
        let karaPlayerTime: AVAudioTime = karas[index].playerTime(forNodeTime: karaNodetime)!
        let karaSampleRate = karaPlayerTime.sampleRate
        let karaNewsampletime = AVAudioFramePosition(karaSampleRate * second)
        let karaFramestoplay = AVAudioFrameCount(Float(karaPlayerTime.sampleRate) * length)
        
        
        
        let PlayerTime: AVAudioTime = records[index].playerTime(forNodeTime: Nodetime)!
        let SampleRate = PlayerTime.sampleRate
        let Newsampletime = AVAudioFramePosition(SampleRate * second)
        let Framestoplay = AVAudioFrameCount(Float(PlayerTime.sampleRate) * length)
        
          
                
        karas[index].stop()
        records[index].stop()

        if Framestoplay > 1000 {
            records[index].scheduleSegment(recordedFile, startingFrame: Newsampletime, frameCount: Framestoplay, at: nil,completionHandler: nil)
            karas[index].scheduleSegment(karaFile, startingFrame: karaNewsampletime, frameCount: karaFramestoplay, at: nil,completionHandler: nil)
        }
            }
        }
    }
    
    
  /*  func getToNextFrame(duration : Float, second: Double){

        if let karaNodetime: AVAudioTime  = self.karaNode.lastRenderTime{
            if let Nodetime: AVAudioTime  = self.recordedNode.lastRenderTime{


                let length = duration - Float(second)
                let karaPlayerTime: AVAudioTime = self.karaNode.playerTime(forNodeTime: karaNodetime)!
                let karaSampleRate = karaPlayerTime.sampleRate
                let karaNewsampletime = AVAudioFramePosition(karaSampleRate * second)
                let karaFramestoplay = AVAudioFrameCount(Float(karaPlayerTime.sampleRate) * length)



                let PlayerTime: AVAudioTime = self.recordedNode.playerTime(forNodeTime: Nodetime)!
                let SampleRate = PlayerTime.sampleRate
                let Newsampletime = AVAudioFramePosition(SampleRate * second)
                let Framestoplay = AVAudioFrameCount(Float(PlayerTime.sampleRate) * length)

                self.pause()
                
                if Framestoplay > 1000 {
                    recordedNode.scheduleSegment(recordedFile, startingFrame: Newsampletime, frameCount: Framestoplay, at: nil,completionHandler: nil)
                    karaNode.scheduleSegment(karaFile, startingFrame: karaNewsampletime, frameCount: karaFramestoplay, at: nil,completionHandler: nil)
                }
                self.play()
            }
        }


    }*/
    
    /*
    func render(duration: Double, completionHandler: @escaping (URL?) -> ()){
        let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let currentDateTime = NSDate()
        let formatter = DateFormatter()
        formatter.dateFormat = "ddMMyyyy-HHmmss"
        let date = formatter.string(from: currentDateTime as Date)
        
        let karaAudioName = [dirPath, date + "FINAL.caf"]
        let url = NSURL.fileURL(withPathComponents: karaAudioName)
        
        
        self.stop()
        self.engine.mainMixerNode.volume = 0
        self.seekTo(second: 0.0 , duration: Float(duration))
        self.play()
        
        do{
            let tapBuffer = AVAudioFrameCount( 4096*4 )
            
            try self.outputFile = AVAudioFile(forWriting: url!, settings: self.mixer.outputFormat(forBus: 0).settings)
            self.mixer.installTap(onBus: 0, bufferSize: tapBuffer , format:self.mixer.outputFormat(forBus: 0), block:{ buffer, when in
                do{
                    try self.outputFile.write(from: buffer)
                }
                catch {
                    print(NSString(string: "Kara Write failed"))
                }})
        }catch{
            print("rendering Failed")
            print(error)
            completionHandler(nil)
        }
        
        
        if #available(iOS 10.0, *) {
            Timer.scheduledTimer(withTimeInterval: duration, repeats: false, block: {
                _ in
                self.mixer.removeTap(onBus: 0)
                self.stop()
                self.engine.stop()
                print("RENDER PART SUCCESFULLY FINISHED")
                completionHandler(url!)
            })
        } else {
            // Fallback on earlier versions
        }
    }
  */
    
    public func setPlaybackVolume(volume: Float){
        
        for i in 0...pieces-1{
            karas[i].volume = volume
        }
        
    }
    
    public func setYourVolume(volume: Float){
        for i in 0...pieces-1{
            records[i].volume = volume
        }
    }
    
    
    
    func renderChunk(index: Int, chunckLength: Double , duration: Double, urlString: String ){
        
        
//        let delay = 0.116
        records[index].play()
        karas[index].play()
        
        let url = URL(string: urlString)
        
        do{
            let tapBuffer = AVAudioFrameCount( 4096 )
            
            try self.outputFiles[index] = AVAudioFile(forWriting: url!, settings: self.mixers[index].outputFormat(forBus: 0).settings)
            mixers[index].installTap(onBus: 0, bufferSize: tapBuffer , format:mixers[index].outputFormat(forBus: 0), block:{ buffer, when in
                do{
                    if self.records[index].isPlaying && self.karas[index].isPlaying{
                    
                        try self.outputFiles[index].write(from: buffer)
                    }
                    else{
                        self.mixers[index].removeTap(onBus: 0)
                    }
                }
                catch {
                    print(NSString(string: "Kara Write failed"))
                }})
        }catch{
            print("rendering part \(index) Failed")
            print(error)
            
        }
        
    }
    
    func stopRendering(){
        
        
        for i in 0...self.pieces - 1{
            
            self.records[i].pause()
            self.karas[i].pause()
            
        }

        self.karaFile = nil
        self.recordedFile = nil
        self.karaBuffer = nil
        self.recordedBuffer = nil
        
    }
    
    
    

}
*/













