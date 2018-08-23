//
//  Karaoke_TableViewCell.swift
//  Canto
//
//  Created by WhoTan on 11/14/17.
//  Copyright © 2017 WhoTan. All rights reserved.
//

import UIKit

class Genre_TableViewCell: UITableViewCell {

    @IBOutlet weak var GenreNameLabel: UILabel!
    @IBOutlet weak var MoreButton: UIButton!
    
    @IBOutlet private weak var KaraokeCollectionView: UICollectionView!
    
    
    
    
    
    var collectionViewOffset: CGFloat {
        get {return KaraokeCollectionView.contentOffset.x}
        set {KaraokeCollectionView.contentOffset.x = newValue}
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: false)
    }
    
    func setCollectionViewDataSourceDelegate
        <D: UICollectionViewDataSource & UICollectionViewDelegate>
        (dataSourceDelegate: D, forRow row: Int) {
        
        KaraokeCollectionView.delegate = dataSourceDelegate
        KaraokeCollectionView.dataSource = dataSourceDelegate
        KaraokeCollectionView.tag = row
        KaraokeCollectionView.reloadData()
    }

}
