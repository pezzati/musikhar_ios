//
//  ViewController.swift
//  Canto
//
//  Created by WhoTan on 8/11/17.
//  Copyright © 2017 WhoTan. All rights reserved.
//

import UIKit
import SDWebImage

class Karaoke_VC: UIViewController,UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, iCarouselDelegate, iCarouselDataSource{

    @IBOutlet weak var Navigation_Bar: UIView!
    @IBOutlet weak var Home_TableView: UITableView!
    
    @IBOutlet weak var pageController: UIPageControl!
    @IBOutlet weak var Carousel: iCarousel!
    var storedOffsets = [Int: CGFloat]()
    var screen_Width = 0
    var genres : [Genre] = []
    var banners = bannersList()
    var waiting = DialougeView()
    var viewCount = 0
    private let refreshControl = UIRefreshControl()
    
    var currentOffset : CGPoint = CGPoint.zero

    override func viewDidLoad() {
        super.viewDidLoad()
        Carousel.dataSource = self
        Carousel.delegate = self
        Carousel.type = .rotary
        Carousel.isPagingEnabled = true
        pageController.currentPage = 0
        pageController.numberOfPages = 0
        
        let tempFrame = Carousel.frame
        Carousel.frame = CGRect(x: tempFrame.minX, y: tempFrame.minY, width: tempFrame.width, height: tempFrame.width/2.03)
            
        Carousel.addSubview(pageController)
        self.screen_Width = Int(view.frame.width)
        Navigation_Bar.headerViewCornerRounding()
        waiting.waitingBox(vc: self)
        
        Home_TableView.refreshControl = refreshControl
        refreshControl.tintColor = UIColor(red:112/255, green:96/255, blue:251/255, alpha:1.0)
        
  
        let formattedString = NSMutableAttributedString()
        refreshControl.attributedTitle = formattedString.bold("در حال به روز رسانی")
        refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
        
        AppManager.sharedInstance().fetchBanners(sender: self, force: false, completionHandler: {
                                success in
                                self.banners = AppManager.sharedInstance().getBanners()
                                self.Carousel.reloadData()
                                self.pageController.numberOfPages = self.banners.results.count
                                self.pageController.currentPage = self.Carousel.currentItemIndex
                            })
        AppManager.sharedInstance().fetchHomeFeed(sender: self,force: false){ success in
                            if success {
                                self.waiting.hide()
                                self.Home_TableView.isHidden = true
                                let homeFeed = AppManager.sharedInstance().getHomeFeed()
                                self.genres = homeFeed
                                self.Home_TableView.reloadData()
                                self.Home_TableView.setContentOffset(self.currentOffset, animated: true)
                                self.Home_TableView.isHidden = false
                            }
                        }
        
        Timer.scheduledTimer(withTimeInterval: 5.0 , repeats: true, block: {_ in

            let next =  self.banners.results.count - 1 == self.pageController.currentPage ? 0 : self.pageController.currentPage + 1
            self.Carousel.scrollToItem(at: next, duration: 1)
        })
        
        
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(true)
//    }
    

    
    override func viewDidAppear(_ animated: Bool) {
        
        self.Home_TableView.setContentOffset(self.currentOffset, animated: true)

                if self.genres.isEmpty{
                    let homeFeed = AppManager.sharedInstance().getHomeFeed()
                    if !homeFeed.isEmpty {
                        self.waiting.hide()
                        self.genres = homeFeed
                        self.Home_TableView.reloadData()
                        self.Home_TableView.setContentOffset(self.currentOffset, animated: true)
                        self.Home_TableView.isHidden = false
                    }
                }
        
                if self.banners.results.isEmpty{
                    let banners = AppManager.sharedInstance().getBanners()
                    if !banners.results.isEmpty{
                        self.banners = banners
                        self.Carousel.reloadData()
                        self.pageController.numberOfPages = self.banners.results.count
                        self.pageController.currentPage = self.Carousel.currentItemIndex
                    }
                }
        
        
//        if self.genres.count == 0 {
//            AppManager.sharedInstance().fetchHomeFeed(sender: self,force: false){ success in
//                if success {
//                    self.waiting.hide()
//                    self.Home_TableView.isHidden = true
//                    let homeFeed = AppManager.sharedInstance().getHomeFeed()
//                    self.genres = homeFeed
//                    self.Home_TableView.reloadData()
//                    self.Home_TableView.setContentOffset(self.currentOffset, animated: true)
//                    self.Home_TableView.isHidden = false
//                }
//            }
//        }
        
//        if self.banners.results.isEmpty{
//            let banners = AppManager.sharedInstance().getBanners()
//
//            if !banners.results.isEmpty{
//                self.banners = banners
//                self.Carousel.reloadData()
//                self.pageController.numberOfPages = self.banners.results.count
//                self.pageController.currentPage = self.Carousel.currentItemIndex
//            }else{
//                AppManager.sharedInstance().fetchBanners(sender: self, force: false, completionHandler: {
//                    success in
//                    self.banners = AppManager.sharedInstance().getBanners()
//                    self.Carousel.reloadData()
//                    self.pageController.numberOfPages = self.banners.results.count
//                    self.pageController.currentPage = self.Carousel.currentItemIndex
//                })
//            }
//        }
        AppManager.sharedInstance().addAction(action: "View Did Appear", session: "Home", detail: "")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.currentOffset =  self.Home_TableView.contentOffset
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
        
//
//        DispatchQueue.global(qos: .background).async {
//            self.viewCount += 1
//            if self.viewCount == 6 || self.genres.count == 0 {
//            AppManager.sharedInstance().fetchUserInfo(sender: self, completionHandler: {_ in })
//            AppManager.sharedInstance().fetchHomeFeed(sender: self, force: false, completionHandler: {_ in })
//            AppManager.sharedInstance().fetchBanners(sender: self, completionHandler: {_ in })
//            self.genres = []
//            self.banners = bannersList()
//            self.viewCount = 0
//            }else if self.viewCount == 3{
//                AppManager.sharedInstance().fetchUserInfo(sender: self, completionHandler: {_ in })
//            }
//        }
        AppManager.sharedInstance().addAction(action: "View Did Disappear", session: "Home", detail: "")
        AppManager.sharedInstance().sendActions()
    }
    
    @objc private func refreshData(_ sender: Any) {
        
        AppManager.sharedInstance().fetchUserInfo(sender: self, completionHandler: {_ in })
        AppManager.sharedInstance().fetchHomeFeed(sender: self, force: false, completionHandler: {success in
            if success{
                let homeFeed = AppManager.sharedInstance().getHomeFeed()
                if !homeFeed.isEmpty {
                    self.genres = homeFeed
                    self.Home_TableView.reloadData()
                    self.Home_TableView.setContentOffset(self.currentOffset, animated: true)
                    self.Home_TableView.isHidden = false
                }
            }
            self.refreshControl.endRefreshing()
        })
        
        AppManager.sharedInstance().fetchBanners(sender: self, completionHandler: {success in
            if success{
                let banners = AppManager.sharedInstance().getBanners()
                if !banners.results.isEmpty{
                    self.banners = banners
                    self.Carousel.reloadData()
                    self.pageController.numberOfPages = self.banners.results.count
                    self.pageController.currentPage = self.Carousel.currentItemIndex
                }
            }
        })
        
        
    }
    
    
    @IBAction func editFavoriteGenres(_ sender: Any) {
        AppManager.sharedInstance().addAction(action: "Genre Selection Tapped", session: "Home", detail: "")
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "genreSelection") as! GenreSelectionViewController
        vc.shouldReturn = true
        self.present(vc, animated: true, completion: {
            self.genres = []
        })
    }
    
    
    @objc func genre_moreTapped(button: UIButton){
        let vc = storyboard?.instantiateViewController(withIdentifier: "genre_more") as! GenreViewController
        vc.url = self.genres[button.tag].files_link
        vc.name = self.genres[button.tag].name
        AppManager.sharedInstance().addAction(action: "Genre More Tapped", session: "Home", detail: vc.name)
        self.present(vc, animated: true, completion: nil)
       
    }
    
    //table view protocol
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.genres.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GenreCell", for: indexPath) as! Genre_TableViewCell
        cell.MoreButton.tag = indexPath.row
        cell.MoreButton.addTarget(self, action: #selector(genre_moreTapped(button:)), for: .touchUpInside)
        cell.KaraokeCollectionView.transform = CGAffineTransform(scaleX: -1, y: 1)
        
        let genreTapped =  UITapGestureRecognizer { (gesture:UIGestureRecognizer?) in
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "genre_more") as! GenreViewController
            vc.url = self.genres[indexPath.row].files_link
            vc.name = self.genres[indexPath.row].name
            AppManager.sharedInstance().addAction(action: "Genre More Tapped", session: "Home", detail: vc.name)
            self.present(vc, animated: true, completion: nil)
            
        }
        cell.GenreNameLabel.isUserInteractionEnabled = true
        cell.GenreNameLabel.addGestureRecognizer(genreTapped!)
        cell.GenreNameLabel.text = self.genres[indexPath.row].name
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let tableViewCell = cell as? Genre_TableViewCell else { return }
        
        tableViewCell.setCollectionViewDataSourceDelegate(dataSourceDelegate: self, forRow: indexPath.row)
        tableViewCell.collectionViewOffset = storedOffsets[indexPath.row] ?? 0
        
    }
    
 
    
    
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let tableViewCell = cell as? Genre_TableViewCell else { return }
        storedOffsets[indexPath.row] = tableViewCell.collectionViewOffset
    }
    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let vc = storyboard?.instantiateViewController(withIdentifier: "genre_more") as! GenreViewController
//        vc.url = self.genres[indexPath.row].files_link
//        vc.name = self.genres[indexPath.row].name
//        self.present(vc, animated: true, completion: nil)
//    }
    
    //collection view delegate and source
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return self.karaokes[collectionView.tag].posts.count
        return self.genres[collectionView.tag].karas.results.count
    }
    

    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "KaraokeCard", for: indexPath) as! KaraokeCard_CollectionViewCell
//        let post = self.karaokes[collectionView.tag].posts[indexPath.row]
        let post = self.genres[collectionView.tag].karas.results[indexPath.row]
        
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
        
        cell.transform = CGAffineTransform(scaleX: -1, y: 1)
        //collectionView.tag indicates which table list row is filling up
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        AppManager.sharedInstance().addAction(action: "Karaoke Tapped", session: "Home", detail: self.genres[collectionView.tag].karas.results[indexPath.row].id.description)
        let karaType = DialougeView()
        karaType.chooseKaraType(kara: self.genres[collectionView.tag].karas.results[indexPath.row], sender: self)
    }
    
    //Carousel data source and delegate
    func numberOfItems(in carousel: iCarousel) -> Int {
        return self.banners.count
    }
    
    func carousel(_ carousel: iCarousel, viewForItemAt index: Int, reusing view: UIView?) -> UIView {
        let bannerImage = UIImageView(frame: CGRect(x: 10, y: 5, width: Carousel.frame.width - 20 , height: Carousel.frame.height - 10))
        
        let banner = self.banners.results[index]
        
        bannerImage.sd_setImage(with: URL(string : banner.file), placeholderImage: UIImage(named : "valery"))
        bannerImage.contentMode = .scaleAspectFill
        bannerImage.clipsToBounds = true
        bannerImage.layer.cornerRadius = 10
        return bannerImage
    }

    func carousel(_ carousel: iCarousel, didSelectItemAt index: Int) {
        let item = self.banners.results[index]
        
        AppManager.sharedInstance().addAction(action: "Banner Tapped", session: "Home", detail: item.link)
        
        switch item.content_type{
        case "single":
//            API_Handler.getSingleKara(karaURL: item.link, completionHandler: { (post, stat) in
//                if stat == ResultStatus.Success && post != nil{
//                    let karaType = DialougeView()
//                    karaType.chooseKaraType(kara: post!, sender: self)
//                }else{
//                    //failed
//                }
//                })
            break
        case "multi":
            let request = RequestHandler(type: .genrePosts , requestURL: item.link, shouldShowError: true, sender: self, waiting: true, force: false)
            
            request.sendRequest(completionHandler: { more_posts, success, msg in
                if success {
                    let result = more_posts as! genre_more
                    UserDefaults.standard.setValue(result.toJsonString(), forKey: item.link)
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "genre_more") as! GenreViewController
                    vc.url = item.link
                    vc.name = item.title
                    self.present(vc, animated: true, completion: nil)
                }
            })
            
            break
        case "redirect":
              UIApplication.shared.openURL( URL(string: item.link )!)
            break
        default :
            break
     
        }
    }
    
    func carouselDidScroll(_ carousel: iCarousel) {
//        AppManager.sharedInstance().addAction(action: "Banner Scrolled", session: "Home", detail: "")
        pageController.currentPage = carousel.currentItemIndex
    }
  
}

