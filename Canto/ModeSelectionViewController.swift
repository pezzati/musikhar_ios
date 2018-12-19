//
//  ModeSelectionViewController.swift
//  Canto
//
//  Created by Whotan on 10/6/18.
//  Copyright © 2018 WhoTan. All rights reserved.
//

import UIKit
import GPUImage

class ModeSelectionViewController: UIViewController {
    
    @IBOutlet weak var carousel: iCarousel!
	@IBOutlet weak var carouselTopConstraint: NSLayoutConstraint!
	@IBOutlet weak var modeNameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    var camera : GPUImageVideoCamera!
    var post : karaoke!
    
    var attributes : [NSAttributedStringKey: NSMutableParagraphStyle]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        carousel.dataSource = self
        carousel.delegate = self
        carousel.type = .linear
        carousel.isPagingEnabled = true
        carousel.bounces = false
        navigationItem.title = "انتخاب حالت"
        navigationItem.largeTitleDisplayMode = .never
        
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 4
        style.alignment = .right
        attributes = [NSAttributedStringKey.paragraphStyle : style]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        initializeCamera()
		carouselTopConstraint.constant = 120*(UIScreen.main.bounds.height/568.0) - 80
        carousel.reloadData()
        carousel.scroll(toOffset: 0.00001, duration: 0.0001)
    }
    
    func initializeCamera(){
//            camera = try Camera(sessionPreset: .hd1280x720 , location: .frontFacing )
		DispatchQueue.main.async {
			self.camera = GPUImageVideoCamera(sessionPreset:  AVCaptureSession.Preset.hd1280x720.rawValue , cameraPosition: .front)
			if self.camera == nil { return }
			self.camera.horizontallyMirrorFrontFacingCamera = true
			self.camera.outputImageOrientation = .portrait
			self.camera.startCapture()
			self.carousel.reloadData()
		}
    }
}

extension ModeSelectionViewController : iCarouselDelegate, iCarouselDataSource {
    
    func numberOfItems(in carousel: iCarousel) -> Int {
        return 3
    }
    
    func carousel(_ carousel: iCarousel, viewForItemAt index: Int, reusing view: UIView?) -> UIView {
        
        let cardView = UIView()
        let height = carousel.frame.height
        cardView.frame = CGRect(x: 0, y: 0, width: height/1.8, height: height)
		let cameraView = GPUImageView(frame: cardView.bounds)
        cameraView.fillMode = .preserveAspectRatioAndFill
        cardView.addSubview(cameraView)
        if camera != nil {
//            camera --> cameraView
			camera.addTarget(cameraView)
        }
        
        cardView.backgroundColor = UIColor.clear
        cameraView.backgroundColor = UIColor.clear
        
        let blurEffect = UIBlurEffect(style: .light)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame =  CGRect(x: 0, y: 0, width: height/1.8*2 , height: height*2)
        blurView.alpha = 0.6
        let gradient = cardView.selectModeGradient(mode: Modes(rawValue: index)!)
        gradient.frame = CGRect(x: 0, y: 0, width: height/1.8, height: height)
        cameraView.insertSubview(blurView, at: 0)
        cameraView.layer.addSublayer(gradient)
        cameraView.clipsToBounds = true
        
        cardView.layer.cornerRadius = 10
        cardView.clipsToBounds = true
        return cardView
    }
    
    func carousel(_ carousel: iCarousel, valueFor option: iCarouselOption, withDefault value: CGFloat) -> CGFloat {
		
        if option == iCarouselOption.spacing {
//			print(UIScreen.main.bounds.height.description)
//            return 1.2*(568/UIScreen.main.bounds.height)
			return 1 + 30/(carousel.frame.height/1.8)
        }
        return value
    }
    
    func carouselDidScroll(_ carousel: iCarousel) {
        
        for i in 0...carousel.numberOfItems {
            let offset = carousel.offsetForItem(at: i)
            let multiplier = offset > 0 ? offset : -offset
            let height = carousel.frame.height - 40*multiplier
            carousel.itemView(at: i)?.frame = CGRect(x: 0, y: 20*multiplier , width: height/1.8, height: height)
        }
        
        let offset = carousel.offsetForItem(at: carousel.currentItemIndex)
        let _offset = offset > 0 ? offset.truncatingRemainder(dividingBy: 1) : -offset.truncatingRemainder(dividingBy: 1)
        modeNameLabel.alpha = 1 - _offset*2
        descriptionLabel.alpha = 1 - _offset*2
        let currentMode = Modes(rawValue: carousel.currentItemIndex)
        modeNameLabel.text = AppGlobal.modeNames[currentMode!]
        descriptionLabel.attributedText = NSAttributedString(string: AppGlobal.modesDescription[currentMode!]!, attributes: attributes)
  
    }
    
    func carousel(_ carousel: iCarousel, didSelectItemAt index: Int) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "WHRecord") as! WHRecordVC
        vc.post = post
        vc.mode = Modes(rawValue: index)
        navigationController?.pushViewController(vc, animated: true)
    }
    
}





