//
//  SearchViewController.swift
//  Canto
//
//  Created by WhoTan on 1/18/18.
//  Copyright © 2018 WhoTan. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchPlease: UILabel!
    @IBOutlet weak var searchTFTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var resultCollectionView: UICollectionView!
    @IBOutlet weak var resultLabel: UILabel!
    
    var results = genre_more()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        
        resultCollectionView.register(UINib(nibName: "KaraokeCard", bundle: nil), forCellWithReuseIdentifier: "KaraokeCard")
        self.navigationController?.navigationBar.setValue(true, forKey: "hidesShadow")
        self.navigationItem.title = ""
        
        DispatchQueue.global(qos: .background).async {
            self.results = AppManager.sharedInstance().getGenreMoreKaras(genreURL: AppGlobal.PopularKaraokesGenre)
            DispatchQueue.main.async {
                if self.results.count > 0 {
                    self.resultCollectionView.reloadData()
                    self.resultCollectionView.isHidden = false
                    self.searchPlease.isHidden = true
                }else{
                    self.searchPlease.isHidden = false
                    self.resultCollectionView.isHidden = true
                }
            }
        }
        self.navigationItem.title = "جستجو"
		
		searchTextField.attributedPlaceholder = NSAttributedString(string: "جست و جو",
															   attributes: [NSAttributedStringKey.foregroundColor: UIColor.lightGray])
    }
    
    override func viewDidAppear(_ animated: Bool) {
        AppManager.sharedInstance().addAction(action: "View Did Appear", session: "Search", detail: "")
        let tap = UITapGestureRecognizer { (gesture:UIGestureRecognizer?) in
            self.searchTextField.resignFirstResponder()
        }
        tap?.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap!)
        
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        AppManager.sharedInstance().addAction(action: "View Did Disappear", session: "Search", detail: "")
        if searchPlease.text ==  "نتیجه ای یافت نشد" {
            self.searchPlease.text = "آهنگ مورد نظر را جست و جو کنید"
            DispatchQueue.global(qos: .background).async {
                self.results = AppManager.sharedInstance().getGenreMoreKaras(genreURL: AppGlobal.PopularKaraokesGenre)
                DispatchQueue.main.async {
                    if self.results.count > 0 {
                        self.resultCollectionView.reloadData()
                        self.resultCollectionView.isHidden = false
                        self.searchPlease.isHidden = true
                    }else{
                        self.searchPlease.isHidden = false
                        self.resultCollectionView.isHidden = true
                    }
                    
                }
            }
        }
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
    
}

extension SearchViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate {
    
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
        AppManager.sharedInstance().addAction(action: "Karaoke Tapped", session: "Search", detail: self.results.results[indexPath.row].id.description )
        let dialogue = DialougeView()
        dialogue.chooseKaraType(kara: self.results.results[indexPath.row], sender: self)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.row + 3 == self.results.results.count && !self.results.next.isEmpty{
            self.setCollectionView(nextPage: true)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y < 0 {
            searchTFTopConstraint.constant = 8 - scrollView.contentOffset.y
        }else{
            searchTFTopConstraint.constant = 8
        }
    }
}
