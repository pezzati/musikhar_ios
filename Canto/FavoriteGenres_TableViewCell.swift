//
//  FavoriteGenres_TableViewCell.swift
//  Canto
//
//  Created by WhoTan on 12/17/17.
//  Copyright © 2017 WhoTan. All rights reserved.
//

import UIKit

class FavoriteGenres_TableViewCell: UITableViewCell {

    @IBOutlet weak var componentView: UIView!
    
    @IBOutlet weak var checkBox: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        componentView.layer.cornerRadius = 7
        componentView.layer.shadowColor = UIColor.lightGray.cgColor
        componentView.layer.shadowOffset = CGSize(width: 0, height: 2)
        componentView.layer.shadowRadius = 6
        componentView.layer.shadowOpacity = 0.4
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
