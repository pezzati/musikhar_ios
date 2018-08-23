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
    var results = genre_more()
    
    @IBOutlet weak var genre_Label: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.results = AppManager.sharedInstance().getGenreMoreKaras(genreURL: self.url)
        self.collectionView.reloadData()
        self.genre_Label.text = self.name
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
        
        cell.ArtistName.text = post.artist.name
        cell.ArtistName.adjustsFontSizeToFitWidth = true
//        cell.SongName.adjustsFontSizeToFitWidth = true
        cell.SongName.text = post.name
        cell.contentView.layer.cornerRadius = 10
        cell.contentView.backgroundColor = UIColor.white
        cell.contentView.layer.shadowRadius = 4
        cell.contentView.layer.shadowOpacity = 0.3
        cell.contentView.layer.shadowColor = UIColor.darkGray.cgColor
        cell.layer.shadowOffset = CGSize(width: 0, height: 2)
        cell.SingButton.layer.cornerRadius = cell.SingButton.frame.height/2
        cell.cardImage.layer.cornerRadius = 10
        cell.cardImage.sd_setImage(with: URL(string: post.cover_photo.link), placeholderImage: UIImage(named: "hootan"))
        cell.addBadge()
        if !post.is_premium { cell.setAsFree() }
        else{ cell.setAsPremium() }
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
