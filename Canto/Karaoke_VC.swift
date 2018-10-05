//
//  ViewController.swift
//  Canto
//
//  Created by WhoTan on 8/11/17.
//  Copyright © 2017 WhoTan. All rights reserved.
//

import UIKit
import SDWebImage

class Karaoke_VC: UIViewController {
    
    @IBOutlet weak var Home_TableView: UITableView!
    @IBOutlet weak var pageController: UIPageControl!
    @IBOutlet weak var Carousel: iCarousel!
    var storedOffsets = [Int: CGFloat]()
    var genres : [Genre] = []
    var banners = bannersList()
    var viewCount = 0
    private let refreshControl = UIRefreshControl()
    var shouldRefresh = false
    
    var currentOffset : CGPoint = CGPoint.zero
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        setupNavBar()
        setupRefreshController()
        setupCarousel()
        refreshControl.beginRefreshing()
        refreshData(refreshControl)
        Timer.scheduledTimer(withTimeInterval: 5.0 , repeats: true, block: {_ in
            
            let next =  self.banners.results.count - 1 == self.pageController.currentPage ? 0 : self.pageController.currentPage + 1
            self.Carousel.scrollToItem(at: next, duration: 1)
        })
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if shouldRefresh { refreshData(refreshControl) }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        self.Home_TableView.setContentOffset(self.currentOffset, animated: true)
        AppManager.sharedInstance().addAction(action: "View Did Appear", session: "Home", detail: "")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        currentOffset =  Home_TableView.contentOffset
        refreshControl.endRefreshing()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
        AppManager.sharedInstance().addAction(action: "View Did Disappear", session: "Home", detail: "")
        AppManager.sharedInstance().sendActions()
    }
    
    func setupNavBar() {
        
        let genreItem = UIBarButtonItem(image: #imageLiteral(resourceName: "add"), style: .plain, target: self, action: #selector(self.onEditClicked))
        self.navigationController?.navigationBar.topItem?.setRightBarButtonItems([genreItem], animated: true)
        self.navigationController?.navigationBar.setValue(true, forKey: "hidesShadow")
        self.navigationItem.title = "کانتو"
    }
    
    func setupRefreshController() {
        
        Home_TableView.refreshControl = refreshControl
        refreshControl.tintColor = UIColor.white
        //        let attributes = [NSAttributedStringKey.foregroundColor : UIColor.white, NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 14)]
        //        refreshControl.attributedTitle = NSAttributedString(string: "در حال به روز رسانی", attributes: attributes)
        refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
    }
    
    func setupCarousel(){
        
        Carousel.dataSource = self
        Carousel.delegate = self
        Carousel.type = .linear
        Carousel.isPagingEnabled = true
        pageController.currentPage = 0
        pageController.numberOfPages = 0
        Carousel.clipsToBounds = true
        pageController.alpha = 0
        let tempFrame = Carousel.frame
        Carousel.frame = CGRect(x: tempFrame.minX, y: tempFrame.minY, width: tempFrame.width, height: tempFrame.width/2.03)
    }
    
    @objc func onEditClicked() {
        
        AppManager.sharedInstance().addAction(action: "Genre Selection Tapped", session: "Home", detail: "")
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "genreSelection") as! GenreSelectionViewController
        vc.shouldReturn = true
        shouldRefresh = true
        genres = []
        Home_TableView.reloadData()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func refreshData(_ sender: Any) {
        
        view.layoutIfNeeded()
        genres = AppManager.sharedInstance().getHomeFeed()
        banners = AppManager.sharedInstance().getBanners()
        pageController.numberOfPages = banners.results.count
        pageController.currentPage = Carousel.currentItemIndex
        Carousel.reloadData()
        Home_TableView.reloadData()
        refreshControl.endRefreshing()
        
        AppManager.sharedInstance().fetchUserInfo(sender: self, completionHandler: {_ in })
        AppManager.sharedInstance().fetchHomeFeed(sender: self, force: genres.isEmpty, completionHandler: { success in
            if self.genres.isEmpty {
                DispatchQueue.main.async {
                    self.genres = AppManager.sharedInstance().getHomeFeed()
                    self.Home_TableView.reloadData()
                }
            }
        })
        AppManager.sharedInstance().fetchBanners(sender: self, completionHandler: { success in
            self.banners = AppManager.sharedInstance().getBanners()
            self.Carousel.reloadData()
            self.pageController.numberOfPages = self.banners.results.count
            self.pageController.currentPage = self.Carousel.currentItemIndex
        })
    }
    
}

extension Karaoke_VC: UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.genres.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GenreCell", for: indexPath) as! Genre_TableViewCell
        cell.KaraokeCollectionView.transform = CGAffineTransform(scaleX: -1, y: 1)
        cell.KaraokeCollectionView.register(UINib(nibName: "KaraokeCard", bundle: nil), forCellWithReuseIdentifier: "KaraokeCard")
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "genre_more") as! GenreViewController
        vc.url = self.genres[indexPath.row].files_link
        vc.name = self.genres[indexPath.row].name
        navigationController?.pushViewController(vc, animated: true)
    }
    
}

extension Karaoke_VC : UICollectionViewDataSource, UICollectionViewDelegate{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.genres[collectionView.tag].karas.results.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "KaraokeCard", for: indexPath) as! KaraokeCard_CollectionViewCell
        let post = self.genres[collectionView.tag].karas.results[indexPath.row]
        cell.setUp(post: post)
        cell.transform = CGAffineTransform(scaleX: -1, y: 1)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        AppManager.sharedInstance().addAction(action: "Karaoke Tapped", session: "Home", detail: self.genres[collectionView.tag].karas.results[indexPath.row].id.description)
        let karaType = DialougeView()
        karaType.chooseKaraType(kara: self.genres[collectionView.tag].karas.results[indexPath.row], sender: self)
    }
    
}


extension Karaoke_VC : iCarouselDelegate, iCarouselDataSource{
    
    func numberOfItems(in carousel: iCarousel) -> Int {
        return self.banners.count
    }
    
    func carousel(_ carousel: iCarousel, viewForItemAt index: Int, reusing view: UIView?) -> UIView {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: Carousel.frame.width , height: Carousel.frame.height))
        let bannerImage = UIImageView(frame: CGRect(x: 20, y: 0, width: Carousel.frame.width - 40, height:  (Carousel.frame.width - 40)/2.03))
        
        let banner = self.banners.results[index]
        
        bannerImage.sd_setImage(with: URL(string : banner.file), placeholderImage: UIImage(named : "valery"))
        bannerImage.contentMode = .scaleAspectFill
        bannerImage.clipsToBounds = true
        //        bannerImage.layer.cornerRadius = 10
        bannerImage.round(corners:   [.topLeft , .bottomLeft , .topRight, .bottomRight], radius: 15)
        view.addSubview(bannerImage)
        return view
    }
    
    func carousel(_ carousel: iCarousel, didSelectItemAt index: Int) {
        
        let item = self.banners.results[index]
        AppManager.sharedInstance().addAction(action: "Banner Tapped", session: "Home", detail: item.link)
        switch item.content_type{
        case "single":
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
                    vc.bannerURL = item.file
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
    
    func carousel(_ carousel: iCarousel, valueFor option: iCarouselOption, withDefault value: CGFloat) -> CGFloat {
        
        if option == iCarouselOption.wrap {
            return 1
        }
        return value
    }
    
    func carouselDidScroll(_ carousel: iCarousel) {
        
        pageController.currentPage = carousel.currentItemIndex
    }
    
}

