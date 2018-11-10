//
//  WHTrimmer.swift
//  Canto
//
//  Created by Whotan on 11/3/18.
//  Copyright © 2018 WhoTan. All rights reserved.
//

import UIKit

protocol WHTrimmerDelegate: class {
	func valueChanged(sender: WHTrimmer, minVal: Float, maxVal: Float)
}

class WHTrimmer: UIView {

	var baseLine: UIView!
	var minThumb: UIImageView!
	var maxThumb: UIImageView!
	var trimLine: UIView!
	var playingLine: UIView!
	var minGesture: UIPanGestureRecognizer!
	var maxGesture: UIPanGestureRecognizer!
	var maxLength = 0.7
	var minLength = 0.3
	var minValue = 0.0
	var maxValue = 0.5
	var delegate : WHTrimmerDelegate?

	override init(frame: CGRect) {
		super.init(frame: frame)
		initMe()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		initMe()
	}
	
	func initMe(){
		
		baseLine = UIView()
		baseLine.backgroundColor = UIColor.lightGray
		baseLine.layer.cornerRadius = 5
		baseLine.clipsToBounds = true
		addSubview(baseLine)
		
		trimLine = UIView()
		trimLine.layer.cornerRadius = 5
		trimLine.backgroundColor = UIColor.white
		trimLine.clipsToBounds = true
		
		
		playingLine = UIView(frame: CGRect.zero)
//		playingLine.round(corners: [.topRight, .bottomRight], radius: 5)
		playingLine.backgroundColor = UIColor.green
		playingLine.clipsToBounds = true
		trimLine.addSubview(playingLine)
		
		minThumb = UIImageView(image: UIImage(named: "thumb_min"))
		minThumb.contentMode = .scaleAspectFit
		addSubview(minThumb)
		
		maxThumb = UIImageView(image: UIImage(named: "thumb_max"))
		maxThumb.contentMode = .scaleAspectFit
		addSubview(maxThumb)
		
		addSubview(trimLine)
	}
	
	func setup(max: Double , min: Double){
		minLength = min
		maxLength = max
		minValue = 0
		maxValue = max
		
		minGesture = UIPanGestureRecognizer(target: self, action: #selector(draggedMin(_:)))
		minThumb.addGestureRecognizer(minGesture)
		minThumb.isUserInteractionEnabled = true
		maxGesture = UIPanGestureRecognizer(target: self, action: #selector(draggedMax(_:)))
		maxThumb.addGestureRecognizer(maxGesture)
		maxThumb.isUserInteractionEnabled = true
		isUserInteractionEnabled = true
		updateLayout()
		alpha = 1
	}
	
	func updateLayout(){
		baseLine.frame = CGRect(x: 15, y: 15, width: frame.width - 30, height: 10)
		minThumb.frame = CGRect(x: CGFloat(minValue)*(frame.width - 30), y: 5, width: 30, height: 30)
		maxThumb.frame = CGRect(x: (frame.width - 30)*CGFloat(maxValue), y: 5, width: 30, height: 30)
		trimLine.frame = CGRect(x: minThumb.frame.midX, y: 15,width: maxThumb.frame.midX - minThumb.frame.midX, height: 10)
	}
	
	func updatePlayLine(end: Double){
		
		let length = end - minValue
		if length > maxLength || length < 0{ return }
		playingLine.alpha = 1
		playingLine.frame = CGRect(x: 15, y: 0, width: CGFloat(length/(maxValue-minValue))*(trimLine.frame.width - 30)  , height: 10)
		
	}
	
	@objc func draggedMax(_ sender: UIPanGestureRecognizer) {
		
		let translation = sender.translation(in: self)
		
		if sender.state == .began{
			return
		}else if sender.state == .changed || sender.state == .ended {
			let newVal = maxValue + Double((translation.x)/(frame.width-30))
			if newVal > 1 || newVal < minValue {
				return
			}
			
			if newVal - minValue > maxLength || newVal - minValue < minLength{
				if minValue + Double((translation.x)/(frame.width-30)) < 0 { return }
				minValue = minValue + Double((translation.x)/(frame.width-30))
			}
			
			maxValue = newVal
			sender.setTranslation(CGPoint.zero, in: self)
			playingLine.alpha = 0
			updateLayout()
			
			if delegate != nil {
				delegate?.valueChanged(sender: self, minVal: Float(minValue), maxVal: Float(maxValue))
			}
		}
	}
	
	@objc func draggedMin(_ sender: UIPanGestureRecognizer) {
		
		let translation = sender.translation(in: self)
		
		if sender.state == .began{
			return
		}else if sender.state == .changed || sender.state == .ended {
			let newVal = minValue + Double((translation.x)/(frame.width-30))
			
			if newVal < 0 || newVal > maxValue {
				return
			}
			
			if maxValue - newVal > maxLength || maxValue - newVal < minLength{
				if maxValue + Double((translation.x)/(frame.width-30)) > 1 { return }
				maxValue = maxValue + Double((translation.x)/(frame.width-30))
			}
			
			minValue = newVal
			sender.setTranslation(CGPoint.zero, in: self)
			playingLine.alpha = 0
			updateLayout()
			
			if delegate != nil {
				delegate?.valueChanged(sender: self, minVal: Float(minValue), maxVal: Float(maxValue))
			}
			
		}
	}

}
