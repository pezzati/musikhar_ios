//
//  GenreViewController.swift
//  Canto
//
//  Created by WhoTan on 11/29/17.
//  Copyright © 2017 WhoTan. All rights reserved.
//

import UIKit
import SDWebImage

class GenreViewController: UIViewController {
    
    public var url : String = ""
    public var name: String = ""
    //    public var bannerDesc : String = ""
    public var bannerURL : String = ""
    var results = genre_more()
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
//        self.results = AppManager.sharedInstance().getGenreMoreKaras(genreURL: self.url)
		getMorePosts()
        self.collectionView.reloadData()
        self.navigationItem.title = name
    }
    
    override func viewDidLoad() {
        
        collectionView.register(UINib(nibName: "KaraokeCard", bundle: nil), forCellWithReuseIdentifier: "KaraokeCard")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        AppManager.sharedInstance().addAction(action: "View Did Appear", session: "Genre More", detail: name)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        AppManager.sharedInstance().addAction(action: "View Did Disappear", session: "Genre More", detail: name)
    }
    
    func getMorePosts(){
		
		let request = RequestHandler(type: .genrePosts , requestURL: results.count == 0 ? self.url : self.results.next, shouldShowError: true, sender: self, waiting: false, force: false)
        
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
    
    
}


extension GenreViewController : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.results.results.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellsAcross: CGFloat = 2
        let spaceBetweenCells: CGFloat = 11
        let dim = (collectionView.bounds.width - 60 - (cellsAcross - 1) * spaceBetweenCells) / cellsAcross
        return CGSize(width: dim, height: dim*5/4 + 10)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0, 30, 0, 30)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "KaraokeCard", for: indexPath) as! KaraokeCard_CollectionViewCell
        let post = self.results.results[indexPath.row]
        cell.setUp(post: post)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        AppManager.sharedInstance().addAction(action: "Karaoke Tapped", session: "Genre More", detail: self.results.results[indexPath.row].id.description)
//        let karaType = DialougeView()
//        karaType.chooseKaraType(kara: self.results.results[indexPath.row], sender: self)
		AppManager.sharedInstance().karaTapped(post: results.results[indexPath.row], sender: self)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.row + 10 >= self.results.results.count && !self.results.next.isEmpty{
            self.getMorePosts()
        }
    }
    
    
}
