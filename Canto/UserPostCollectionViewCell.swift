//
//  UserPostCollectionViewCell.swift
//  Canto
//
//  Created by Whotan on 10/6/18.
//  Copyright © 2018 WhoTan. All rights reserved.
//

import UIKit

class UserPostCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var karaImage: UIImageView!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var songNameLabel: UILabel!
    @IBOutlet weak var karaSizeConstraint: NSLayoutConstraint!
    
    var karaImageGradient1 : CALayer!
    var karaImageGradient2 : CALayer!
    var postImageGradient1: CALayer!
    var postImageGradient2: CALayer!
    var subViewsAdded = false
    
    func setUp(post : userPost){
        
        artistLabel.text = post.kara.artist.name.count == 0 ? post.kara.name : post.kara.artist.name
        songNameLabel.text = post.kara.name
        postImage.layer.cornerRadius = 10
        karaImage.layer.cornerRadius = 10
        postImage.sd_setImage(with: URL(string: post.kara.cover_photo.link), completed: nil)
        karaImage.sd_setImage(with: URL(string: post.kara.cover_photo.link), completed: nil)
        
        if karaImageGradient1 == nil {
            karaImageGradient1 = karaImage.darkGradiantLayer()
            karaImageGradient2 = karaImage.doubleDarkGradiantLayer()
            postImageGradient1 = postImage.darkGradiantLayer()
            postImageGradient2 = postImage.doubleDarkGradiantLayer()
        }
        
        postImageGradient1.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.width + 1)
        postImageGradient2.frame = CGRect(x: 0, y: self.frame.width - 20, width: self.frame.width, height: 21)
        karaImageGradient1.frame = CGRect(x: 0, y: 0, width: self.frame.width*karaSizeConstraint.multiplier, height: self.frame.width*karaSizeConstraint.multiplier + 1)
        karaImageGradient2.frame = CGRect(x: 0, y: self.frame.width*karaSizeConstraint.multiplier - 5, width: self.frame.width*karaSizeConstraint.multiplier, height: 6)
        
        if subViewsAdded { return }
        karaImage.layer.insertSublayer(karaImageGradient1, at: 0)
        karaImage.layer.insertSublayer(karaImageGradient2, at: 0)
        postImage.layer.insertSublayer(postImageGradient1, at: 0)
        postImage.layer.insertSublayer(postImageGradient2, at: 0)
        subViewsAdded = true
        
        
        
    }
    
}












