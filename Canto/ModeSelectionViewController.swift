//
//  ModeSelectionViewController.swift
//  Canto
//
//  Created by Whotan on 10/6/18.
//  Copyright © 2018 WhoTan. All rights reserved.
//

import UIKit

class ModeSelectionViewController: UIViewController {

    @IBOutlet weak var carousel: iCarousel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        carousel.dataSource = self
        carousel.delegate = self
        carousel.type = .linear
        carousel.isPagingEnabled = true
    }
    
}

extension ModeSelectionViewController : iCarouselDelegate, iCarouselDataSource {
    
    func numberOfItems(in carousel: iCarousel) -> Int {
        return 3
    }
    
    func carousel(_ carousel: iCarousel, viewForItemAt index: Int, reusing view: UIView?) -> UIView {
        let cardView = UIView()
        
        switch index {
        case 0:
            cardView.backgroundColor = UIColor.white
            break
        case 1:
            cardView.backgroundColor = UIColor.red
            break
        case 2:
            cardView.backgroundColor = UIColor.blue
            break
        default:
            break
        }
        cardView.frame = CGRect(x: 0, y: 0, width: carousel.frame.height/1.8, height: carousel.frame.height)
        return cardView
    }
    
    func carousel(_ carousel: iCarousel, valueFor option: iCarouselOption, withDefault value: CGFloat) -> CGFloat {
        
        if option == iCarouselOption.spacing {
            return 1.2
        }
        return value
    }
    
    
}
