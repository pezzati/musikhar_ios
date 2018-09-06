//
//  API_Handler.swift
//  Canto
//
//  Created by WhoTan on 12/3/17.
//  Copyright © 2017 WhoTan. All rights reserved.
//

import UIKit
import Alamofire

class API_Handler: NSObject {
    
    /*
    public static func signUp(params : Parameters, completionHandler: @escaping (String, ResultStatus) -> ()){
        let url = URL(string: AppGlobal.UserSignupURL)
        Alamofire.request(url!, method: .post, parameters: params , encoding: JSONEncoding.default, headers: ["Content-Type": "application/json"]).responseJSON{ response in
            switch response.result{
            case .failure( _):
                print(response.description)
                completionHandler("", ResultStatus.InternetConnection)
                break
            case .success( _):
                if (response.response?.statusCode)! == 200 {
                    do{ let json = try JSONSerialization.jsonObject(with: response.data!, options: []) as? [String:String]
                        if let token = json?["token"]{ completionHandler(token, ResultStatus.Success) }
                        else{ completionHandler("", ResultStatus.ServerError) }
                    }catch{}
                }else{
                    do{ let json = try JSONSerialization.jsonObject(with: response.data!, options: []) as? [[String:String]]
                        if let errorMsg = json?[0]["error"]{ completionHandler(errorMsg, ResultStatus.ServerError) } else{ completionHandler("", ResultStatus.ServerError) }
                    }catch{}
                }
                break
        }
    }
    }
    */
    
    /*
    public static func login(params : Parameters, completionHandler: @escaping (String, ResultStatus) -> ()){
        let url = URL(string: AppGlobal.UserLoginURL)
        Alamofire.request(url!, method: .post, parameters: params , encoding: JSONEncoding.default, headers: ["Content-Type": "application/json"]).responseJSON{ response in
            switch response.result{
            case .failure( _):
                completionHandler("", ResultStatus.InternetConnection)
                break
            case .success( _):
                if (response.response?.statusCode)! == 200 {
                    do{ let json = try JSONSerialization.jsonObject(with: response.data!, options: []) as? [String:String]
                        if let token = json?["token"]{ completionHandler(token, ResultStatus.Success) }
                        else{ completionHandler("", ResultStatus.ServerError) }
                    }catch{}
                }else{
                    do{ let json = try JSONSerialization.jsonObject(with: response.data!, options: []) as? [[String:String]]
                        if let errorMsg = json?[0]["error"]{ completionHandler(errorMsg, ResultStatus.ServerError) } else{ completionHandler("", ResultStatus.ServerError) }
                    }catch{}
                }
                break
            }
        }
    }
    */
    
    /*public static func submitVerificationCode(params : Parameters, completionHandler: @escaping (String, ResultStatus) -> ()){
        let url = URL(string: AppGlobal.SubmitVerificationCode)
        Alamofire.request(url!, method: .post, parameters: params , encoding: JSONEncoding.default, headers: ["Content-Type": "application/json", "USERTOKEN" : UserDefaults.standard.value(forKey: AppGlobal.Token) as! String]).responseJSON{ response in
            
            if response.response?.statusCode == 200{
                completionHandler("", ResultStatus.Success)
                print("Verification Successful")
            }else{
            
            switch response.result{
            case .failure( _):
                completionHandler("", ResultStatus.InternetConnection)
                break
            case .success( _):
                if (response.response?.statusCode)! == 200 {
                        completionHandler("", ResultStatus.Success)
                        print("Verification Successful")
                }else if (response.response?.statusCode)! == 401 {
                    do{ let json = try JSONSerialization.jsonObject(with: response.data!, options: []) as? [[String:String]]
                        if let errorMsg = json?[0]["error"]{ completionHandler(errorMsg, ResultStatus.Forbidden) } else{ completionHandler("", ResultStatus.Forbidden) }
                    }catch{completionHandler("", ResultStatus.Forbidden)}
                }else {
                    do{ let json = try JSONSerialization.jsonObject(with: response.data!, options: []) as? [[String:String]]
                        if let errorMsg = json?[0]["error"]{ completionHandler(errorMsg, ResultStatus.ServerError) } else{ completionHandler("", ResultStatus.ServerError) }
                    }catch{completionHandler("", ResultStatus.ServerError)}
                }
                break
            }
            }
        }
    }*/
    
    public static func resendVerificationCode(mobile: String, email: String, completionHandler: @escaping (String, ResultStatus) -> ()){
//        "user/profile/verify?context=&username="
        
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
    
    /*
    public static func getHomeList( completionHandler: @escaping (homeKaraokeFeed? , ResultStatus) -> ()){
        
        let requestURL = URL(string: AppGlobal.HomeFeed)
        Alamofire.request(requestURL!, method: .get, encoding: JSONEncoding.default, headers: ["Content-Type": "application/json" , "USERTOKEN" : UserDefaults.standard.value(forKey: AppGlobal.Token) as! String]).responseArray{ (response: DataResponse<[homeGenre]>) in
            
            switch response.result{
            case .failure(let error):
                print("Request failed with error: " + String(describing: error))
                completionHandler(nil, .InternetConnection)
                break
                
            case .success( _):
                if((response.response?.statusCode)! == 200){
                    print("Request sent successfuly")
                    let feed = homeKaraokeFeed()
                    if let result = response.result.value {
                        for item in result {
                            feed.genres.append(item)
                        }
                    }
                    let cache = feed.toJsonString()
                    UserDefaults.standard.set(cache, forKey: AppGlobal.HomeFeedCache)
                    
                    completionHandler(feed, .Success)
                }else if((response.response?.statusCode)! < 410 && (response.response?.statusCode)! >= 400){
                    print("Forbidden")
                    completionHandler(nil, .Forbidden)
                }else{
                    print("Request returned error with status code: " + String(describing: response.response!.statusCode) + "JSON : " + String(describing: response.data))
                    completionHandler(nil, .ServerError)
                }
            }
        }
    }
    
    */
    
//    public static func getGenrePosts(url : String, completionHandler: @escaping (genre_more? , ResultStatus) -> ()){
//
//        let requestURL = URL(string: url)
//        Alamofire.request(requestURL!, method: .get, encoding: JSONEncoding.default, headers: ["Content-Type": "application/json" , "USERTOKEN" : UserDefaults.standard.value(forKey: AppGlobal.Token) as! String]).responseData{ response in
//
//            switch response.result{
//            case .failure(let error):
//                print("Request failed with error: " + String(describing: error))
//                completionHandler(nil, .InternetConnection)
//                break
//
//            case .success( _):
//                if((response.response?.statusCode)! == 200){
//                    print("Request sent successfuly")
//                     let results = genre_more(data: response.data!)
//                    completionHandler(results, .Success)
//                }else if((response.response?.statusCode)! < 410 && (response.response?.statusCode)! >= 400){
//                    print("Forbidden")
//                    completionHandler(nil, .Forbidden)
//                }else{
//                    print("Request returned error with status code: " + String(describing: response.response!.statusCode) + "JSON : " + String(describing: response.data))
//                    completionHandler(nil, .ServerError)
//                }
//            }
//        }
//    }
    /*
    public static func getUserInfo(completionHandler: @escaping (user? , ResultStatus) -> ()){
        
        let requestURL = URL(string: AppGlobal.UserProfileURL)
        Alamofire.request(requestURL!, method: .get, encoding: JSONEncoding.default, headers: ["Content-Type": "application/json" , "USERTOKEN" : UserDefaults.standard.value(forKey: AppGlobal.Token) as! String]).responseData{ response in
            
            switch response.result{
            case .failure(let error):
                print("Request failed with error: " + String(describing: error))
                completionHandler(nil, .InternetConnection)
                break
                
            case .success( _):
                if((response.response?.statusCode)! == 200){
                    print("Request sent successfuly")
                    let results = user(data: response.data!)
                    completionHandler(results, .Success)
                }else if((response.response?.statusCode)! < 410 && (response.response?.statusCode)! >= 400){
                    print("Forbidden")
                    completionHandler(nil, .Forbidden)
                }else{
                    print("Request returned error with status code: " + String(describing: response.response!.statusCode) + "JSON : " + String(describing: response.data))
                    completionHandler(nil, .ServerError)
                }
            }
        }
    }
    */
    
    /*
    public static func getHomeBannerList( completionHandler: @escaping (bannersList? , ResultStatus) -> ()){
        
        let requestURL = URL(string: AppGlobal.HomeBannersList)
        Alamofire.request(requestURL!, method: .get, encoding: JSONEncoding.default, headers: ["Content-Type": "application/json" , "USERTOKEN" : UserDefaults.standard.value(forKey: AppGlobal.Token) as! String]).responseData{ response in
            
            switch response.result{
            case .failure(let error):
                print("Request failed with error: " + String(describing: error))
                completionHandler(nil, .InternetConnection)
                break
                
            case .success( _):
                if((response.response?.statusCode)! == 200){
                    print("Request sent successfuly")
                    let res = bannersList(data: response.data!)
                    let cache = res.toJsonString()
                    UserDefaults.standard.set(cache, forKey: AppGlobal.BannersCache)
                    completionHandler(res, .Success)
                    
                }else if((response.response?.statusCode)! < 410 && (response.response?.statusCode)! >= 400){
                    print("Forbidden")
                    completionHandler(nil, .Forbidden)
                }else{
                    print("Request returned error with status code: " + String(describing: response.response!.statusCode) + "JSON : " + String(describing: response.data))
                    completionHandler(nil, .ServerError)
                }
            }
        }
    }
    */
    
    /*
    public static func getGenreList(completionHandler: @escaping (GenresList? , ResultStatus) -> ()){
        
        
        let requestURL = URL(string: AppGlobal.GenresListURL)
        
        Alamofire.request(requestURL!, method: .get, encoding: JSONEncoding.default, headers: ["Content-Type": "application/json" , "USERTOKEN" : UserDefaults.standard.value(forKey: AppGlobal.Token) as! String]).responseData{ response in
            
            switch response.result{
            case .failure(let error):
                print("Request failed with error: " + String(describing: error))
                completionHandler(nil, .InternetConnection)
                break
                
            case .success( _):
                if((response.response?.statusCode)! == 200){
                    print("Request sent successfuly")
                    let res = GenresList(data: response.data!)
                    let cache = res.toJsonString()
                    UserDefaults.standard.set(cache, forKey: AppGlobal.GenresListCache)
                    completionHandler(res, .Success)
                    
                }else if((response.response?.statusCode)! < 410 && (response.response?.statusCode)! >= 400){
                    print("Forbidden")
                    completionHandler(nil, .Forbidden)
                }else{
                    print("Request returned error with status code: " + String(describing: response.response!.statusCode) + "JSON : " + String(describing: response.data))
                    completionHandler(nil, .ServerError)
                }
            }
        }
    }
    */
    
    /*
    public static func setFavoriteGenres(reqMethod : HTTPMethod, params : [String], completionHandler: @escaping (ResultStatus) -> ()){
        
        let requestURL = URL(string: AppGlobal.SetFavoriteGenresURL)
        
        var request = URLRequest(url: requestURL!)
        request.httpMethod = reqMethod.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(UserDefaults.standard.value(forKey: AppGlobal.Token) as! String, forHTTPHeaderField: "USERTOKEN" )
        
        request.httpBody = try! JSONSerialization.data(withJSONObject: params)
        
        
        Alamofire.request(request).response { response in

            if response.error == nil{
               if((response.response?.statusCode)! < 210 && (response.response?.statusCode)! >= 200){
                    print("SUCCESS")
                    completionHandler(.Success)
                }else{
                    print("Request returned error with status code: " + String(describing: response.response!.statusCode) + "JSON : " + String(describing: response.data))
                    completionHandler(.ServerError)
                }
        } else {
                print("Request returned error with : " + response.error.debugDescription  )
            completionHandler(.InternetConnection)
        }
        }
    }
    */
    
//    public static func getSingleKara(karaURL : String, completionHandler: @escaping (karaoke? , ResultStatus) -> ()){
//
//        let requestURL = URL(string: karaURL)
//
//        Alamofire.request(requestURL!, method: .get, encoding: JSONEncoding.default, headers: ["Content-Type": "application/json" , "USERTOKEN" : UserDefaults.standard.value(forKey: AppGlobal.Token) as! String]).responseData{ response in
//
//            switch response.result{
//            case .failure(let error):
//                print("Request failed with error: " + String(describing: error))
//                completionHandler(nil, .InternetConnection)
//                break
//
//            case .success( _):
//                if((response.response?.statusCode)! == 200){
//                    print("Request sent successfuly")
//                    let res = karaoke(data: response.data!)
//                    completionHandler(res, .Success)
//
//                }else if((response.response?.statusCode)! < 410 && (response.response?.statusCode)! >= 400){
//                    print("Forbidden")
//                    completionHandler(nil, .Forbidden)
//                }else{
//                    print("Request failed !" )
//                    completionHandler(nil, .ServerError)
//                }
//            }
//        }
//    }
    
    
//    public static func getPackages( completionHandler: @escaping (packagesList? , ResultStatus) -> ()){
//
//
//        let requestURL = URL(string: AppGlobal.PackagesList)
//
//        Alamofire.request(requestURL!, method: .get, encoding: JSONEncoding.default, headers: ["Content-Type": "application/json" , "USERTOKEN" : UserDefaults.standard.value(forKey: AppGlobal.Token) as! String]).responseData{ response in
//
//            switch response.result{
//            case .failure(let error):
//                print("Request failed with error: " + String(describing: error))
//                completionHandler(nil, .InternetConnection)
//                break
//
//            case .success( _):
//                if((response.response?.statusCode)! == 200){
//
//                    let res = packagesList(data: response.data!)
//                    completionHandler(res, .Success)
//
//                }else if((response.response?.statusCode)! < 410 && (response.response?.statusCode)! >= 400){
//                    print("Forbidden")
//                    completionHandler(nil, .Forbidden)
//                }else{
//                    print("Request failed !" )
//                    completionHandler(nil, .ServerError)
//                }
//            }
//        }
//    }
    
    
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
                    if  response.response?.statusCode == 202 || response.response?.statusCode == 201 || response.response?.statusCode == 200 {
                        completionHandler(nil, true, nil)
                    }else{
                        self.failed(){ Data,Success,msg in
                            completionHandler(Data, Success, msg)
                            if self.showWaiting { self.dialougeBox.hide() }
                        }
                    }
                    
                }else{
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
                   if (response.response?.statusCode)! == 200 {
                        print(response.result.value!)
                        var url = response.result.value!
                        url.remove(at: url.index(of: "\"")!)
                        url.remove(at: url.index(of: "\"")!)
                    completionHandler(url, true, nil)
                   }else{
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
                    self.failed(){ Data,Success,msg in
                        completionHandler(Data, Success, msg)
                        if self.showWaiting { self.dialougeBox.hide() }
                    }
                    break
                case .success( _):
                    
                    print(response.response?.statusCode)
                    
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
                       if self.requestType == .login || self.requestType == .signUp{
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
                        }else if (response.response?.statusCode)! == 403{
                            self.forbidden()
                            completionHandler(nil,false,nil)
                            if self.showWaiting { self.dialougeBox.hide() }
                        }else if (self.requestType == .codeVerification || self.requestType == .googleSignIn) && (response.response?.statusCode)! == 400 {
                            if self.showWaiting { self.dialougeBox.hide() }
                            completionHandler(nil,false,"کد وارد شده اشتباه است")
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
        }
    }
    
    
    public func forbidden(){
        UserDefaults.standard.setValue("", forKey: AppGlobal.Token)
        UserDefaults.standard.setValue("", forKey: AppGlobal.userInfoCache)
        let vc = self.sender.storyboard?.instantiateViewController(withIdentifier: "login")
        self.sender.present(vc!, animated: true, completion: nil)
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


