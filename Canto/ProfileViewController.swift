//
//  ProfileViewController.swift
//  Canto
//
//  Created by WhoTan on 12/13/17.
//  Copyright © 2017 WhoTan. All rights reserved.
//

import UIKit
import SDWebImage
import AVFoundation

class ProfileViewController: UIViewController,UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    
    
    
    @IBOutlet weak var normalUserLabel: UILabel!
    @IBOutlet weak var noPostsView: UIView!
    @IBOutlet weak var premiumImageView: UIImageView!
    @IBOutlet weak var headerTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var songsCollectionView: UICollectionView!
    
    //    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var Name: UILabel!
    @IBOutlet weak var Credit: UILabel!
    
    var userInfo = user()
    var posts : userPostsList = userPostsList()
    
    override func viewDidLoad() {
        songsCollectionView.register(UINib(nibName: "KaraokeCard", bundle: nil), forCellWithReuseIdentifier: "KaraokeCard")
        let genreItem = UIBarButtonItem(image: #imageLiteral(resourceName: "setting"), style: .plain, target: self, action: #selector(self.onSettingClicked))
        self.navigationController?.navigationBar.topItem?.setRightBarButtonItems([genreItem], animated: true)
        self.navigationController?.navigationBar.setValue(true, forKey: "hidesShadow")
        self.view.bringSubview(toFront: headerView)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        DispatchQueue.global(qos: .background).async {
            self.userInfo = AppManager.sharedInstance().getUserInfo()
            self.posts = AppManager.sharedInstance().getUserPostsList()
            DispatchQueue.main.async {
                self.noPostsView.isHidden = self.posts.posts.count != 0
                self.updateInfo()
            }
        }
        
        
        if self.userInfo.first_name == ""{
            AppManager.sharedInstance().fetchUserInfo(sender: self, force: false, completionHandler: {
                _ in
                self.userInfo = AppManager.sharedInstance().getUserInfo()
                self.posts = AppManager.sharedInstance().getUserPostsList()
                self.noPostsView.isHidden = self.posts.posts.count != 0
                self.updateInfo()
            })
        }
        AppManager.sharedInstance().addAction(action: "View Did Appear", session: "Profile", detail: "")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        AppManager.sharedInstance().addAction(action: "View Did Disappear", session: "Profile", detail: "")
    }
    
    @IBAction func editInfo(_ sender: Any) {
        
        AppManager.sharedInstance().addAction(action: "Photo/Name Tapped", session: "Profile", detail: "")
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "PhotoPicker") as? ProfilePictureViewController
        vc!.isFirstTime = false
        self.present(vc!, animated: true, completion: nil)
    }
    
    @objc func onSettingClicked(){
        
        AppManager.sharedInstance().addAction(action: "Setting Tapped", session: "Profile", detail: "")
        let vc = storyboard?.instantiateViewController(withIdentifier: "Setting")
        navigationController?.pushViewController(vc!, animated: true)
    }
    
    override func viewWillLayoutSubviews() {
        profilePicture.round(corners: [.topLeft , .bottomLeft , .topRight, .bottomRight], radius: 15)
    }
    
    
    // MARK: -Collection View Delegate, Data source
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "KaraokeCard", for: indexPath) as! KaraokeCard_CollectionViewCell
        cell.setUp(post: posts.posts[indexPath.row].kara)
        cell.freeBadge.isHidden = true
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.posts.posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        AppManager.sharedInstance().addAction(action: "Post Tapped", session: "Profile", detail: indexPath.row.description)
        let vc = storyboard?.instantiateViewController(withIdentifier: "WatchPostViewController") as! WatchPostViewController
        vc.index = indexPath.row
        self.present(vc, animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellsAcross: CGFloat = 2
        let spaceBetweenCells: CGFloat = 18
        let dim = (collectionView.bounds.width - (cellsAcross - 1) * spaceBetweenCells) / cellsAcross
        return CGSize(width: dim, height: dim*190/140)
    }
    
    
    
    func updateInfo(){
        //        self.profilePicture.sd_setImage(with: URL(string: self.userInfo.image), placeholderImage: UIImage(named: "hootan"))
        navigationItem.title = userInfo.first_name
        self.profilePicture.image = AppManager.sharedInstance().userAvatar
        self.Name.text = "هوتن حسینی"
        self.Credit.isHidden = !self.userInfo.is_premium
        self.normalUserLabel.isHidden = self.userInfo.is_premium
        self.premiumImageView.isHidden = !self.userInfo.is_premium
        self.noPostsView.isHidden = self.posts.posts.count != 0
        self.songsCollectionView.reloadData()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y < 0 {
            headerTopConstraint.constant = -scrollView.contentOffset.y
        }else{
            headerTopConstraint.constant = 0
        }
    }
    
    
    
}









