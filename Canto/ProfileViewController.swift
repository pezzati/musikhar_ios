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

class ProfileViewController: UIViewController {
    
    
    

    @IBOutlet weak var noPostsView: UIView!
    @IBOutlet weak var headerTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var songsCollectionView: UICollectionView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var Name: UILabel!
	@IBOutlet weak var creditLbl: UILabel!
	@IBOutlet weak var premiumIV: UIImageView!
	@IBOutlet weak var coinIV: UIImageView!
	
    
    var userInfo = user()
    var posts : userPostsList = userPostsList()
    
    override func viewDidLoad() {
        songsCollectionView.register(UINib(nibName: "UserPostCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "KaraokeCard")
        let genreItem = UIBarButtonItem(image: #imageLiteral(resourceName: "setting"), style: .plain, target: self, action: #selector(self.onSettingClicked))
        self.navigationController?.navigationBar.topItem?.setRightBarButtonItems([genreItem], animated: true)
        self.navigationController?.navigationBar.setValue(true, forKey: "hidesShadow")
        self.view.bringSubview(toFront: headerView)
    }
    
    override func viewDidAppear(_ animated: Bool) {
		
        if AppManager.sharedInstance().userInfo.username.isEmpty{
            AppManager.sharedInstance().fetchUserInfo(sender: self, force: true, completionHandler: {
                _ in
				
                self.updateInfo()
            })
		}else{
			self.updateInfo()
		}
		
        AppManager.sharedInstance().addAction(action: "View Did Appear", session: "Profile", detail: "")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        AppManager.sharedInstance().addAction(action: "View Did Disappear", session: "Profile", detail: "")
    }
    
    @IBAction func editInfo(_ sender: Any) {
        
        AppManager.sharedInstance().addAction(action: "Photo/Name Tapped", session: "Profile", detail: "")
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "PhotoPicker") as? ProfilePictureViewController
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
    
}


extension ProfileViewController : UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "KaraokeCard", for: indexPath) as! UserPostCollectionViewCell
        cell.setUp(post: posts.posts[indexPath.row])
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
        let spaceBetweenCells: CGFloat = 11
        let dim = (collectionView.bounds.width - 60 - (cellsAcross - 1) * spaceBetweenCells) / cellsAcross
        return CGSize(width: dim, height: dim*4/3 + 10)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0, 25, 0, 25)
    }
    
    
    func updateInfo(){
		
        Name.text = AppManager.sharedInstance().userInfo.username
		self.posts = AppManager.sharedInstance().getUserPostsList()
		noPostsView.isHidden = self.posts.posts.count != 0
		songsCollectionView.reloadData()
		
		if AppManager.sharedInstance().userInfo.premium_days > 0 {
			creditLbl.text = AppManager.sharedInstance().userInfo.premium_days.description
			coinIV.isHidden = true
			premiumIV.isHidden = false
		}else{
			creditLbl.text = AppManager.sharedInstance().userInfo.coins.description
			coinIV.isHidden = false
			premiumIV.isHidden = true
		}
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y < 0 {
            headerTopConstraint.constant = -scrollView.contentOffset.y
        }else{
            headerTopConstraint.constant = 0
        }
    }
    
    
    
}









