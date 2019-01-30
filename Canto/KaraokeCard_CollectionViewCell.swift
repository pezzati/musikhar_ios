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
	@IBOutlet weak var priceLbl: UILabel!
	@IBOutlet weak var coinIV: UIImageView!
	@IBOutlet weak var coinIVHeightConstraint: NSLayoutConstraint!
	
    
//    var freeBadge = UIImageView()
    var subviewsAdded = false
    var darkGradient : CALayer!
    var bottomDarkGradient : CALayer!
    
    public func animateMe (){
		
//        self.freeBadge = UIImageView(frame: CGRect(x: 5 , y: 5, width: 35, height: 15))
//        self.freeBadge.contentMode = .scaleAspectFit
//        self.freeBadge.image = UIImage(named: "free")
//        self.contentView.addSubview(self.freeBadge)
    }
    
    public func setUp(post : karaoke){
		
        ArtistName.text = post.artist.name.count == 0 ? post.name : post.artist.name
        SongName.text = post.name
        cardImage.layer.cornerRadius = 10
		cardImage.sd_setImage(with: URL(string: post.cover_photo.link), placeholderImage: UIImage(named: "hootan"))
        cardImage.contentMode = .scaleToFill
		
        if darkGradient == nil {
            darkGradient = cardImage.darkGradiantLayer()
            bottomDarkGradient = cardImage.doubleDarkGradiantLayer()
        }
        
        darkGradient.frame = CGRect(x: 0, y: 1, width: self.frame.width, height: self.frame.width + 2)
        bottomDarkGradient.frame = CGRect(x: 0, y: self.frame.width - 20, width: self.frame.width, height: 21)
		
		if post.price == 0 {
			priceLbl.text = "رایگان"
			coinIV.image = UIImage(named: "free")
			coinIVHeightConstraint.constant = 12
			coinIV.isHidden = false
		}else{
			if let item = AppManager.sharedInstance().inventory.posts.first(where: {$0.id == post.id}){
				priceLbl.text = "X\(item.count)"
				coinIV.isHidden = true
			}else{
				priceLbl.text = post.price.description
				coinIV.image = UIImage(named: "coin")
				coinIVHeightConstraint.constant = 15
				coinIV.isHidden = false
			}
		}
		
		animateMe()
		
        if subviewsAdded{ return }
        cardImage.layer.insertSublayer(darkGradient, at: 0)
        cardImage.layer.insertSublayer(bottomDarkGradient, at: 0)
        animateMe()
        subviewsAdded = true
    }
    
}







