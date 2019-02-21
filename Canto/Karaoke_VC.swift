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
    var Carousel = iCarousel()
    var storedOffsets = [Int: CGFloat]()
    var homeFeed : [karaList] = []
    var banners = bannersList()
    var viewCount = 0
    private let refreshControl = UIRefreshControl()
    
    var currentOffset : CGPoint = CGPoint.zero
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        setupNavBar()
        setupRefreshController()
        setupCarousel()
//        refreshControl.beginRefreshing()
//        refreshData(refreshControl)
        Timer.scheduledTimer(withTimeInterval: 5.0 , repeats: true, block: {_ in
            let next =  self.banners.results.count - 1 == self.Carousel.currentItemIndex ? 0 : self.Carousel.currentItemIndex + 1
            self.Carousel.scrollToItem(at: next, duration: 1)
        })
		fetchData()
		
    }
    
    override func viewWillAppear(_ animated: Bool) {
		navigationController?.navigationBar.prefersLargeTitles = false
		navigationController?.isNavigationBarHidden = false
    }
	
	func fetchData(refresh: Bool = false){
		
		if banners.results.isEmpty || refresh{
			AppManager.sharedInstance().fetchBanners(sender: self, force: false) { success in
				self.banners = AppManager.sharedInstance().banners
				self.Carousel.reloadData()
			}
		}
		
		if homeFeed.isEmpty || refresh{
			AppManager.sharedInstance().fetchHomeFeed(vc: self, force: !refresh) { success in
				self.homeFeed = AppManager.sharedInstance().homeFeed
				self.Home_TableView.reloadData()
			}
		}
		
		if AppManager.sharedInstance().userInfo.username.isEmpty || refresh{
			AppManager.sharedInstance().fetchUserInfo(sender: self, force: false)
		}
		
		if AppManager.sharedInstance().inventory.posts.isEmpty || refresh{
			AppManager.sharedInstance().fetchUserInventory(sender: self, force: false){
				success in
				self.Home_TableView.reloadData()
			}
		}
		
		
	}
    
    override func viewDidAppear(_ animated: Bool) {
        self.Home_TableView.setContentOffset(self.currentOffset, animated: true)
        
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
		
//        let genreItem = UIBarButtonItem(image: #imageLiteral(resourceName: "add"), style: .plain, target: self, action: #selector(self.onEditClicked))
//        navigationController?.navigationBar.topItem?.setRightBarButtonItems([genreItem], animated: true)
        navigationController?.navigationBar.setValue(true, forKey: "hidesShadow")
        navigationItem.title = "کانتو"
        navigationController?.view.backgroundColor = view.backgroundColor
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
        Carousel.clipsToBounds = true
        Carousel.frame = CGRect(x: 0, y: 0, width:view.bounds.width, height:view.bounds.width/2.03)
    }
    
/*    @objc func onEditClicked() {
        
        AppManager.sharedInstance().addAction(action: "Genre Selection Tapped", session: "Home", detail: "")
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "genreSelection") as! GenreSelectionViewController
        vc.shouldReturn = true
        shouldRefresh = true
        genres = []
        Home_TableView.reloadData()
        navigationController?.pushViewController(vc, animated: true)
    }
*/
    
    @objc private func refreshData(_ sender: Any) {
        
        view.layoutIfNeeded()
		fetchData(refresh: true)
        refreshControl.endRefreshing()
    }
    
}

extension Karaoke_VC: UITableViewDataSource, UITableViewDelegate{
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return banners.count > 0 ? 2 : 1
	}
	
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if section == 0 && banners.count > 0 {
			return 1
		}
		return self.homeFeed.count
    }
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		if indexPath.section == 0 && banners.count > 0 {
			return view.bounds.width/2.03
		}
		return 240
	}
	
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if banners.count > 0 && indexPath.section == 0 {
			let cell = UITableViewCell(frame: CGRect.zero)
			cell.backgroundColor = UIColor.clear
			cell.addSubview(Carousel)
			Carousel.frame = CGRect(x: 0, y: 0, width:view.bounds.width, height:view.bounds.width/2.03)
			Carousel.reloadData()
			cell.selectionStyle = .none
			return cell
		}
        let cell = tableView.dequeueReusableCell(withIdentifier: "GenreCell", for: indexPath) as! Genre_TableViewCell
        cell.KaraokeCollectionView.transform = CGAffineTransform(scaleX: -1, y: 1)
        cell.KaraokeCollectionView.register(UINib(nibName: "KaraokeCard", bundle: nil), forCellWithReuseIdentifier: "KaraokeCard")
        cell.GenreNameLabel.text = self.homeFeed[indexPath.row].name
        
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
		if indexPath.section == 0 && banners.count > 0 {
			return
		}
        let vc = storyboard?.instantiateViewController(withIdentifier: "genre_more") as! GenreViewController
//        vc.url = self.genres[indexPath.row].files_link
		vc.url = homeFeed[indexPath.row].more
        vc.name = homeFeed[indexPath.row].name
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
}

extension Karaoke_VC : UICollectionViewDataSource, UICollectionViewDelegate{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        let count = genres[collectionView.tag].karas.results.count
		let count = homeFeed[collectionView.tag].data.count
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "KaraokeCard", for: indexPath) as! KaraokeCard_CollectionViewCell
        let post = homeFeed[collectionView.tag].data[indexPath.row]
        cell.setUp(post: post)
        cell.transform = CGAffineTransform(scaleX: -1, y: 1)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        AppManager.sharedInstance().addAction(action: "Karaoke Tapped", session: "Home", detail: homeFeed[collectionView.tag].data[indexPath.row].id.description)
//        let karaType = DialougeView()
//        karaType.chooseKaraType(kara: homeFeed[collectionView.tag].data[indexPath.row], sender: self)
		AppManager.sharedInstance().karaTapped(post: homeFeed[collectionView.tag].data[indexPath.row], sender: self)
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
//                    self.present(vc, animated: true, completion: nil)
					self.navigationController?.pushViewController(vc, animated: true)
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
	
    
}

