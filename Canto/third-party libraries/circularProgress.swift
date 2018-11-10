//
//  CircularProgress.swift
//  CircularProgress-Tutorial
//
//  Created by Aman Aggarwal on 5/18/18.
//  Copyright © 2018 iostutorialjunction.com . All rights reserved.
//
import UIKit

class CircularProgress: UIView {
	
	fileprivate var progressLayer = CAShapeLayer()
	fileprivate var tracklayer = CAShapeLayer()
	fileprivate var progressLabel = UILabel()
	
	/*
	// Only override draw() if you perform custom drawing.
	// An empty implementation adversely affects performance during animation.
	override func draw(_ rect: CGRect) {
	// Drawing code
	}
	*/
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		createCircularPath()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		createCircularPath()
	}
	
	var progressColor:UIColor = UIColor.white {
		didSet {
			progressLayer.strokeColor = progressColor.cgColor
		}
	}
	
	var trackColor:UIColor = UIColor.clear {
		didSet {
			tracklayer.strokeColor = trackColor.cgColor
		}
	}
	
	fileprivate func createCircularPath() {
		self.backgroundColor = UIColor.clear
		self.layer.cornerRadius = self.frame.size.width/2.0
		let circlePath = UIBezierPath(arcCenter: CGPoint(x: frame.size.width / 2.0, y: frame.size.height / 2.0),
									  radius: (frame.size.width - 1.5)/2, startAngle: CGFloat(-0.5 * Double.pi),
									  endAngle: CGFloat(1.5 * Double.pi), clockwise: true)
		
		progressLabel.backgroundColor = UIColor.white
		progressLabel.text = ""
		progressLabel.layer.cornerRadius = (frame.width-10)/2
		progressLabel.frame = CGRect(x: 4, y: 4 , width: frame.width - 8, height: frame.height - 8)
		progressLabel.clipsToBounds = true
		progressLabel.font = UIFont.systemFont(ofSize: 14)
		progressLabel.textAlignment = .center
		addSubview(progressLabel)
		
		tracklayer.path = circlePath.cgPath
		tracklayer.fillColor = UIColor.clear.cgColor
		tracklayer.strokeColor = trackColor.cgColor
		tracklayer.lineWidth = 10.0;
		tracklayer.strokeEnd = 1.0
		layer.addSublayer(tracklayer)
		
		progressLayer.path = circlePath.cgPath
		progressLayer.fillColor = UIColor.clear.cgColor
		progressLayer.strokeColor = progressColor.cgColor
		progressLayer.lineWidth = 8.0;
		progressLayer.strokeEnd = 0.0
		progressLayer.opacity = 0.5
		layer.addSublayer(progressLayer)
		
	}
	
	func setProgressWithAnimation(duration: TimeInterval, value: Float) {
		let animation = CABasicAnimation(keyPath: "strokeEnd")
		animation.duration = duration
		// Animate from 0 (no circle) to 1 (full circle)
		animation.fromValue = Float(progressLayer.strokeEnd)
		animation.toValue = value
		animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
		progressLabel.text = Int(value*100).description + "%"
		progressLayer.strokeEnd = CGFloat(value)
		progressLayer.add(animation, forKey: "animateCircle")
	}
	
}
