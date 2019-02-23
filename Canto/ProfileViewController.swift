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
        let info = UIBarButtonItem(image: #imageLiteral(resourceName: "setting"), style: .plain, target: self, action: #selector(self.onSettingClicked))
		let shop = UIBarButtonItem(image: UIImage(named: "shop"), style: .plain, target: self, action: #selector(self.onShopClicked))
        self.navigationController?.navigationBar.topItem?.setRightBarButtonItems([info, shop], animated: true)
        self.navigationController?.navigationBar.setValue(true, forKey: "hidesShadow")
        self.view.bringSubview(toFront: headerView)
		Name.adjustsFontSizeToFitWidth = true
		
		posts = AppManager.sharedInstance().getUserPostsList()
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
		
    }
	

    
    override func viewDidDisappear(_ animated: Bool) {
		
    }
    
    @IBAction func editInfo(_ sender: Any) {
		
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "PhotoPicker") as? ProfilePictureViewController
		vc?.isFirstTime = false
		navigationController?.pushViewController(vc!, animated: true)
    }
    
    @objc func onSettingClicked(){
		
        let vc = storyboard?.instantiateViewController(withIdentifier: "Setting")
        navigationController?.pushViewController(vc!, animated: true)
    }
	
	@objc func onShopClicked(){
		let vc = storyboard?.instantiateViewController(withIdentifier: "PurchaseTableViewController")
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
		
		DispatchQueue.main.async {
			
			self.profilePicture.sd_setImage(with: URL(string: AppManager.sharedInstance().userInfo.avatar.link), placeholderImage: UIImage(named: "userPH") )
			self.Name.text = AppManager.sharedInstance().userInfo.username
			self.posts = AppManager.sharedInstance().userPosts
			self.noPostsView.isHidden = self.posts.posts.count != 0
			self.songsCollectionView.reloadData()
			
			if AppManager.sharedInstance().userInfo.premium_days > 0 {
				self.creditLbl.text = AppManager.sharedInstance().userInfo.premium_days.description
				self.coinIV.isHidden = true
				self.premiumIV.isHidden = false
			}else{
				self.creditLbl.text = AppManager.sharedInstance().userInfo.coins.description
				self.coinIV.isHidden = false
				self.premiumIV.isHidden = true
			}
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









