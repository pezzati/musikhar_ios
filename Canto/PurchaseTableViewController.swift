//
//  PurchaseTableViewController.swift
//  Canto
//
//  Created by WhoTan on 1/31/18.
//  Copyright © 2018 WhoTan. All rights reserved.
//

import UIKit
import SDWebImage
import Alamofire

class PurchaseTableViewController: UITableViewController {

    var packages : [package] = []
	
	override func viewDidLoad() {
		navigationController?.navigationBar.prefersLargeTitles = true
		tabBarController?.hidesBottomBarWhenPushed = true
	}
	
    
    override func viewWillAppear(_ animated: Bool) {
		
        getPackages()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        AppManager.sharedInstance().addAction(action: "View Did Appear", session: "Shop", detail: "")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        AppManager.sharedInstance().addAction(action: "View Did Disappear", session: "Shop", detail: "")
    }
    
    func getPackages(){
        
        let request = RequestHandler(type: .packageList, requestURL: AppGlobal.PackagesList, shouldShowError: true, retry: 3, sender: self, waiting: true, force: false)
        
        request.sendRequest(completionHandler: {data, success, msg in
            if success{
                self.packages = (data as! packagesList).results
                self.tableView.reloadData()
            }else{
                AppManager.sharedInstance().addAction(action: "Failed to get packages", session: "Shop", detail: "")
                self.dismiss(animated: true, completion: nil)
            }
        })
        
    }


    @IBAction func close(_ sender: Any) {
        AppManager.sharedInstance().addAction(action: "Close Tapped", session: "Shop", detail: "")
        self.dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return section == 0 ? 1 : self.packages.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if indexPath.section == 0{
			let cell = tableView.dequeueReusableCell(withIdentifier: "CreditInfoCell", for: indexPath)
			cell.selectionStyle = .none
			
			let coins = cell.contentView.viewWithTag(101) as! UILabel
			coins.text = AppManager.sharedInstance().userInfo.coins.description
			
			let premiumDays = cell.contentView.viewWithTag(102) as! UILabel
			premiumDays.text = AppManager.sharedInstance().userInfo.premium_days.description
			
			return cell
		}
		else{
			
			let cell = tableView.dequeueReusableCell(withIdentifier: "PurchaceTableViewCell", for: indexPath)
			let image = cell.contentView.viewWithTag(101) as! UIImageView
			
			image.layer.cornerRadius = 0
			image.sd_setImage(with: URL(string: packages[indexPath.row].icon)!)
			let selectedBckView = UIView()
			selectedBckView.backgroundColor = UIColor.clear
			cell.selectedBackgroundView = selectedBckView
			return cell
		}
	}
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return indexPath.section == 1 ? 180 : 90
		let width = view.bounds.width - 40
	
		return indexPath.section == 1 ? width/2.62 + 8 : width/4.24 + 32
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
        if indexPath.section == 1{
            AppManager.sharedInstance().addAction(action: "Package Tapped", session: "Shop", detail: self.packages[indexPath.row].serial_number )
            tableView.deselectRow(at: indexPath, animated: false)
            self.getPackageURL(serialNumber : self.packages[indexPath.row].serial_number)
        }else{
            tableView.deselectRow(at: indexPath, animated: false)
        }
    }
    
    
    func getPackageURL(serialNumber : String){
        let params = ["serial_number" : Int(serialNumber)]
        
        let request = RequestHandler(type: .purchaseLink, requestURL: AppGlobal.PackageSerialNumber, params: params, shouldShowError: true, timeOut : 15 , retry: 1, sender: self, waiting: true, force: false)
        request.sendRequest(completionHandler: {data, success, msg in
            if success{
                let url = data as! String
                UIApplication.shared.open( URL(string: url )!, options: [:], completionHandler:{ bool in
					self.navigationController?.popViewController(animated: true)
				})
//                UIApplication.shared.openURL(URL(string: url )!)
//                self.dismiss(animated: true, completion: nil)
            }else{
                AppManager.sharedInstance().addAction(action: "Failed to get purchase link", session: "Shop", detail: "")
            }
        })
        
        
        
        
       
//            print(UserDefaults.standard.value(forKey: AppGlobal.Token) as! String)
//            let requestURL = URL(string: AppGlobal.ServerURL + "finance/purchase")
//        
//        Alamofire.request(requestURL!, method: .post, parameters: params , encoding: JSONEncoding.default, headers: ["Content-Type": "application/json", "USERTOKEN" : UserDefaaults.standard.value(forKey: AppGlobal.Token) as! String]).responseString{ response in
//            switch response.result{
//            case .failure( _):
//                print(response.description)
//                //connection error
//                break
//            case .success( _):
//                if (response.response?.statusCode)! == 200 {
//                    print(response.result.value!)
//                    var url = response.result.value!
//                    url.remove(at: url.index(of: "\"")!)
//                    url.remove(at: url.index(of: "\"")!)
//                    print(url)
//                    
//                    UIApplication.shared.open( URL(string: url )!, options: [:], completionHandler:{ bool in self.dismiss(animated: true, completion: nil) })
//                    
//                }else{
//                      //error while casting
//                }
//                break
//            }
//        }
        }
        
        
        
    }
    


