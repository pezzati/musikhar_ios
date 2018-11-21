//
//  CameraHelper.swift
//  Canto
//
//  Created by Whotan on 10/12/18.
//  Copyright © 2018 WhoTan. All rights reserved.
//

import UIKit
import GPUImage

class CameraHelper: NSObject {

    var camera : GPUImageVideoCamera!
    var blendFilter : GPUImageAddBlendFilter!
    var cameraView : GPUImageView?
	var movieWriter: GPUImageMovieWriter!
	var size = CGSize(width: 720, height: 720)

    init(inView : UIView) {
        cameraView = GPUImageView(frame: inView.bounds)
        inView.addSubview(cameraView!)
		camera = GPUImageVideoCamera(sessionPreset: AVCaptureSession.Preset.hd1280x720.rawValue , cameraPosition: AVCaptureDevice.Position.front )
		if camera == nil{ return }
		camera.outputImageOrientation = .portrait
		cameraView?.fillMode = .preserveAspectRatioAndFill
		camera.addTarget(cameraView)
		camera.startCapture()
		size = CGSize(width: 720, height: Int(Float(720*(inView.frame.height/inView.frame.width))))
	}
    
    func updateView(inView : UIView){
        if cameraView != nil {
            cameraView?.removeFromSuperview()
            cameraView = GPUImageView(frame: inView.bounds)
			size = CGSize(width: 720.0, height: Double(Float(720*(inView.frame.height/inView.frame.width))))
            cameraView?.fillMode = .preserveAspectRatioAndFill
            inView.addSubview(cameraView!)
            if camera == nil { return }
			camera.addTarget(cameraView)
			camera.outputImageOrientation = .portrait
            camera.startCapture()
        }
    }
    
    func rotateCamera(front : Bool, inView : UIView){
		let location : AVCaptureDevice.Position = front ? AVCaptureDevice.Position.front : AVCaptureDevice.Position.back
		camera = GPUImageVideoCamera(sessionPreset: AVCaptureSession.Preset.hd1280x720.rawValue , cameraPosition: location )
		if camera == nil{ return }
		camera.outputImageOrientation = .portrait
		updateView(inView: inView)
    }
	
	func startRecording(){
		try? FileManager.default.removeItem(at: AppManager.videoURL())
		movieWriter = GPUImageMovieWriter(movieURL: AppManager.videoURL(), size: size)
//		let blendInput = GP
//		let blendInput = PictureInput(image: blendLayerImage())
//		blendFilter = AddBlend()
//		blendInput.processImage()
//		blendInput --> blendFilter
//		camera --> blendFilter -->  movieWriter
//		camera --> movieWriter
		if camera == nil{ return }
		camera.addTarget(movieWriter)
		camera.horizontallyMirrorFrontFacingCamera = true
		movieWriter.startRecording()
	}
	
	func stopRecording(){
		movieWriter.finishRecording()
	}
    
    
    func blendLayerImage()->UIImage {

        UIGraphicsBeginImageContext(CGSize(width: CGFloat(size.width), height: CGFloat(size.height)))
        let _img = UIImage(named: "watermark")
		_img?.draw(in: CGRect(x: 15.0, y: Double(size.height - 15 - 80), width: 80*3.2, height: 80.0))
        let finalImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return finalImage!
    }
//
//    let blendInput = PictureInput(image: blendLayerImage())
//    blendFilter = AddBlend()
//    blendInput.processImage()
//    blendInput --> blendFilter
//    
    
    
}
