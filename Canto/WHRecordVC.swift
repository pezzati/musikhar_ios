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
    
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var fullScreenConstraint: NSLayoutConstraint!
    @IBOutlet weak var squareConstraint: NSLayoutConstraint!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var recordingToolbarView: UIView!
    
    @IBOutlet weak var darkLayerView: UIView!
    
    public var post : karaoke?
    public var original = false
    var mode : Modes!
    var cameraHelper : CameraHelper?
    var isSquare = true
    var isFrontCamera = true
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.isNavigationBarHidden = true
        setup()
    }
    
    @IBAction func closeTapped(_ sender: Any) {
        
        navigationController?.popViewController(animated: true)
        navigationController?.isNavigationBarHidden = false
    }
    
    func setup(){
        closeButton.setImage(#imageLiteral(resourceName: "close").maskWithColor(color: UIColor.white), for: .normal)
        if mode != .karaoke {
            cameraHelper = CameraHelper(inView: cameraView)
            cameraView.isHidden = false
            darkLayerView.isHidden = false
            recordingToolbarView.isHidden = false
        }
    }
    
    //MARK: -Recording Toolbar Actions
    
    @IBAction func recordTapped(_ sender: UIButton) {
    }
    
    @IBAction func rotateTapped(_ sender: UIButton) {
        cameraHelper?.rotateCamera(front: !isFrontCamera, inView: cameraView)
        isFrontCamera = !isFrontCamera
    }
    
    @IBAction func toggleRatioTapped(_ sender: UIButton) {
        
        if self.isSquare{
            self.squareConstraint.priority = UILayoutPriority(rawValue: 998)
            self.fullScreenConstraint.priority = UILayoutPriority(rawValue: 999)
            sender.setTitle("Square", for: .normal)
        }else{
            self.squareConstraint.priority = UILayoutPriority(rawValue: 999)
            self.fullScreenConstraint.priority = UILayoutPriority(rawValue: 998)
            sender.setTitle("Full", for: .normal)
        }
        self.isSquare = !self.isSquare
        self.view.layoutIfNeeded()
        self.cameraHelper?.updateView(inView: self.cameraView)
    }
    
    @IBAction func settingTapped(_ sender: UIButton) {
    }
}























