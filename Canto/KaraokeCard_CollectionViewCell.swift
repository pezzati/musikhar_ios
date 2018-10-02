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
    var BadgeAdded = false
    var gradiantAdded = false
    
    public func addBadge (){
        
        if !self.BadgeAdded{
            self.ArtistName.adjustsFontSizeToFitWidth = true
            self.SongName.adjustsFontSizeToFitWidth = true
            self.freeBadge = UIImageView(frame: CGRect(x: 5 , y: 5, width: 35, height: 15))
            self.freeBadge.contentMode = .scaleAspectFit
            self.freeBadge.image = UIImage(named: "free")
            self.freeBadge.isHidden = true
            self.contentView.addSubview(self.freeBadge)
            self.BadgeAdded = true
        }
    }
    
    public func setAsFree(){
        self.ArtistName.adjustsFontSizeToFitWidth = true
        self.SongName.adjustsFontSizeToFitWidth = true
        self.freeBadge.isHidden = false
    }
    
    public func setAsPremium(){
        self.ArtistName.adjustsFontSizeToFitWidth = true
        self.SongName.adjustsFontSizeToFitWidth = true
        self.freeBadge.isHidden = true
    }
    
    public func setUp(post : karaoke){
        if gradiantAdded{ return }
        cardImage.doubleDarkGradiantLayer()
        cardImage.darkGradiantLayer()
        gradiantAdded = true
    }

}







