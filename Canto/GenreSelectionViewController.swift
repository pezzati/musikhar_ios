//
//  GenreSelectionViewController.swift
//  Canto
//
//  Created by WhoTan on 12/14/17.
//  Copyright © 2017 WhoTan. All rights reserved.
//

import UIKit

class GenreSelectionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var purpleButton: UIButton!
    @IBOutlet weak var purpleButtonBackground: UIImageView!
    @IBOutlet weak var regularDone: UIButton!
    @IBOutlet weak var backButton: UIButton!
    
    
    var genres : GenresList = GenresList()
    var shouldReturn : Bool = false
    var firstTime : Bool = false
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AppManager.sharedInstance().addAction(action: "View Did Appear", session: "Genre Selection", detail: "")
//        self.genres = AppManager.sharedInstance().getGenreList()
        self.tableView.reloadData()
        if self.genres.results.isEmpty{
//            AppManager.sharedInstance().fetchGenreList(sender: self,force: true, completionHandler: {_ in
//                self.genres = AppManager.sharedInstance().getGenreList()
//                self.tableView.reloadData()
//            })
        }
        
        if firstTime{
            for genre in self.genres.results{
                genre.liked_it = false
            }
            self.tableView.reloadData()
//            AppManager.sharedInstance().fetchHomeFeed(sender: self, force: false, completionHandler: {_ in })
//            AppManager.sharedInstance().fetchBanners(sender: self, completionHandler: {_ in })
			
        }
        
        
        self.purpleButton.isHidden = !self.firstTime
        self.purpleButtonBackground.isHidden = !self.firstTime
        self.backButton.isHidden = firstTime
        self.regularDone.isHidden = firstTime
        
    }

    
    override func viewDidDisappear(_ animated: Bool) {
        AppManager.sharedInstance().addAction(action: "View Did Disappear", session: "Genre Selection", detail: "")
    }
    
    //TableView Delegate and Datasource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.genres.results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Genre", for: indexPath) as! FavoriteGenres_TableViewCell
        
        let genre = self.genres.results[indexPath.row]
        cell.nameLabel.text = genre.name
        if genre.liked_it{
            cell.checkBox.image = UIImage(named : "checked")
        }else{
            cell.checkBox.image = UIImage(named: "unchecked")
        }
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.genres.results[indexPath.row].liked_it = !self.genres.results[indexPath.row].liked_it
        AppManager.sharedInstance().addAction(action: self.genres.results[indexPath.row].liked_it ? "Genre Deselected" : "Genre Selected" , session: "Genre Selection", detail: self.genres.results[indexPath.row].name)
        
        tableView.reloadData()
    } 
    
    
    
    @IBAction func done(_ sender: Any) {
        
        AppManager.sharedInstance().addAction(action: "Done Tapped", session: "Genre Selection", detail: "")
        var favoriteList : [String] = []
        
        for item in self.genres.results{
            if item.liked_it{
                favoriteList.append(item.name)
            }
        }
        
        if favoriteList.count == 0 {
            tableView.shake()
            return
        }
        

        
//        AppManager.sharedInstance().setFavoriteGenres(sender: self, params: favoriteList, completionHandler:{ success in
//            if success{
//
//                UserDefaults.standard.set(self.genres.toJsonString(), forKey: AppGlobal.GenresListCache)
//                AppManager.sharedInstance().getGenreList()
////                AppManager.sharedInstance().fetchHomeFeed(sender: self, completionHandler: { _ in
//
//                if self.shouldReturn{
//                    self.navigationController?.popViewController(animated: true)
//                }else{
//                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "mainTabBar")
//                    self.present(vc!, animated: true, completion: nil)
//                }
////                })
//            }})
    }
    
    @IBAction func back(_ sender: Any) {
        AppManager.sharedInstance().addAction(action: "Back Tapped", session: "Genre Selection", detail: "")
        self.dismiss(animated: true, completion: nil)
    }
    
    

    
}
