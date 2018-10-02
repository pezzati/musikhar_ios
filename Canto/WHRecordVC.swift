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
    
    @IBOutlet weak var cameraView: RenderView!
    
    public var post : karaoke?
    public var original = false
    var camera : Camera!
    var blendFilter : AddBlend!
    var sepiaFilter : SepiaToneFilter!
    var movieOutput:MovieOutput? = nil
    var isRecording = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let blendInput = PictureInput(image: blendLayerImage())
        blendFilter = AddBlend()
        sepiaFilter = SepiaToneFilter()

        let cropFilter = Crop()
        cropFilter.cropSizeInPixels = Size(width: 720, height: 720)
        cropFilter.locationOfCropInPixels = Position(point: CGPoint(x: 0, y: 280))

        do {
            camera = try Camera(sessionPreset: .hd1280x720 , location: .frontFacing )
            blendInput.processImage()
            blendInput --> blendFilter
            camera --> sepiaFilter --> cropFilter --> blendFilter --> cameraView
            camera.startCapture()

        } catch {
            fatalError("Could not initialize rendering pipeline: \(error)")
        }
  
    }
    


    func blendLayerImage()->UIImage {
        
        UIGraphicsBeginImageContext(CGSize(width: 720, height: 720))
        let _img = UIImage(named: "watermark")
        _img?.draw(in: CGRect(x: 15, y: 720 - 15 - 80, width: 80*3.2, height: 80))
        let finalImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return finalImage!
        
    }

    @IBAction func capture(_ sender: Any) {
//        if (!isRecording) {
//            do {
//                self.isRecording = true
//                let documentsDir = try FileManager.default.url(for:.documentDirectory, in:.userDomainMask, appropriateFor:nil, create:true)
//                let fileURL = URL(string:"test.mp4", relativeTo:documentsDir)!
//                do {
//                    try FileManager.default.removeItem(at:fileURL)
//                } catch {
//                }
//
//                movieOutput = try MovieOutput(URL:fileURL, size:Size(width:720, height:720), liveVideo:true)
//
////                movieOutput = try MovieOutput(URL: fileURL, size: Size(width:540, height:540), fileType: .mp4, liveVideo: true, settings: videoEncodingSettings as [String : AnyObject])
//                blendFilter --> movieOutput!
//                movieOutput!.startRecording()
//            } catch {
//                fatalError("Couldn't initialize movie, error: \(error)")
//            }
//        } else {
//            movieOutput?.finishRecording{
//                self.isRecording = false
//                self.movieOutput = nil
//            }
//        }
    }
    
    
}
