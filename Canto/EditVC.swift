//
//  EditVC.swift
//  Canto
//
//  Created by Whotan on 11/14/18.
//  Copyright © 2018 WhoTan. All rights reserved.
//

import UIKit
import GPUImage
import AVFoundation

class EditVC: UIViewController {

	@IBOutlet weak var videoView: RenderView!
	
	public var mode : Modes!
	var movie : MovieInput!
	var filter = SaturationAdjustment()
	
	
	override var prefersStatusBarHidden: Bool {
		return true
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()

		loadVideo()
	}
	
	func loadVideo(){
		movie = try? MovieInput(url:AppManager.videoURL(), playAtActualSpeed:true)
		movie --> filter --> videoView
		movie.start()
		
		
		
	}

}
