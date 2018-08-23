//
//  MediaHelper.swift
//  Canto
//
//  Created by WhoTan on 4/26/18.
//  Copyright © 2018 WhoTan. All rights reserved.
//

import UIKit
import AVFoundation

class MediaHelper: NSObject {
    
    
    public static func userKaraPic(kara : karaoke) -> UIImage{
        let ratio = UIScreen.main.bounds.width*2/1000
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: ratio*1000, height: ratio*1000))
        view.backgroundColor = UIColor.white
        
        let userPic = UIImageView(frame: CGRect(x: (286)*ratio, y: (286)*ratio, width: 429*ratio, height: 429*ratio))
        userPic.image = AppManager.sharedInstance().userAvatar
        userPic.contentMode = .scaleAspectFill
        userPic.clipsToBounds = true
        
        let coverPhoto = UIImageView(frame: CGRect(x: 0, y: 0, width: ratio*1000, height: ratio*1000))
        coverPhoto.image = UIImage(named: "cover")
        coverPhoto.contentMode = .scaleAspectFit
        
        let karaName = UILabel(frame: CGRect(x: 10*ratio, y: (37)*ratio, width: 380*ratio, height: 30*ratio))
        karaName.textAlignment = .center
        karaName.text = kara.name
        karaName.font = UIFont.boldSystemFont(ofSize: 18.0)
        
        let artistName = UILabel(frame: CGRect(x: 10*ratio, y: (77)*ratio, width: 380*ratio, height: 30*ratio))
        artistName.textAlignment = .center
        artistName.text = kara.artist.name
        artistName.font = UIFont.boldSystemFont(ofSize: 18.0)
        
        view.addSubview(userPic)
        view.addSubview(coverPhoto)
        view.addSubview(karaName)
        view.addSubview(artistName)
        return view.asImage()!
    }
    
    
    public static  func writeSingleImageToMovie(image: UIImage, movieLength: TimeInterval, outputFileURL: URL, completion: @escaping (URL?) -> ()) {
        do {
            
            let imageSize = image.size
            let videoWriter = try AVAssetWriter(outputURL: outputFileURL, fileType: AVFileType.mov)
            let videoSettings: [String: Any] = [AVVideoCodecKey: AVVideoCodecH264,
                                                AVVideoWidthKey: imageSize.width,
                                                AVVideoHeightKey: imageSize.height]
            let videoWriterInput = AVAssetWriterInput(mediaType: AVMediaType.video, outputSettings: videoSettings)
            let adaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: videoWriterInput, sourcePixelBufferAttributes: nil)
            
            if !videoWriter.canAdd(videoWriterInput) {  }
            videoWriterInput.expectsMediaDataInRealTime = true
            videoWriter.add(videoWriterInput)
            
            videoWriter.startWriting()
            let timeScale: Int32 = 600 // recommended in CMTime for movies.
            let halfMovieLength = Float64(movieLength/2.0) // videoWriter assumes frame lengths are equal.
            let startFrameTime = CMTimeMake(0, timeScale)
            let endFrameTime = CMTimeMakeWithSeconds(halfMovieLength, timeScale)
            videoWriter.startSession(atSourceTime: startFrameTime)
            
            guard let cgImage = image.cgImage else { return }
            let buffer: CVPixelBuffer = try self.pixelBuffer(fromImage: cgImage, size: imageSize)
            while !adaptor.assetWriterInput.isReadyForMoreMediaData { usleep(10) }
            adaptor.append(buffer, withPresentationTime: startFrameTime)
            while !adaptor.assetWriterInput.isReadyForMoreMediaData { usleep(10) }
            adaptor.append(buffer, withPresentationTime: endFrameTime)
            
            videoWriterInput.markAsFinished()
            videoWriter.finishWriting {
                completion(outputFileURL)
            }
        } catch {
            completion(nil)
        }
    }
    
    public static func pixelBuffer(fromImage image: CGImage, size: CGSize) throws -> CVPixelBuffer {
        let options: CFDictionary = [kCVPixelBufferCGImageCompatibilityKey as String: true, kCVPixelBufferCGBitmapContextCompatibilityKey as String: true] as CFDictionary
        var pxbuffer: CVPixelBuffer? = nil
        let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(size.width), Int(size.height), kCVPixelFormatType_32ARGB, options, &pxbuffer)
        guard let buffer = pxbuffer, status == kCVReturnSuccess else { throw NSError.init()}
        
        CVPixelBufferLockBaseAddress(buffer, [])
        guard let pxdata = CVPixelBufferGetBaseAddress(buffer) else { throw NSError.init()}
        let bytesPerRow = CVPixelBufferGetBytesPerRow(buffer)
        
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        guard let context = CGContext(data: pxdata, width: Int(size.width), height: Int(size.height), bitsPerComponent: 8, bytesPerRow: bytesPerRow, space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue) else {throw NSError.init()}
        context.concatenate(CGAffineTransform(rotationAngle: 0))
        context.draw(image, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        CVPixelBufferUnlockBaseAddress(buffer, [])
        
        return buffer
    }
    
    public static func cropAndWatermark(capturingVideoPath: URL, silentVideoPath : URL , completionHandler: @escaping (Bool) -> ()){
        
        let videoAsset = AVAsset(url: capturingVideoPath)
        let clipVideoTrack = videoAsset.tracks(withMediaType: .video).first
        let videoDuration = videoAsset.duration
        let videoSize = clipVideoTrack?.naturalSize
        let parentlayer = CALayer()
        let videoLayer = CALayer()
        
        let imglogo = UIImage(named: "watermark")
        let watermarkLayer = CALayer()
        watermarkLayer.contents = imglogo?.cgImage
        let preferredWidthForWatermark = (videoSize?.height)! / 4.5
        watermarkLayer.frame = CGRect(x: 30, y: 30 ,width: preferredWidthForWatermark, height: preferredWidthForWatermark/3.2)
        watermarkLayer.opacity = 0.7
        let estimatedXtoCrop = ((clipVideoTrack?.naturalSize.width)! - (clipVideoTrack?.naturalSize.height)!)/2
        parentlayer.frame = CGRect(x: 0, y: 0, width: (videoSize?.height)!, height: (videoSize?.height)!)
        videoLayer.frame = CGRect(x: 0, y: 0, width: (videoSize?.height)! , height: (videoSize?.height)!)
        

        parentlayer.addSublayer(videoLayer)
        parentlayer.addSublayer(watermarkLayer)
        
        let videoCompostition = AVMutableVideoComposition()
        videoCompostition.renderSize = CGSize(width: (clipVideoTrack?.naturalSize.height)!, height: (clipVideoTrack?.naturalSize.height)!)
        videoCompostition.frameDuration = CMTimeMake(1, 30)
        let instructions = AVMutableVideoCompositionInstruction()
        instructions.timeRange = CMTimeRange(start: kCMTimeZero, duration: videoDuration)
        
        
        let transformer = AVMutableVideoCompositionLayerInstruction(assetTrack: clipVideoTrack!)
        let t : CGAffineTransform = (clipVideoTrack?.preferredTransform)!
        let t1 = t.scaledBy(x: 1, y: -1)
        let t2 = t1.translatedBy(x: -estimatedXtoCrop, y: -(clipVideoTrack?.naturalSize.height)!)
//                 let t2 = t1.translatedBy(x: 0, y: -(clipVideoTrack?.naturalSize.height)!)
        let finalTransform: CGAffineTransform = t2
        transformer.setTransform(finalTransform, at: kCMTimeZero)
        
        videoCompostition.animationTool = AVVideoCompositionCoreAnimationTool(postProcessingAsVideoLayers: [videoLayer], in: parentlayer)
        
        instructions.layerInstructions = [transformer]
        
        videoCompostition.instructions.append(instructions)
        
        let exporter = AVAssetExportSession(asset: videoAsset, presetName: AVAssetExportPresetHighestQuality)
        exporter?.videoComposition = videoCompostition
        exporter?.outputFileType = AVFileType.mp4
        exporter?.shouldOptimizeForNetworkUse = false
        exporter?.outputURL = silentVideoPath
        exporter?.exportAsynchronously(completionHandler: {
            if exporter?.status == .completed{
                DispatchQueue.main.async(execute: {
                print("Video Croppig completed")
                completionHandler(true)
                    })
                do{
//                    try? FileManager.default.removeItem(at: capturingVideoPath)
                }
            }else{
                completionHandler(false)
            }
        })
    }
    
    public static func mixAudioVideo(audio: URL, video: URL, output: URL, completionHandler: @escaping (Bool) -> ()){
        
        let audioAsset = AVAsset(url: audio)
        let videoAsset = AVAsset(url: video)
        let videoDuration = videoAsset.duration
        var audioDuration = audioAsset.duration
        audioDuration.timescale = videoDuration.timescale
        
        let mixComposition = AVMutableComposition()
        let compositionVideoTrack = mixComposition.addMutableTrack(withMediaType: AVMediaType.video, preferredTrackID: kCMPersistentTrackID_Invalid)
        do {
            try compositionVideoTrack?.insertTimeRange(CMTimeRange.init(start: kCMTimeZero, duration: videoDuration) , of: videoAsset.tracks(withMediaType: AVMediaType.video).first!, at: kCMTimeZero)
            
        }
        catch{
            print(error)
            
        }
        
        let compositionAudioTrack = mixComposition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: kCMPersistentTrackID_Invalid)
        do {
            try compositionAudioTrack?.insertTimeRange(CMTimeRange.init(start: kCMTimeZero, duration: videoDuration) , of: audioAsset.tracks(withMediaType: AVMediaType.audio).first!, at: kCMTimeZero)}
        catch{
            print(error)
            
        }
        
        let finalExportSession = AVAssetExportSession(asset: mixComposition, presetName: AVAssetExportPresetHighestQuality)
        finalExportSession?.outputFileType = AVFileType.mp4
        finalExportSession?.outputURL = output
        finalExportSession?.exportAsynchronously(completionHandler: {
            if finalExportSession?.status == .completed{
                
                print("final export session completed successfully")
                try? FileManager.default.removeItem(at: video)
                try? FileManager.default.removeItem(at: audio)
                completionHandler(true)
            }else{
                print("SHIIIIIT")
                completionHandler(false)
                print(finalExportSession?.error ?? "")
                _ = finalExportSession?.status
            }
        })
    }
    
    public static func mixMultipleAudioWithVideo(duration: Double, audio: [ String],delay : Double  , length: Double, video: URL, output: URL, completionHandler: @escaping (Bool) -> ()){
        
        let videoAsset = AVAsset(url: video)
        let videoDuration = CMTime(seconds: duration, preferredTimescale: videoAsset.duration.timescale)
        
        
        print("Duration is : \(videoDuration.seconds) according to Media Helper")
        
//        var timeRangeArray : [CMTimeRange] = []
        
        
        
//        for i in 0...4{
//
//            let startTime = CMTime(seconds: timeRanges[i]  , preferredTimescale: videoDuration.timescale )
//            let endTime = CMTime(seconds: timeRanges[i+1], preferredTimescale: videoDuration.timescale)
//            let timeRange = CMTimeRange(start: startTime, end: endTime)
//            timeRangeArray.append(timeRange)
//        }
        
        var audioArray : [AVAsset] = []
        
        for i in 0...audio.count - 1 {
            let url = URL(string: audio[i])
            let asset = AVAsset(url: url!)
            audioArray.append(asset)
        }
        
        
        let mixComposition = AVMutableComposition()
        let compositionVideoTrack = mixComposition.addMutableTrack(withMediaType: AVMediaType.video, preferredTrackID: kCMPersistentTrackID_Invalid)
        do {
            try compositionVideoTrack?.insertTimeRange(CMTimeRange.init(start: kCMTimeZero, duration: videoDuration) , of: videoAsset.tracks(withMediaType: AVMediaType.video).first!, at: kCMTimeZero)}
        catch{
            print(error)
            
        }
        
        
        var timeRange = CMTimeRange(start: CMTime(seconds:  0.0 , preferredTimescale: videoDuration.timescale), duration: CMTime(seconds: length , preferredTimescale: videoDuration.timescale))
        var startTime = kCMTimeZero
        
        do {

            for i in 0...audioArray.count - 1{
                
                let compositionAudioTrack = mixComposition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: kCMPersistentTrackID_Invalid)
                try compositionAudioTrack?.insertTimeRange(timeRange, of: audioArray[i].tracks(withMediaType: AVMediaType.audio).first!, at: startTime)
                timeRange = CMTimeRange(start: CMTime(seconds:  delay, preferredTimescale: videoDuration.timescale), duration: CMTime(seconds: length, preferredTimescale: videoDuration.timescale))
                startTime = CMTime(seconds: length*Double(i+1)  , preferredTimescale: videoDuration.timescale)
                
                if i == audioArray.count - 2{
                    timeRange = CMTimeRange(start: CMTime(seconds:  delay, preferredTimescale: videoDuration.timescale), duration: CMTime(seconds: videoDuration.seconds - length*Double(audio.count - 1) , preferredTimescale: videoDuration.timescale))
                }
                
            }
            
           
            
        }
        catch{
            print(error)
            completionHandler(false)
        }
        
        let finalExportSession = AVAssetExportSession(asset: mixComposition, presetName: AVAssetExportPresetHighestQuality)
        finalExportSession?.outputFileType = AVFileType.mp4
        finalExportSession?.outputURL = output
        finalExportSession?.exportAsynchronously(completionHandler: {
            if finalExportSession?.status == .completed{
                print("final export session completed successfully")
                try? FileManager.default.removeItem(at: video)
//                try? FileManager.default.removeItem(at: audio)
                completionHandler(true)
            }else{
                print("SHIIIIIT")
                completionHandler(false)
                print(finalExportSession?.error ?? "")
                _ = finalExportSession?.status
            }
        })
    }
    
    
}
