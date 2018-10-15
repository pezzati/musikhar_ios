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
    @IBOutlet weak var fullScreenConstraint: NSLayoutConstraint!
    @IBOutlet weak var squareConstraint: NSLayoutConstraint!
    @IBOutlet weak var closeButton: UIButton!
    
    public var post : karaoke?
    public var original = false
    var mode : Modes!
    var cameraHelper = CameraHelper()
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.isNavigationBarHidden = true
        closeButton.setImage(#imageLiteral(resourceName: "close").maskWithColor(color: UIColor.white), for: .normal)
        cameraHelper.initCamera(cameraView: cameraView)
    }
    
    @IBAction func closeTapped(_ sender: Any) {
        
        navigationController?.popViewController(animated: true)
        navigationController?.isNavigationBarHidden = false
    }
    
}
