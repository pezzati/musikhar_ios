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
    var blendFilter = GPUImageOverlayBlendFilter()
	var blendInput : GPUImagePicture!
    var cameraView : GPUImageView?
	var movieWriter: GPUImageMovieWriter!
//	var size = CGSize(width: 720, height: 720)

    init(inView : UIView) {
        cameraView = GPUImageView(frame: inView.bounds)
        inView.addSubview(cameraView!)
		camera = GPUImageVideoCamera(sessionPreset: AVCaptureSession.Preset.high.rawValue , cameraPosition: AVCaptureDevice.Position.front )
		if camera == nil{ return }
		camera.outputImageOrientation = .portrait
		camera.horizontallyMirrorFrontFacingCamera = true
		cameraView?.fillMode = .preserveAspectRatioAndFill

		camera.addTarget(cameraView)
		camera.startCapture()
//		size = CGSize(width: 720, height: Int(Float(720*(inView.frame.height/inView.frame.width))))
	}
    
    func updateView(inView : UIView){
        if cameraView != nil {
            cameraView?.removeFromSuperview()
            cameraView = GPUImageView(frame: inView.bounds)
//			size = CGSize(width: 720.0, height: Double(Float(720*(inView.frame.height/inView.frame.width))))
            cameraView?.fillMode = .preserveAspectRatioAndFill
            inView.addSubview(cameraView!)
            if camera == nil { return }
			camera.horizontallyMirrorFrontFacingCamera = true

//			blendInput = GPUImagePicture(image: CameraHelper.blendLayerImage())
//			blendInput?.processImage()
//			blendInput?.addTarget(blendFilter)
//			camera.addTarget(blendFilter)
//
//			blendFilter.addTarget(cameraView)
			
			
			camera.addTarget(cameraView)
			camera.outputImageOrientation = .portrait
            camera.startCapture()
        }
    }
    
    func rotateCamera(front : Bool, inView : UIView){
		let location : AVCaptureDevice.Position = front ? AVCaptureDevice.Position.front : AVCaptureDevice.Position.back
		camera = GPUImageVideoCamera(sessionPreset: AVCaptureSession.Preset.high.rawValue , cameraPosition: location )
		if camera == nil{ return }
		camera.outputImageOrientation = .portrait
		updateView(inView: inView)
    }
	
	func initiateRecorder(){
		try? FileManager.default.removeItem(at: AppManager.videoURL())
		movieWriter = GPUImageMovieWriter(movieURL: AppManager.videoURL(), size: CGSize(width: 1080, height: 1920))
		if camera == nil{ return }
		camera.horizontallyMirrorFrontFacingCamera = true
		blendInput = GPUImagePicture(image: CameraHelper.blendLayerImage())
		blendInput?.processImage()
		blendInput?.addTarget(blendFilter)
		camera.addTarget(blendFilter)
		blendFilter.addTarget(movieWriter)
	}
	
	
	func startRecording(){
		let when = DispatchTime.now()
		DispatchQueue.main.asyncAfter(deadline: when, execute: {
			if self.movieWriter.assetWriter.status.rawValue == 0{
				self.movieWriter.startRecording()
			}
		})
		
	}
	
	func stopRecording(){
		movieWriter.finishRecording()
	}
    
    
    class func blendLayerImage()->UIImage {

        UIGraphicsBeginImageContext(CGSize(width: 1080, height: 1920))
        let _img = UIImage(named: "watermark")
		_img?.draw(in: CGRect(x: (700 - 270)*1.5, y: 45*1.5, width: 270*1.5, height: 80.0*1.5))
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
