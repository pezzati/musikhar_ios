//
//  PostListTableViewCell.swift
//  Canto
//
//  Created by WhoTan on 6/19/18.
//  Copyright © 2018 WhoTan. All rights reserved.
//

import UIKit
import SDWebImage
import AVFoundation

class PostListTableViewCell: UITableViewCell {

    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var removeButton: UIButton!
    @IBOutlet weak var pictureImageView: UIImageView!
    @IBOutlet weak var songNameLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var mainSuperView: UIView!
    @IBOutlet weak var mainView: UIView!
    var post : userPost = userPost()
    var fileURL : URL? = nil
    var playerView : UIView? = nil
    var slider : mySlider2? = nil
    var playButton : UIImageView? = nil
    var timerLabel = UILabel()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear
        self.selectedBackgroundView?.backgroundColor = UIColor.white
        self.backgroundColor = UIColor.clear
    }
    
//    override func setSelected(_ selected: Bool, animated: Bool) {
//        selectedBackgroundView?.alpha = 0
//    }
    
    
    public func setupCell(post: userPost){
        
        self.post = post
        
        self.artistNameLabel.text = post.kara.artist.name
        self.songNameLabel.text = post.kara.name
        self.mainSuperView.layer.cornerRadius = 10
        self.mainSuperView.layer.shadowColor = UIColor.lightGray.cgColor
        self.mainSuperView.layer.shadowRadius = 5
        self.mainSuperView.layer.shadowOpacity = 0.5
        self.mainView.layer.cornerRadius = 10
        
        self.mainView.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.pictureImageView.sd_setImage(with: URL(string: post.kara.cover_photo.link) , placeholderImage: UIImage(named: "hootan"))
        
        let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let pathArray = [dirPath, post.file.link]
        self.fileURL = NSURL.fileURL(withPathComponents: pathArray)
    }
    
    
    func expand(playerLayer : AVPlayerLayer){
        
    
        
        self.playerView = UIView(frame:  CGRect(x: 0, y: self.pictureImageView.frame.maxY , width: UIScreen.main.bounds.width - 30 , height: UIScreen.main.bounds.width - 30))
        playButton = UIImageView(frame: CGRect(x: 16, y: (playerView?.frame.maxY)! - 25 - 16, width: 25, height: 25))
        playButton?.image = UIImage(named: "postPlay")
        self.playerView?.backgroundColor = UIColor.clear
        self.playerView?.clipsToBounds = true
        playerLayer.frame = (playerView?.bounds)!
        playerView?.layer.addSublayer(playerLayer)
        mainView.addSubview(playerView!)
        mainView.addSubview(playButton!)
        slider = mySlider2(frame: CGRect(x: 16 + 25 + 5, y: Int((playerView?.frame.maxY)! - 25 - 7.5 - 7.5), width: Int(UIScreen.main.bounds.width - 30 - 46 - 46 - 10) , height: 20))
        slider?.thumbTintColor = UIColor.blue
        slider?.maximumValue = 1.0
        slider?.minimumValue = 0.0
        
        mainView.addSubview(slider!)
        
        timerLabel = UILabel(frame: CGRect(x: Int((slider?.frame.maxX)! + 8) , y: Int(((playButton?.frame.minY)! + 3))   , width: 36, height: 18))
        timerLabel.text = "00:00"
        timerLabel.textAlignment = .center
        
        
        timerLabel.backgroundColor = UIColor.darkGray
        timerLabel.alpha = 0.7
        timerLabel.textColor = UIColor.white
        timerLabel.layer.cornerRadius = 5
        timerLabel.clipsToBounds = true
        timerLabel.font = UIFont.systemFont(ofSize: 12)
        mainView.addSubview(timerLabel)
    }
    
    
    func close(){

        self.playerView?.removeFromSuperview()
        self.playerView = nil
        playButton?.removeFromSuperview()
        playButton = nil
        slider?.removeFromSuperview()
    }
    
}
