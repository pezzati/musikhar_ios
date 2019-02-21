//
//  AvatarPickerViewController.swift
//  Canto
//
//  Created by Whotan on 1/15/19.
//  Copyright © 2019 WhoTan. All rights reserved.
//

import UIKit

class AvatarPickerViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

	
	var avatars: AvatarsList = AvatarsList()
	@IBOutlet weak var collectionView: UICollectionView!
	
	
	override func viewWillAppear(_ animated: Bool) {
		if avatars.results.count == 0{
			getMorePosts()
		}
		
	}
	
	func getMorePosts(){
		
		let request = RequestHandler(type: .avatarsList , requestURL: avatars.results.count == 0 ? AppGlobal.AvatarsList : self.avatars.next, shouldShowError: true, sender: self, waiting: false, force: false)
		
		request.sendRequest(completionHandler: { more_posts, success, msg in
			if success {
				let result = more_posts as! AvatarsList
				if self.avatars.next != result.next || self.avatars.results.isEmpty{
					self.avatars.next = result.next
					self.avatars.previous = (result.previous)
					for item in (result.results){
						self.avatars.results.append(item)
					}
					self.collectionView.reloadData()
				}
			}
		})
	}
	
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return avatars.results.count
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		let cellsAcross: CGFloat = 3
		let spaceBetweenCells: CGFloat = 11
		let dim = (collectionView.bounds.width - 60 - (cellsAcross - 1) * spaceBetweenCells) / cellsAcross
		return CGSize(width: dim, height: dim)
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
		return UIEdgeInsetsMake(0, 30, 0, 30)
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AvatarCell", for: indexPath)
		let imageView = cell.contentView.viewWithTag(2) as! UIImageView
		imageView.sd_setImage(with: URL(string : avatars.results[indexPath.row].link))
		imageView.layer.cornerRadius = 10
		return cell
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		
		AppManager.sharedInstance().userInfo.avatar = avatars.results[indexPath.row]
		navigationController?.popViewController(animated: true)
	}
	
	func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
		if indexPath.row + 6 >= avatars.results.count && !avatars.next.isEmpty{
			self.getMorePosts()
		}
	}
	
	
	
}
