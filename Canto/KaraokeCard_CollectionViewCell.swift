//
//  KaraokeCard_CollectionViewCell.swift
//  Canto
//
//  Created by WhoTan on 11/14/17.
//  Copyright © 2017 WhoTan. All rights reserved.
//

import UIKit

class KaraokeCard_CollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var cardImage: UIImageView!
    @IBOutlet weak var SongName: UILabel!
    @IBOutlet weak var ArtistName: UILabel!
    @IBOutlet weak var SingButton: UIButton!
    
    var freeBadge = UIImageView()
    var subviewsAdded = false
    var darkGradient : CALayer!
    var bottomDarkGradient : CALayer!
    
    public func addBadge (){

        self.freeBadge = UIImageView(frame: CGRect(x: 5 , y: 5, width: 35, height: 15))
        self.freeBadge.contentMode = .scaleAspectFit
        self.freeBadge.image = UIImage(named: "free")
        self.contentView.addSubview(self.freeBadge)
    }
    
    public func setAsFree(){
        self.freeBadge.isHidden = false
    }
    
    public func setAsPremium(){
        self.freeBadge.isHidden = true
    }
    
    public func setUp(post : karaoke){
        
        ArtistName.text = post.artist.name.count == 0 ? post.name : post.artist.name
        SongName.text = post.name
        cardImage.layer.cornerRadius = 10
        cardImage.sd_setImage(with: URL(string: post.cover_photo.link), completed: nil)
        freeBadge.isHidden = post.is_premium
        
        if darkGradient == nil {
            darkGradient = cardImage.darkGradiantLayer()
            bottomDarkGradient = cardImage.doubleDarkGradiantLayer()
        }
        
        darkGradient.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.width)
        bottomDarkGradient.frame = CGRect(x: 0, y: self.frame.width - 20, width: self.frame.width, height: 20)
        
        if subviewsAdded{ return }
        cardImage.layer.insertSublayer(darkGradient, at: 0)
        cardImage.layer.insertSublayer(bottomDarkGradient, at: 0)
        addBadge()
        freeBadge.isHidden = post.is_premium
        subviewsAdded = true
    }

}







