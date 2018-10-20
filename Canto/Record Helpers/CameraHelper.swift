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

    var camera : Camera!
    var blendFilter : AddBlend!
    var cameraView : RenderView?

    init(inView : UIView) {
        cameraView = RenderView(frame: inView.bounds)
        inView.addSubview(cameraView!)
        
        do {
            camera = try Camera(sessionPreset: .hd1280x720 , location: .frontFacing )
            cameraView?.fillMode = .preserveAspectRatioAndFill
           
            camera --> cameraView!
            camera.startCapture()
        } catch {
            print("Could not initialize rendering pipeline: \(error)")
        }
    }
    
    func updateView(inView : UIView){
        if cameraView != nil {
            cameraView?.removeFromSuperview()
            cameraView = RenderView(frame: inView.bounds)
            cameraView?.fillMode = .preserveAspectRatioAndFill
            inView.addSubview(cameraView!)
            if camera == nil { return }
            camera --> cameraView!
            camera.startCapture()
        }
    }
    
    func rotateCamera(front : Bool, inView : UIView){
        let location : PhysicalCameraLocation = front ? .frontFacing : .backFacing
        do {
            camera = try Camera(sessionPreset: .hd1280x720 , location: location )
            updateView(inView: inView)
        } catch {
            print("Could not initialize rendering pipeline: \(error)")
        }
    }
    
    
//    func blendLayerImage()->UIImage {
//
//        UIGraphicsBeginImageContext(CGSize(width: 720, height: 720))
//        let _img = UIImage(named: "watermark")
//        _img?.draw(in: CGRect(x: 15, y: 720 - 15 - 80, width: 80*3.2, height: 80))
//        let finalImage = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//
//        return finalImage!
//    }
//
//    let blendInput = PictureInput(image: blendLayerImage())
//    blendFilter = AddBlend()
//    blendInput.processImage()
//    blendInput --> blendFilter
//    
    
    
}
