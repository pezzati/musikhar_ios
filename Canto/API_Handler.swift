//
//  API_Handler.swift
//  Canto
//
//  Created by WhoTan on 12/3/17.
//  Copyright © 2017 WhoTan. All rights reserved.
//

import UIKit
import Alamofire
import EVReflection

class API_Handler: NSObject {
	
	public static func resendVerificationCode(mobile: String, email: String, completionHandler: @escaping (String, ResultStatus) -> ()){
		
		var urlString = AppGlobal.ServerURL + "user/profile/verify?context="
		if mobile.isEmpty {
			urlString = urlString + "email" + "&username=" + email
		}else {
			urlString = urlString + "mobile" + "&username=" + mobile
			
		}
		
		let url = URL(string: urlString)
		
		Alamofire.request(url!, method: .get, encoding: JSONEncoding.default, headers: ["Content-Type": "application/json"]).responseData{ response in
			switch response.result{
			case .failure( _):
				completionHandler("", ResultStatus.InternetConnection)
				break
			case .success( _):
				if (response.response?.statusCode)! == 200 {
					completionHandler("", ResultStatus.Success)
				}else {
					do{ let json = try JSONSerialization.jsonObject(with: response.data!, options: []) as? [[String:String]]
						if let errorMsg = json?[0]["error"]{ completionHandler(errorMsg, ResultStatus.ServerError) } else{ completionHandler("", ResultStatus.Forbidden) }
					}catch{completionHandler("", ResultStatus.ServerError)}
				}
				break
			}
		}
	}
	public static func uploadFileToBT( fileURL: URL ){
		var data : Data? = nil
		print(fileURL.lastPathComponent)
		do{
			data = try Data(contentsOf: fileURL)
		}catch{
			print("File wasn't found")
			return
		}
		
		var request = URLRequest(url: URL(string: AppGlobal.BacktoryUpload)!)
		request.httpMethod = HTTPMethod.post.rawValue
		request.setValue("Bearer eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiNWI4MmFiZGRlNGIwY2FjMGUxNmZlMTRiIiwiaXNfZ3Vlc3QiOnRydWUsInVzZXJfbmFtZSI6IlVxbTNra2NocDg0aTF1OXMiLCJzY29wZSI6WyJjbGllbnQiXSwiZXhwIjoxNTM2ODUyNzcwLCJqdGkiOiI3NmM0NWQwNi00MWM4LTQ2NTUtYmU0ZC04ZjI1Yjk3NDQzMTIiLCJjbGllbnRfaWQiOiI1YTM0ZDQ3ZGU0YjAxYTI4MTBmMDhmY2UifQ.A2zgKOhz-hqt-jtMhn9eTmqMljvITOKGUjjsJaBeAYtHA84RQmgsw-Lrr_n8Efv8FQUsAWwxjbiDtSkX6FmDbS-WLNDgDJO8G7gbjsP6w5oBN9_tE-LKGu48KNVUOCyQqAvCo5FFRJC8meQ-uBFhlNc55q34QYnmbNjJGDDgGwRISkwKMPzsElWCIqHEIY2KkOv9jIAxzjvGqUnReLrDPoYn-nV--2LrAj4CA0NhnVZDMgDX1aHIwCnnWZiKwzBAcyBLmqLMUVBZajqksCTHkapYaZFu5hqN2XxbB1OxVidqj6CHFtMEF-P_F_Auod0CY4uQWRCK0rIZg1Bcx8pnuw", forHTTPHeaderField: "Authorization")
		request.setValue("5a34d4a5e4b01a2810f0912b", forHTTPHeaderField: "X-Backtory-Storage-Id")
		if let token = UserDefaults.standard.value(forKey: AppGlobal.Token) as? String{
			request.setValue(token, forHTTPHeaderField: "y-storage-token")
		}
		
		print(request.allHTTPHeaderFields)
		//        Alamofire.upload(multipartFormData: { multiPartFormData in
		////            multiPartFormData.append( , withName: "fileItems[0].fileToUpload")
		//            multiPartFormData.append(data!, withName: "fileItems[0].fileToUpload", fileName: fileURL.lastPathComponent, mimeType: "video/mp4" )
		//
		//            multiPartFormData.append( "/path6/".data(using: .utf8)! , withName: "fileItems[0].path")
		//            multiPartFormData.append("5a34d47de4b01a2810f08fce".data(using: .utf8)!, withName: "X-Backtory-Authentication-Id")
		//        }, with: request, encodingCompletion: {
		//            encodingResult in
		//
		//            switch encodingResult {
		//
		//            case .success(let upload, _, _):
		//            upload.responseJSON(completionHandler: {res in
		//                print(res)
		//            })
		//                upload.response { response in
		//                    let statCode = response.response?.statusCode
		//                    if statCode == 201 {
		//                        print("uploaded successfuly!")
		//                    }else{
		//                        print("problem with uploading file, retrying... statusCode : \(String(describing: statCode))")
		//                        print(response.request?.httpBody)
		//
		//                        print(response.response?.description)
		////                        let x = String(data: response.response?.allHeaderFields, encoding: String.Encoding.utf8)
		//                    }
		//                }
		//                break
		//            case .failure(_):
		//                print("problem with uploading file, retrying...")
		//
		//                break
		//            }
		//
		//
		//        })
		
		
	}
}

class RequestHandler : NSObject{
	
	var method : HTTPMethod = .get
	var url : URL!
	var requestType : RequestType!
	var state : RequestState = .initializing
	var request : URLRequest!
	var retryCount = 2
	var showError = true
	var params : Parameters!
	var timeOut : Double = 5
	var sender : UIViewController!
	var stringArray : [String] = []
	var showWaiting = true
	var dialougeBox : DialougeView!
	var forcedToDo : Bool = false
	var buildVersion : String = ""
	
	public init(type: RequestType, requestURL: String, params : Parameters = [:],stringArray : [String] = [], shouldShowError : Bool = false, timeOut : Double = 5, retry: Int = 1,sender : UIViewController?, waiting : Bool = false, force : Bool = false){
		
		if let version = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
			self.buildVersion = version
		}
		self.sender = sender
		self.url = URL(string: requestURL)
		self.timeOut = timeOut
		self.params = params
		self.retryCount = retry
		self.showError = shouldShowError
		self.stringArray = stringArray
		self.showWaiting = waiting
		self.requestType = type
		self.request = URLRequest(url: self.url!)
		self.request.httpMethod = self.method.rawValue
		self.request.setValue("application/json", forHTTPHeaderField: "Content-Type")
		self.request.setValue("ios", forHTTPHeaderField: "devicetype")
		self.request.setValue(buildVersion, forHTTPHeaderField: "buildVersion")
		self.request.setValue("ios", forHTTPHeaderField: "deviceType")
		self.request.timeoutInterval = self.timeOut
		self.forcedToDo = force
		
		if let token = UserDefaults.standard.value(forKey: AppGlobal.Token) as? String{
			if token.characters.count > 2 {
				self.request.setValue(token, forHTTPHeaderField: "USERTOKEN")
				print("user token is : " + token)
			}
		}
		
		switch type {
		case .sing:
			self.method = .post
			self.request.httpMethod = self.method.rawValue
		case .login:
			self.method = .post
			self.request.httpMethod = self.method.rawValue
			self.request.httpBody = try! JSONSerialization.data(withJSONObject: params)
			
			break
		case .signUp:
			self.method = .post
			self.request.httpMethod = self.method.rawValue
			self.request.httpBody = try! JSONSerialization.data(withJSONObject: params)
			
			break
		case .setFavoriteGenres:
			self.method = .post
			self.request.httpMethod = self.method.rawValue
			self.request.httpBody = try! JSONSerialization.data(withJSONObject: self.stringArray)
			break
		case .giftCode:
			self.method = .post
			self.request.httpMethod = self.method.rawValue
			self.request.httpBody = try! JSONSerialization.data(withJSONObject: params)
		case .purchaseLink:
			self.method = .post
			self.request.httpMethod = self.method.rawValue
			self.request.httpBody = try! JSONSerialization.data(withJSONObject: params)
			break
		case .codeVerification:
			self.method = .post
			self.request.httpMethod = self.method.rawValue
			self.request.httpBody = try! JSONSerialization.data(withJSONObject: params)
			break
		case .googleSignIn:
			self.method = .post
			self.request.httpMethod = self.method.rawValue
			self.request.httpBody = try! JSONSerialization.data(withJSONObject: params)
			break
		case .nassabLogin:
			self.method = .post
			self.request.httpMethod = self.method.rawValue
			self.request.httpBody = try! JSONSerialization.data(withJSONObject: params)
			break
		case .updateUserInfo:
			self.method = .post
			self.request.httpMethod = self.method.rawValue
			self.request.httpBody = try! JSONSerialization.data(withJSONObject: params)
			break
		case .actionLog:
			self.method = .post
			self.request.httpMethod = self.method.rawValue
			let list = AppManager.sharedInstance().getActionList().list
			var param : [Any] = []
			for item in list{
				param.append(["action" : item.action, "session" : item.session , "detail" : item.detail, "timestamp" : item.timestamp])
			}
			self.request.httpBody = try! JSONSerialization.data(withJSONObject: param)
			break
		case .handShake:
			self.method = .post
			self.request.httpMethod = self.method.rawValue
			self.request.httpBody = try! JSONSerialization.data(withJSONObject: params)
			break
		default:
			break
		}
		
		if self.showWaiting{
			self.dialougeBox = DialougeView()
			self.dialougeBox.waitingBox(vc: self.sender)
		}
	}
	
	public func sendRequest(completionHandler: @escaping (Any? , Bool, String?) -> ()){
		
		if self.requestType == .setFavoriteGenres || self.requestType == .actionLog {
			Alamofire.request(self.request!).response(completionHandler:{
				response in
				if response.error == nil {
					print(self.requestType.debugDescription + " done with code: \(response.response?.statusCode)")
					if  response.response?.statusCode == 202 || response.response?.statusCode == 201 || response.response?.statusCode == 200 {
						completionHandler(nil, true, nil)
					}else{
						self.failed(){ Data,Success,msg in
							completionHandler(Data, Success, msg)
							if self.showWaiting { self.dialougeBox.hide() }
						}
					}
					
				}else{
					print(self.requestType.debugDescription + " failed request)")
					print("headers: " + ( self.request.allHTTPHeaderFields?.description ?? "" ))
					print("body: " + (self.params != nil ? self.params.description : "no params"))
					
					self.failed(){ Data,Success,msg in
						completionHandler(Data, Success, msg)
						if self.showWaiting { self.dialougeBox.hide() }
					}
				}
			})
		}else if self.requestType == .purchaseLink {
			Alamofire.request(self.request!).responseString(completionHandler:{
				response in
				switch response.result{
				case .failure( _):
					self.failed(){ Data,Success,msg in
						completionHandler(Data, Success, msg)
						if self.showWaiting { self.dialougeBox.hide() }
					}
					break
				case .success( _):
					print(self.requestType.debugDescription + " done with code: \(response.response?.statusCode)")
					if (response.response?.statusCode)! == 200 {
						print(response.result.value!)
						var url = response.result.value!
						url.remove(at: url.index(of: "\"")!)
						url.remove(at: url.index(of: "\"")!)
						if self.showWaiting { self.dialougeBox.hide() }
						completionHandler(url, true, nil)
					}else{
						print(self.requestType.debugDescription + " failed request)")
						print("headers: " + ( self.request.allHTTPHeaderFields?.description ?? "" ))
						print("body: " + (self.params != nil ? self.params.description : "no params"))
						self.failed(){ Data,Success,msg in
							completionHandler(Data, Success, msg)
							if self.showWaiting { self.dialougeBox.hide() }
						}
					}
					break
				}
			})
		}else {
			Alamofire.request(self.request!).responseJSON(completionHandler:{
				response in
				
				
				switch response.result{
				case .failure( _):
					print(self.requestType.debugDescription + " failed request)")
					print("headers: " + ( self.request.allHTTPHeaderFields?.description ?? "" ))
					print("body: " + (self.params != nil ? self.params.description : "no params"))
					print(self.request.url?.absoluteString)
					print(response.error)
					self.failed(){ Data,Success,msg in
						completionHandler(Data, Success, msg)
						if self.showWaiting { self.dialougeBox.hide() }
					}
					break
				case .success( _):
					
					print(self.requestType.debugDescription + " done with code: \(response.response?.statusCode)")
					
					if (response.response?.statusCode)! == 200 {
						self.parseRecievedData(response: response){
							Data, Success, msg in
							if Success{ completionHandler(Data,Success, msg)
								if self.showWaiting { self.dialougeBox.hide() }
							}
							else{
								self.failed(){ Data,Success, msg in
									completionHandler(Data, Success, msg)
									if self.showWaiting { self.dialougeBox.hide() }
								}
							}
						}
					}else if (response.response?.statusCode)! == 426  {
						if self.dialougeBox != nil {
							self.dialougeBox.hide()
						}else{
							self.dialougeBox = DialougeView()
						}
						if self.sender != nil{
							do{ let json = try JSONSerialization.jsonObject(with: response.data!, options: []) as? [String:String]
								if let url = json?["url"]{ self.dialougeBox.update(force: true, downloadURL: url, vc: self.sender) }
							}catch{}
						}
					}else{
						if self.requestType == .login || self.requestType == .signUp || self.requestType == .giftCode{
							self.parseRecievedData(response: response){
								Data, Success, msg in
								if Success{ completionHandler(Data,false, msg)
									if self.showWaiting { self.dialougeBox.hide() }
								}
								else{
									self.failed(){ Data,Success, msg in
										completionHandler(Data, Success, msg)
										if self.showWaiting { self.dialougeBox.hide() }
									}
								}
							}
						}else if (response.response?.statusCode)! == 401{
							self.forbidden()
							completionHandler(nil,false,nil)
							if self.showWaiting { self.dialougeBox.hide() }
						}else if (response.response?.statusCode)! == 403{
							completionHandler(nil,false,AppGlobal.SHOULD_BUY)
							if self.showWaiting { self.dialougeBox.hide() }
						}else if (self.requestType == .codeVerification || self.requestType == .googleSignIn || self.requestType == .updateUserInfo) && (response.response?.statusCode)! == 400 {
							if self.showWaiting { self.dialougeBox.hide() }
							completionHandler(nil,false,"کد وارد شده اشتباه است")
						}else if (response.response?.statusCode)! == 402{
							//PAYMENT REQUIRED
							completionHandler(nil, false, AppGlobal.PAYMENT_REQUIRED)
							if self.showWaiting { self.dialougeBox.hide() }
						}else{
							self.failed(){ Data,Success, msg in
								completionHandler(Data, Success, msg)
								if self.showWaiting { self.dialougeBox.hide() }
							}
						}
						
					}
					break
				}
			})
		}
	}
	
	
	public func parseRecievedData(response : DataResponse<Any> , completionHandler: @escaping (Any? , Bool, String?) -> ()){
		
		if  self.requestType == .signUp{
			
			
			if (response.response?.statusCode)! == 200{
				do{ let json = try JSONSerialization.jsonObject(with: response.data!, options: []) as? [String:String]
					if let username = json?["username"]{ completionHandler(username, true,nil) }
					else{ completionHandler(nil, false, nil) }
				}catch{
					completionHandler(nil, true, nil)
				}
			}
			else{
				do{ let json = try JSONSerialization.jsonObject(with: response.data!, options: []) as? [[String:String]]
					if let errorMsg = json?[0]["error"]{ completionHandler(nil, true, errorMsg) } else{ completionHandler(nil, false, nil) }
				}catch{ completionHandler(nil, false, nil) }
			}
			
		}else if self.requestType == .genreList{
			
			
			let result = GenresList(data: response.data!)
			if result.count != 0 {
				let cache = result.toJsonString()
				UserDefaults.standard.set(cache, forKey: AppGlobal.GenresListCache)
				completionHandler(result,true,nil )
			}else{ completionHandler(nil,false,nil) }
			
		}else if self.requestType == .feedList{
			
			
			let result = FeedsList(data: response.data!)
			if result.count != 0 {
				let cache = result.toJsonString()
				UserDefaults.standard.set(cache, forKey: AppGlobal.Feed)
				completionHandler(result,true,nil )
			}else{ completionHandler(nil,false,nil) }
			
		}else if self.requestType == .genrePosts{
			
			
			let result = genre_more(data: response.data!)
			if (response.response?.statusCode)! == 200{
				completionHandler(result, true, nil)
			}else{ completionHandler(nil,false,nil) }
			
		}else if self.requestType == .userInfo || self.requestType == .updateUserInfo{
			
			let result = user(data: response.data!)
			completionHandler(result, true, nil)
			
		}else if self.requestType == .bannersList{
			
			
			let result = bannersList(data: response.data!)
			if result.count != 0{
				completionHandler(result, true, nil)
			}else{ completionHandler(nil, false, nil)}
		}else if self.requestType == .packageList{
			
			let result = packagesList(data: response.data!)
			if !result.results.isEmpty{
				completionHandler(result, true, nil)
			}else{ completionHandler(nil, false, nil)}
			
		}else if self.requestType == .codeVerification || self.requestType == .googleSignIn || self.requestType == .nassabLogin {
			
			do{
				let json = try JSONSerialization.jsonObject(with: response.data!, options: []) as? [String:Any]
				let params = ["token" : json!["token"] as! String , "new_user" : json!["new_user"] as! Bool  ] as [String : Any]
				completionHandler(params, true, nil)
				
			}catch{ completionHandler(nil, false, nil) }
			
		}else if self.requestType == .handShake {
			
			let result = handShakeResult(data: response.data!)
			completionHandler(result, true, nil)
		}else if self.requestType == .karaoke {
			let result = karaoke(data: response.data!)
			completionHandler(result, true, nil)
		}else if self.requestType == .homeFeed{
			
			let json = try! JSONSerialization.jsonObject(with: response.data!, options: []) as! [NSDictionary]
			var results : [karaList] = []
			
			for item in json{
				let list = karaList(dictionary: item)
				results.append(list)
			}
			completionHandler(results, true, nil)
		}else if self.requestType == .inventory{
			let result = UserInventory(data: response.data!)
			completionHandler(result, true, nil)
		}else if self.requestType == .sing{
			let result = UserInventory(data: response.data!)
			completionHandler(result, true, nil)
		}else if self.requestType == .avatarsList{
			let result = AvatarsList(data: response.data!)
			completionHandler(result, true, nil)
		}else if self.requestType == .giftCode{
			
			if (response.response?.statusCode)! == 200{
				let result = UserInventory(data: response.data!)
				AppManager.sharedInstance().inventory = result
				AppManager.sharedInstance().userInfo.coins = result.coins
				AppManager.sharedInstance().userInfo.premium_days = result.days
				completionHandler(nil, true, nil)
			}
			else{
				do{ let json = try JSONSerialization.jsonObject(with: response.data!, options: []) as? [[String:String]]
					if let errorMsg = json?[0]["error"]{ completionHandler(nil, true, errorMsg) } else{ completionHandler(nil, false, nil) }
				}catch{ completionHandler(nil, false, nil) }
			}
			
		}
	}
	
	
	public func forbidden(){
		UserDefaults.standard.setValue("", forKey: AppGlobal.Token)
		UserDefaults.standard.setValue("", forKey: AppGlobal.userInfoCache)
		
		if sender == nil {
			if var topController = UIApplication.shared.keyWindow?.rootViewController {
				while let presentedViewController = topController.presentedViewController {
					topController = presentedViewController
				}
				let vc = topController.storyboard?.instantiateViewController(withIdentifier: "LoginMethod")
				topController.present(vc!, animated: true, completion: nil)
			}
		}else{
			let vc = self.sender.storyboard?.instantiateViewController(withIdentifier: "LoginMethod")
			self.sender.present(vc!, animated: true, completion: nil)
		}
	}
	
	public func failed(completionHandler: @escaping (Any? , Bool, String?) -> ()){
		//retry manager
		
		if self.retryCount > 0{
			self.retryCount -= 1
			print("retrying request")
			self.sendRequest(){
				data,success,msg in
				completionHandler(data,success,msg)
			}
		}else if self.showError{
			//check if is showing waiting and hide it
			if self.showWaiting { self.dialougeBox.hide() }
			self.dialougeBox = DialougeView()
			self.dialougeBox.internetConnectionError(vc: sender, completionHandler: { retry in
				self.dialougeBox.hide()
				if retry{
					if self.showWaiting{self.dialougeBox.waitingBox(vc: self.sender) }
					self.retryCount = 2
					self.sendRequest(){
						data,success,msg in
						completionHandler(data,success,msg)
					}
				}else if self.forcedToDo{
					self.dialougeBox.hide()
					if self.showWaiting{self.dialougeBox.waitingBox(vc: self.sender)}
					self.retryCount = 2
					self.sendRequest(){
						data,success,msg in
						completionHandler(data,success,msg)
					}
				}
				else{
					completionHandler(nil, false, nil)
				}
			})
		}else{
			completionHandler(nil, false, nil)
		}
	}
	
}


