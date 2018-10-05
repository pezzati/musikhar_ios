//
//  GenreViewController.swift
//  Canto
//
//  Created by WhoTan on 11/29/17.
//  Copyright © 2017 WhoTan. All rights reserved.
//

import UIKit
import SDWebImage

class GenreViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    public var url : String = ""
    public var name: String = ""
//    public var bannerDesc : String = ""
    public var bannerURL : String = ""
    var results = genre_more()
    
    @IBOutlet weak var headerTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var genre_Label: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.results = AppManager.sharedInstance().getGenreMoreKaras(genreURL: self.url)
        self.collectionView.reloadData()
        self.genre_Label.text = self.name
        self.headerView.headerViewCornerRounding()
        
        self.navigationItem.title = name
        
       /* if results.desc != "" {
            self.descriptionLabel.text = results.desc
            self.descriptionLabel.superview?.layer.cornerRadius = 10
//            self.descriptionLabel.superview?.clipsToBounds = true
            self.descriptionLabel.superview?.backgroundColor = UIColor.white
            self.descriptionLabel.superview?.layer.shadowRadius = 4
            self.descriptionLabel.superview?.layer.shadowOpacity = 0.3
            self.descriptionLabel.superview?.layer.shadowColor = UIColor.darkGray.cgColor
            self.descriptionLabel.superview?.layer.shadowOffset = CGSize(width: 0, height: 2)
            self.descriptionLabel.superview?.isHidden = false
            self.descriptionLabel.isHidden = false
        }else{
            self.descriptionLabel.superview?.isHidden = true
            self.descriptionLabel.isHidden = true
            self.collectionViewTopConstraint.constant = -24
        }  */
//
//        if bannerURL != ""{
//            self.bannerImageWidthConstraint.constant = self.view.frame.width - 25
//            self.bannerImageView.layer.cornerRadius = 10
//            self.bannerImageView.clipsToBounds = true
//            self.bannerImageView.sd_setImage(with: URL(string : self.bannerURL)!, placeholderImage: nil)
//        }else{
//            self.bannerImageWidthConstraint.constant = 0
//        }
        
    }
    
    override func viewDidLoad() {
        
        collectionView.register(UINib(nibName: "KaraokeCard", bundle: nil), forCellWithReuseIdentifier: "KaraokeCard")
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        AppManager.sharedInstance().addAction(action: "View Did Appear", session: "Genre More", detail: name)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        AppManager.sharedInstance().addAction(action: "View Did Disappear", session: "Genre More", detail: name)
    }
    
    func getMorePosts(){
        
        let request = RequestHandler(type: .genrePosts , requestURL: self.results.next, shouldShowError: true, sender: self, waiting: false, force: false)
 
        request.sendRequest(completionHandler: { more_posts, success, msg in
            if success {
                let result = more_posts as! genre_more
                self.results.next = (result.next)
                self.results.previous = (result.previous)
                self.results.count = self.results.count + (result.count)
                for item in (result.results){
                    self.results.results.append(item)
                }
                self.collectionView.isHidden = true
                self.collectionView.reloadData()
                self.collectionView.isHidden = false
            }
        })
    }
    
    
    @IBAction func back(_ sender: Any) {
        AppManager.sharedInstance().addAction(action: "Back Tapped", session: "Genre More", detail: name)
        self.dismiss(animated: true, completion: nil)
    }
    //collection view delegate and source
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.results.results.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellsAcross: CGFloat = 2
        let spaceBetweenCells: CGFloat = 18
        let dim = (collectionView.bounds.width - (cellsAcross - 1) * spaceBetweenCells) / cellsAcross
        return CGSize(width: dim, height: dim*190/140)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "KaraokeCard", for: indexPath) as! KaraokeCard_CollectionViewCell
        let post = self.results.results[indexPath.row]
        cell.setUp(post: post)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        AppManager.sharedInstance().addAction(action: "Karaoke Tapped", session: "Genre More", detail: self.results.results[indexPath.row].id.description)
        let karaType = DialougeView()
        karaType.chooseKaraType(kara: self.results.results[indexPath.row], sender: self)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.row + 3 == self.results.results.count && !self.results.next.isEmpty{
            self.getMorePosts()
        }
    }
    

}
