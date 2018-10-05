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
    
    var selectedIndex = -1
//    var playerLayer : AVPlayerLayer? = nil
//    var Player : AVPlayer? = nil
//    var playerItem : AVPlayerItem? = nil
//    var isPlaying = false
//    var isMovingSlider = false
//    var timer : Timer? = nil
    
    override func viewDidLoad() {
        songsCollectionView.register(UINib(nibName: "KaraokeCard", bundle: nil), forCellWithReuseIdentifier: "KaraokeCard")
        self.navigationController?.navigationBar.setValue(true, forKey: "hidesShadow")
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
//        do{
//            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback , with: .defaultToSpeaker)
//            try AVAudioSession.sharedInstance().setActive(true)
//        }catch{
//            print(error)
//        }
        
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
//        self.timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true, block: {
//            _ in
//            self.updateRow()
//        })
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        AppManager.sharedInstance().addAction(action: "View Did Disappear", session: "Profile", detail: "")
//        AppManager.sharedInstance().sendActions()
//        self.tableView.setContentOffset(CGPoint.zero, animated: true)
//        if self.selectedIndex != -1{
//            self.closeRow(indexPath: IndexPath(row: selectedIndex, section: 0))
//        }
//        if self.timer != nil{
//            timer?.invalidate()
//            timer = nil
//        }
    }
    
    @IBAction func editInfo(_ sender: Any) {
        AppManager.sharedInstance().addAction(action: "Photo/Name Tapped", session: "Profile", detail: "")
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "PhotoPicker") as? ProfilePictureViewController
        vc!.isFirstTime = false
        self.present(vc!, animated: true, completion: nil)
    }
    
    
    override func viewWillLayoutSubviews() {
        profilePicture.round(corners: [.topLeft , .bottomLeft , .topRight, .bottomRight], radius: 15)
    }
    
   
   // MARK: -Collection View Delegate, Data source
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "KaraokeCard", for: indexPath) as! KaraokeCard_CollectionViewCell
//        cell.contentView.layer.cornerRadius = 10
//        cell.contentView.backgroundColor = UIColor.white
//        cell.contentView.layer.shadowRadius = 4
//        cell.contentView.layer.shadowOpacity = 0.3
//        cell.contentView.layer.shadowColor = UIColor.darkGray.cgColor
//        cell.layer.shadowOffset = CGSize(width: 0, height: 2)
//        cell.cardImage.layer.cornerRadius = 10
//        let imgURL = URL(string : self.posts.posts[indexPath.row].kara.cover_photo.link)
//        cell.cardImage.sd_setImage(with: imgURL, placeholderImage: UIImage(named: "hootan"))
//        cell.ArtistName.text = self.posts.posts[indexPath.row].kara.content.artist.name
//        cell.SongName.text = self.posts.posts[indexPath.row].kara.name
//        cell.setAsPremium()
        cell.setUp(post: posts.posts[indexPath.row].kara)
        cell.freeBadge.isHidden = true
        return cell
    }
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        let cellsAcross: CGFloat = 2
//        let spaceBetweenCells: CGFloat = 18
//        let dim = (collectionView.bounds.width - (cellsAcross - 1) * spaceBetweenCells) / cellsAcross
//        return CGSize(width: dim, height: dim*220/170)
//    }

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
    
    /*
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         return self.posts.posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         let cell = tableView.dequeueReusableCell(withIdentifier: "PostListCell", for: indexPath) as! PostListTableViewCell
        
        cell.setupCell(post: self.posts.posts[indexPath.row])
        
        let share = UITapGestureRecognizer { (gesture:UIGestureRecognizer?) in
            DispatchQueue.main.async {
                
                if self.isPlaying{
                    self.play()
                }
                
                AppManager.sharedInstance().addAction(action: "Share Tapped", session: "User Post", detail: "")
                let objectsToShare = [cell.fileURL!] as [Any]
                let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
                activityVC.setValue("Video", forKey: "subject")
                
                //New Excluded Activities Code
                activityVC.excludedActivityTypes = [UIActivityType.airDrop, UIActivityType.addToReadingList, UIActivityType.assignToContact, UIActivityType.copyToPasteboard, UIActivityType.mail, UIActivityType.message, UIActivityType.postToTencentWeibo, UIActivityType.postToVimeo, UIActivityType.postToWeibo, UIActivityType.print ]
                
                if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad ){
                    activityVC.popoverPresentationController?.sourceView = cell.shareButton
                }
                
                self.present(activityVC, animated: true, completion: nil)
            }
        }
        
        cell.shareButton.addGestureRecognizer(share!)
        
        let remove = UITapGestureRecognizer { (gesture:UIGestureRecognizer?) in
            let dialog = DialougeView()
            dialog.shouldRemove(vc: self, completionHandler: {
                sure in
                if sure{
                    AppManager.sharedInstance().addAction(action: "Remove Tapped", session: "User Post", detail: self.posts.posts[indexPath.row].kara.id.description)
                    AppManager.sharedInstance().removeUserPost(index: indexPath.row, fileURL: cell.fileURL!)
                    dialog.hide()
                  
                    if self.selectedIndex != -1{
//                        self.selectedIndex = -1
//                        self.playerLayer?.removeFromSuperlayer()
//                        cell.close()
//
//                        self.Player?.pause()
//                        self.playerItem = nil
//                        self.playerLayer = nil
//                        self.Player = nil
//                        self.isPlaying = false
                        self.closeRow(indexPath: indexPath)
                    }
                    self.posts = AppManager.sharedInstance().getUserPostsList()
                    self.tableView.reloadData()
                }else{
                    dialog.hide()
                }
            })
        }
        
        cell.removeButton.addGestureRecognizer(remove!)
        
        if indexPath.row == selectedIndex && self.playerLayer != nil{
            if cell.playButton == nil{
                let play = UITapGestureRecognizer { (gesture:UIGestureRecognizer?) in
                    self.play()
                }
                cell.expand(playerLayer: playerLayer!)
                cell.playerView?.addGestureRecognizer(play!)
                cell.slider?.addTarget(self, action: #selector(sliderBeganMoving), for: UIControlEvents.touchDown)
                cell.slider?.addTarget(self, action: #selector(sliderEnded), for: UIControlEvents.touchUpInside)
            }
        }
        
        return cell
    }
    
    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
////        tableView.deselectRow(at: indexPath, animated: false)
//        if selectedIndex != -1{
//            tableView.reloadRows(at: [IndexPath(row: selectedIndex, section: 0)] , with: .automatic)
//        }
//        self.selectedIndex = indexPath.row
//        tableView.reloadRows(at: [indexPath], with: .automatic)
//    }
    

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        if indexPath.row == selectedIndex{
//            selectedIndex = -1
//            let cell = tableView.cellForRow(at: indexPath) as? PostListTableViewCell
//            playerLayer?.removeFromSuperlayer()
//            cell?.close()
//
//            Player?.pause()
//            playerItem = nil
//            playerLayer = nil
//            Player = nil
//            isPlaying = false
//
//            tableView.beginUpdates()
//            tableView.endUpdates()
            self.closeRow(indexPath: indexPath)
        }else{
        
            if selectedIndex != -1{
//                let cell = tableView.cellForRow(at: IndexPath(item: selectedIndex, section: 0)) as? PostListTableViewCell
//                playerLayer?.removeFromSuperlayer()
//                cell?.close()
//
//                Player?.pause()
//                playerItem = nil
//                playerLayer = nil
//                Player = nil
//                isPlaying = false
//
//                tableView.beginUpdates()
//                tableView.endUpdates()
                self.closeRow(indexPath: IndexPath(row: selectedIndex, section: 0))
                
            }
            self.openRow(indexPath: indexPath)
            
//            selectedIndex = indexPath.row
//            let cell = tableView.cellForRow(at: indexPath) as? PostListTableViewCell
//            playerItem = AVPlayerItem(url: (cell?.fileURL)!)
//            Player = AVPlayer(playerItem: playerItem)
//            playerLayer = AVPlayerLayer(player: Player)
//            playerLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
//            playerLayer?.masksToBounds = true
//            let play = UITapGestureRecognizer { (gesture:UIGestureRecognizer?) in
//                self.play()
//            }
//            cell?.expand(playerLayer: playerLayer!)
//            cell?.playerView?.addGestureRecognizer(play!)
//
//            tableView.beginUpdates()
//            tableView.endUpdates()
//            tableView.scrollToRow(at: indexPath, at: .middle , animated: true)
        }
    }
    
    @objc func sliderBeganMoving(){
        
        self.isMovingSlider = true
        if isPlaying{
            self.play()
        }
    }
    
    
    @objc func sliderEnded(sender : mySlider2){
        self.isMovingSlider = false
        print(sender.value)
//        playerItem?.seek(to: CMTime(seconds: Double(sender.value)*(playerItem?.duration.seconds)!, preferredTimescale: (playerItem?.duration.timescale)!), completionHandler: nil)
        playerItem?.seek(to: CMTime(seconds: Double(sender.value)*(playerItem?.duration.seconds)!, preferredTimescale: (playerItem?.duration.timescale)!), toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero, completionHandler: nil)
        if !isPlaying{
            self.play()
        }
        
    }
    
    
    
    func openRow(indexPath: IndexPath){
        
        AppManager.sharedInstance().addAction(action: "Post Tapped", session: "Profile", detail: indexPath.row.description)
        selectedIndex = indexPath.row
        let cell = tableView.cellForRow(at: indexPath) as? PostListTableViewCell
        playerItem = AVPlayerItem(url: (cell?.fileURL)!)
        Player = AVPlayer(playerItem: playerItem)
        playerLayer = AVPlayerLayer(player: Player)
        playerLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        playerLayer?.masksToBounds = true
        let play = UITapGestureRecognizer { (gesture:UIGestureRecognizer?) in
            self.play()
        }
        cell?.expand(playerLayer: playerLayer!)
        cell?.playerView?.addGestureRecognizer(play!)
        
        tableView.beginUpdates()
        tableView.endUpdates()
        tableView.scrollToRow(at: indexPath, at: .middle , animated: true)
        
        cell?.slider?.addTarget(self, action: #selector(sliderBeganMoving), for: UIControlEvents.touchDown)
        cell?.slider?.addTarget(self, action: #selector(sliderEnded), for: UIControlEvents.touchUpInside)
        
    }
    
    func closeRow(indexPath: IndexPath){
        
        let cell = tableView.cellForRow(at: IndexPath(item: selectedIndex, section: 0)) as? PostListTableViewCell
        
        if playerLayer != nil{
            playerLayer?.removeFromSuperlayer()
        }
        
        cell?.close()
    
        
        if Player != nil{
            Player?.pause()
        }
        playerItem = nil
        playerLayer = nil
        Player = nil
        isPlaying = false
        
        selectedIndex = -1
        tableView.beginUpdates()
        tableView.endUpdates()
        
        
    }
    
    
    func updateRow(){
        
        if selectedIndex != -1 && self.isPlaying && !isMovingSlider{
            
            let cell = tableView.cellForRow(at: IndexPath(row: selectedIndex, section: 0)) as? PostListTableViewCell
            if cell?.slider != nil && cell?.timerLabel != nil{
                cell?.slider?.setValue(Float((Player?.currentTime().seconds)! / (playerItem?.duration.seconds)!), animated: false)
                cell?.timerLabel.text = playerItem?.currentTime().durationText
            }
        }
    }
    

    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
//        if indexPath.row == selectedIndex{
//
//            if !(tableView.indexPathsForVisibleRows?.contains(indexPath))!{
//                selectedIndex = -1
//
//
//                tableView.beginUpdates()
//                tableView.endUpdates()
//
//                let cell = tableView.cellForRow(at: indexPath) as? PostListTableViewCell
//                playerLayer?.removeFromSuperlayer()
//                cell?.close()
//
//                playerItem = nil
//                playerLayer = nil
//                Player = nil
//
//            }
//        }
        
        
    }
    
    
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.row == selectedIndex{
            
            return 105 + self.view.frame.width - 30
        }else{
            return 105
        }

    }
    
    func play(){
        
        if selectedIndex == -1 || self.Player == nil{
            return
        }
        
        let cell = tableView.cellForRow(at: IndexPath(item: selectedIndex, section: 0)) as? PostListTableViewCell
        
        if self.isMovingSlider{
            playerItem?.seek(to:  kCMTimeZero , toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero, completionHandler: nil)
            self.isMovingSlider = false
            
        }
        
        if !self.isPlaying{
            cell?.playButton?.image = UIImage(named: "postPause")
            Player?.play()
            self.isPlaying = true
        }else{
            cell?.playButton?.image = UIImage(named : "postPlay")
            Player?.pause()
            self.isPlaying = false
        }
    }
    
//    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        let current = cell as! PostListTableViewCell
//
//        current.setupCell(post: self.posts.posts[indexPath.row])
//    }
 
 */
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        self.headerTopConstraint.constant = -scrollView.contentOffset.y/1.5
//
//    }
    
    
    @IBAction func setting(_ sender: Any) {
        AppManager.sharedInstance().addAction(action: "Setting Tapped", session: "Profile", detail: "")
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "Setting")
        self.present(vc!, animated: true, completion: nil)
        
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
    
    
    
    
}









