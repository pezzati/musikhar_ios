//
//  SearchViewController.swift
//  Canto
//
//  Created by WhoTan on 1/18/18.
//  Copyright © 2018 WhoTan. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource,UITextFieldDelegate, UICollectionViewDelegateFlowLayout {



    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchPlease: UILabel!
    @IBOutlet weak var resultCollectionView: UICollectionView!
    
    var results = genre_more()
    
    
    override func viewDidLoad() {
        headerView.headerViewCornerRounding()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        AppManager.sharedInstance().addAction(action: "View Did Appear", session: "Search", detail: "")
    }

    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        AppManager.sharedInstance().addAction(action: "View Did Disappear", session: "Search", detail: "")
        self.searchPlease.text = "آهنگ مورد نظر را جست و جو کنید"

    }
    
    @IBAction func searchTapped(_ sender: Any) {
        self.textFieldShouldReturn(self.searchTextField)
//        self.searchTextField.resignFirstResponder()
//        if self.searchTextField.text != nil{
//            self.setCollectionView(nextPage: false)
//        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {   //delegate method
        AppManager.sharedInstance().addAction(action: "Search Tapped", session: "Search", detail: self.searchTextField.text ?? "")
         self.searchTextField.resignFirstResponder()
        
        if self.searchTextField.text != nil{
            self.setCollectionView(nextPage: false)
        }
        return true
    }
    
    func setCollectionView(nextPage : Bool = false){
 
        
        let searchText = self.searchTextField.text!.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed )
        var requestURL = AppGlobal.SearchKaraokes + searchText!
        
        if nextPage{ requestURL = self.results.next }
        
        let request = RequestHandler(type: .genrePosts , requestURL: requestURL, shouldShowError: true, sender: self, waiting: !nextPage, force: false)
        
        request.sendRequest(completionHandler: { more_posts, success, msg in
            if success {
                if nextPage{
                let result = more_posts as! genre_more
                self.results.next = (result.next)
                self.results.previous = (result.previous)
                self.results.count = self.results.count + (result.count)
                for item in (result.results){
                    self.results.results.append(item)
                }
                self.resultCollectionView.reloadData()
            }else{
                let result = more_posts as! genre_more
                if result.count != 0{
                self.searchPlease.isHidden = true
                self.results = result
                self.resultCollectionView.reloadData()
                self.resultCollectionView.isHidden = false
                }else{
                    self.searchPlease.isHidden = false
                    self.resultCollectionView.isHidden = true
                    self.searchPlease.text = "نتیجه ای یافت نشد"
                }
            }
            }
        })
    }
    
    //MARK: -Collection View
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
        AppManager.sharedInstance().addAction(action: "Karaoke Tapped", session: "Search", detail: self.results.results[indexPath.row].id.description )
        let dialogue = DialougeView()
        dialogue.chooseKaraType(kara: self.results.results[indexPath.row], sender: self)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.row + 3 == self.results.results.count && !self.results.next.isEmpty{
            self.setCollectionView(nextPage: true)
        }
    }
}
