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
    
    public func initCamera(cameraView : RenderView){
        
//        let blendInput = PictureInput(image: blendLayerImage())
//        blendFilter = AddBlend()
        
        do {
            camera = try Camera(sessionPreset: .hd1280x720 , location: .frontFacing )
            cameraView.fillMode = .preserveAspectRatioAndFill
//            blendInput.processImage()
//            blendInput --> blendFilter
            camera --> cameraView
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
    
    
    
}
