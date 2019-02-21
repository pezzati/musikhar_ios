//
//  WHSlider.swift
//  Canto
//
//  Created by Whotan on 10/26/18.
//  Copyright © 2018 WhoTan. All rights reserved.
//

import UIKit

protocol WHSliderDelegate: class {
	func valueChanged(sender: WHSlider, percent: Float)
}

class WHSlider: UIView {

	var backgroundDarkLayer : UIView!
	var fillerView : UIView!
	var panGesture : UIPanGestureRecognizer!
	var imageView : UIImageView!
	var delegate : WHSliderDelegate?
	
	var minimumValue = 0
	var maximumValue = 100
	var currentValue : CGFloat = 50
	
	var type : controller!
	var isActive = true
	var imageName = ""
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		initMe()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		initMe()
	}
	
	func initMe() {
		backgroundColor = UIColor.clear
		layer.cornerRadius = 15
		let blurEffect = UIBlurEffect(style: .light)
		let backgroundDarkLayer = UIVisualEffectView(effect: blurEffect)
		backgroundDarkLayer.frame = bounds
		backgroundDarkLayer.clipsToBounds = true
		clipsToBounds = true
		addSubview(backgroundDarkLayer)
		fillerView = UIView(frame: CGRect(x: 0, y: frame.height/2, width: frame.width, height: frame.height/2))
		fillerView.backgroundColor = UIColor.white
		fillerView.clipsToBounds = true
		backgroundDarkLayer.contentView.addSubview(fillerView)
		
		imageView = UIImageView()
		imageView.frame.size = CGSize(width: 40, height: 40)
		imageView.frame.origin = CGPoint(x: 16.25, y: 60)
		imageView.backgroundColor = UIColor.clear
		imageView.contentMode = .scaleAspectFit
		backgroundDarkLayer.contentView.addSubview(imageView)

		panGesture = UIPanGestureRecognizer(target: self, action: #selector(draggedView(_:)))
		isUserInteractionEnabled = true
		addGestureRecognizer(panGesture)
		alpha = 0
		
//		if type == controller.micVolume{
//			currentValue = 50
//			fillerView.frame = CGRect(x: 0, y: 0, width: frame.width, height: 0)
//		}
		
		
	}
	
	func setup(of controllerType: controller){
		type = controllerType
		imageName = controllerType.rawValue
		imageView.image = UIImage(named: imageName + "_mid")
		
//		if type == controller.micVolume{
//			currentValue = 50
//			fillerView.frame = CGRect(x: 0, y: 0, width: frame.width, height: 0)
//			delegate?.valueChanged(sender: self, percent: 0)
//		}
		
		UIView.animate(withDuration: 1, animations: {
			self.alpha = 1
		})
	}
	
	func inactivate(){
		alpha = 0.5
		isActive = false
	}
	
	func activate(){
		alpha = 1
		isActive = true
	}
	
	@objc func draggedView(_ sender: UIPanGestureRecognizer) {
		
		if !isActive { return }
		
		let translation = sender.translation(in: self)
		
		if sender.state == .began{
			return
		}else if sender.state == .changed || sender.state == .ended {
			currentValue = -translation.y/2 + currentValue
			sender.setTranslation(CGPoint.zero, in: self)
			if currentValue > 100 { currentValue = 100}
			if currentValue < 0 { currentValue = 0 }
			fillerView.frame = CGRect(x: 0, y: self.frame.height*(100 - currentValue)/100, width: self.frame.width, height: currentValue/100*self.frame.height)
			
			if delegate != nil {
				
				switch currentValue {
				case 0 ... 30:
					imageView.image = UIImage(named: imageName + "_low")
					break
				case 31 ... 60:
					imageView.image = UIImage(named: imageName + "_mid")
					break
				case 61 ... 100:
					imageView.image = UIImage(named: imageName + "_high")
					break
				default:
					break
				}
				
				delegate?.valueChanged(sender: self, percent: Float(currentValue/100))
			}
		}
		
	}
	

}
