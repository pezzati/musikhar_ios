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
	var delegate : WHSliderDelegate?
	
	var minimumValue = 0
	var maximumValue = 100
	var currentValue : CGFloat = 50
	
	var type : controller!
	
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
		let blurEffect = UIBlurEffect(style: .dark)
		let backgroundDarkLayer = UIVisualEffectView(effect: blurEffect)
		backgroundDarkLayer.frame = bounds
		backgroundDarkLayer.clipsToBounds = true
		clipsToBounds = true
		addSubview(backgroundDarkLayer)
		fillerView = UIView(frame: CGRect(x: 0, y: frame.height/2, width: frame.width, height: frame.height/2))
		fillerView.backgroundColor = UIColor.white
		fillerView.clipsToBounds = true
		backgroundDarkLayer.contentView.addSubview(fillerView)
		
		panGesture = UIPanGestureRecognizer(target: self, action: #selector(draggedView(_:)))
		isUserInteractionEnabled = true
		addGestureRecognizer(panGesture)
		alpha = 0
	}
	
	func setup(of controllerType: controller){
		type = controllerType
		
		UIView.animate(withDuration: 1, animations: {
			self.alpha = 1
		})
	}
	
	@objc func draggedView(_ sender: UIPanGestureRecognizer) {
		
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
				delegate?.valueChanged(sender: self, percent: Float(currentValue/100))
			}
		}
		
	}
	

}
