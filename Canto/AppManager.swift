//
//  AppManager.swift
//  Canto
//
//  Created by WhoTan on 4/20/18.
//  Copyright © 2018 WhoTan. All rights reserved.
//

import UIKit
import AVFoundation

class AppManager: NSObject {
    
    private static var shared: AppManager = {
        let shared = AppManager()
        shared.cachedHomeFeed()
        shared.cachedUserInfo()
        return shared
    }()
    
    class func sharedInstance() -> AppManager{
        return shared
    }
    
    
    //MARK: -Karaokes
    
        private var homeFeed : [Genre] = []
    
        private func cachedHomeFeed(){
        var result : [Genre] = []
        
        if let cachedListString = UserDefaults.standard.value(forKey: AppGlobal.GenresListCache) as? String {
            let cachedGenreList = GenresList(json: cachedListString)
        
            let news = Genre()
            news.name = "تازه ها"
            news.files_link = AppGlobal.NewKaraokesGenre
            result.append(news)
            
            let popular = Genre()
            popular.name = "محبوب ها"
            popular.files_link = AppGlobal.PopularKaraokesGenre
            result.append(popular)
          
//            let free = Genre()
//            free.name = "رایگان این هفته"
//            free.files_link = AppGlobal.FreeKaraokesGenre
//            result.append(free)
            
            for item in cachedGenreList.results{
                if item.liked_it{
                    result.append(item)
                }
            }
            
            for genre in result{
                if let genreString = UserDefaults.standard.value(forKey: genre.files_link) as? String {
                    let genreCache = genre_more(json: genreString)
                    genre.karas = genreCache
                }else{
                 genre.karas = genre_more()
                }
            }
            self.homeFeed = result
        }
    }
    
    public func getHomeFeed() -> [Genre]{
        self.cachedHomeFeed()
        return self.homeFeed
    }
    
    public func clearGenresCache() {
        var result : [Genre] = []
        
        if let cachedListString = UserDefaults.standard.value(forKey: AppGlobal.GenresListCache) as? String {
            let cachedGenreList = GenresList(json: cachedListString)
            
            let news = Genre()
            news.name = "تازه ها"
            news.files_link = AppGlobal.NewKaraokesGenre
            result.append(news)
            
            let popular = Genre()
            popular.name = "محبوب ها"
            popular.files_link = AppGlobal.PopularKaraokesGenre
            result.append(popular)
            
            let free = Genre()
            free.name = "رایگان این هفته"
            free.files_link = AppGlobal.FreeKaraokesGenre
            result.append(free)
            
            for item in cachedGenreList.results{
                if item.liked_it{
                    result.append(item)
                }
            }
            
            for genre in result{
                if let genreString = UserDefaults.standard.value(forKey: genre.files_link) as? String {
                    UserDefaults.standard.set(nil, forKey: genre.files_link)
                }
            }
            UserDefaults.standard.set(nil, forKey: AppGlobal.GenresListCache)
        }
        
        
        
    }
    
    
    public func getContent(url: String, sender: UIViewController, completionHandler: @escaping (Bool, karaoke?) -> ()){
        var didCallBack = false
        
        if let cachedKara = UserDefaults.standard.value(forKey: url) as? String{
            let kara = karaoke(json: cachedKara)
            completionHandler(true, kara)
            didCallBack = true
        }
        
        let request = RequestHandler(type: .karaoke , requestURL: url, shouldShowError: !didCallBack, retry: 1, sender: sender, waiting: !didCallBack, force: false)
        request.sendRequest(completionHandler: {
            data, success, msg in
            if success{
                if let kara = data as? karaoke{
                    UserDefaults.standard.setValue(kara.toJsonString(), forKey: url)
                    if !didCallBack{ completionHandler(true, kara) }
                }else{
                    if !didCallBack { completionHandler(false, nil) }
                }
            }else{
                if !didCallBack{ completionHandler(false, nil)}
            }
        })
        
        
        
        
    }
    
    var lastFetchTime : Int = 0
    
    public func fetchHomeFeed(sender: UIViewController, force : Bool = false, all : Bool = false,completionHandler: @escaping (Bool) -> ()){
        var loaded = true
        
        if self.homeFeed.count < 3 {
            loaded = false
        }
        
        for item in self.homeFeed{
            if item.karas.results.count == 0 {
                loaded = false
            }
        }
        
        if loaded && Int(Date.timeIntervalSinceReferenceDate) - lastFetchTime < 1800{
            completionHandler(true)
            return
        }
        
        
        
        let request = RequestHandler(type: .genreList , requestURL: AppGlobal.GenresListURL, shouldShowError: force, retry: 1, sender: sender, waiting: force, force: force)
        request.sendRequest(completionHandler: {
            data, success, msg in
            
            if success{
            var temp = (data as! GenresList).results
            UserDefaults.standard.set((data as! GenresList).toJsonString(), forKey: AppGlobal.GenresListCache)
            var result : [Genre] = []
                
                let news = Genre()
                news.name = "تازه ها"
                news.files_link = AppGlobal.NewKaraokesGenre
                result.append(news)
                
                let popular = Genre()
                popular.name = "محبوب ها"
                popular.files_link = AppGlobal.PopularKaraokesGenre
                result.append(popular)
                
//                let free = Genre()
//                free.name = "رایگان این هفته"
//                free.files_link = AppGlobal.FreeKaraokesGenre
//                result.append(free)
                
          
                for item in temp{
                    if item.liked_it || all{
                        result.append(item)
                    }
                }
                
            
            let dialogue = DialougeView()
            
            if force{ dialogue.waitingBox(vc: sender) }
            
            var counter = result.count
                for genre in result{
                     let req = RequestHandler(type: .genrePosts , requestURL: genre.files_link, shouldShowError: false, retry: 1, sender: sender, waiting: false, force: false)
                    
                    req.sendRequest(completionHandler: {karaokes, success, msg in
                        if success {
                            genre.karas = karaokes as! genre_more
                            self.homeFeed = result
                            UserDefaults.standard.set(genre.karas.toJsonString() , forKey: genre.files_link)
                            counter -= 1
                            if counter == 0 {
                                if force {dialogue.hide() }
                                completionHandler(success)
                                self.lastFetchTime = Int(Date.timeIntervalSinceReferenceDate)
                            }
                        }else{
                            if force{
                            dialogue.hide()
                            dialogue.internetConnectionError(vc: sender, completionHandler: {
                                retry in
                                dialogue.hide()
                                self.fetchHomeFeed(sender: sender, force: force, completionHandler: {
                                    isSuccess in
                                    completionHandler(isSuccess)
                                })
                            })
                            }else {completionHandler(success)}
                        }
                    })
                }
        }
        })
    }
    
    
    
    
    
    //MARK: -UserInfo
    private var userInfo : user!
    
    public var shouldGetUserInfo = false
    
    private func cachedUserInfo(){
        
        self.updateUserPhoto()
        if let cachedInfo = UserDefaults.standard.value(forKey: AppGlobal.userInfoCache) as? String{
            self.userInfo = user(json: cachedInfo)
        }else{
            self.userInfo = user()
        }
        if !userAvatarSet { self.updateUserPhoto() }
    }
    
    public func getUserInfo() -> user{
        self.cachedUserInfo()
        return self.userInfo
    }
    
    public func fetchUserInfo(sender: UIViewController, force: Bool = false, completionHandler: @escaping (Bool) -> ()){
        
        let request = RequestHandler(type: .userInfo , requestURL: AppGlobal.UserProfileURL, shouldShowError: force, timeOut: 5, retry: 2, sender: sender, waiting: force, force: force)
        request.sendRequest(completionHandler: {data, success, msg in
            if success {
                self.userInfo = data as! user
                UserDefaults.standard.setValue(self.userInfo.toJsonString(), forKey: AppGlobal.userInfoCache)
            }
            completionHandler(success)
            self.shouldGetUserInfo = false
        })
    }
    
    public var userAvatar = UIImage(named: "userPH")
    public var userAvatarSet = false
    
    public func updateUserPhoto(){
        
        if let photoData = UserDefaults.standard.object(forKey: "UserImage") as? Data{
            if let image = UIImage(data: photoData) {
                self.userAvatar = image
                self.userAvatarSet = true
            }
        }
    }
    
    
    
    
    

    //MARK: -UserPosts
    private var userPosts : userPostsList = userPostsList()
    
    public func getUserPostsList() -> userPostsList{
        
            if let jsonString = UserDefaults.standard.value(forKey: AppGlobal.UserPostsList ) as? String{
                let posts = userPostsList(json: jsonString)
                self.userPosts = posts
                return posts
            }else{
              UserDefaults.standard.set(userPostsList().toJsonString(), forKey: AppGlobal.UserPostsList)
        }
        return userPostsList()
    }
    
    public func addUserPost(post: userPost){
        let previousPostList = self.getUserPostsList()
        previousPostList.posts.insert(post, at: 0)
        UserDefaults.standard.set(previousPostList.toJsonString(), forKey: AppGlobal.UserPostsList )
        self.userPosts = previousPostList
    }
    
    public func removeUserPost(index: Int, fileURL: URL ){
        let currentPostList = self.getUserPostsList()
        currentPostList.posts.remove(at: index)
        do{ try? FileManager.default.removeItem(at: fileURL) }
        UserDefaults.standard.set(currentPostList.toJsonString(), forKey: AppGlobal.UserPostsList )
        self.userPosts = currentPostList
    }
    
    //MARK: -Action Log
    
    func getActionList() -> ActionLogList{
        var list = ActionLogList()
        if let jsonString = UserDefaults.standard.value(forKey: AppGlobal.ActionLogList) as? String{
            list = ActionLogList(json: jsonString)
        }
        return list
    }
    
    
    func addAction(action : String,session: String , detail: String){
        
        let list = self.getActionList()
        let log = ActionLog()
        log.action = action
        log.detail = detail
        log.session = session
        log.timestamp =  Int(Int(Date.timeIntervalSinceReferenceDate) + Int(Date.timeIntervalBetween1970AndReferenceDate)).description
        
        print("user action added for \(action)  \n \(session) \n  \(detail) \n  \(log.timestamp) \n count : \(list.list.count) " )
        list.list.append(log)
        UserDefaults.standard.set(list.toJsonString(), forKey: AppGlobal.ActionLogList)
    }
    
    var isSendingActions = false
    
    func sendActions(){
        
        if !isSendingActions{
        let actions = self.getActionList()
        if actions.list.count > 9{
            let request = RequestHandler(type: .actionLog, requestURL: AppGlobal.UserActionsLog, params: [:], retry: 0  , sender: nil)
            isSendingActions = true
            request.sendRequest(completionHandler: { data, success , msg in
                
                if success{
                    let list = ActionLogList()
                    UserDefaults.standard.set(list.toJsonString(), forKey: AppGlobal.ActionLogList)
                    print("Actions sent successfuly")
                    self.isSendingActions = false
                }else{
                    self.isSendingActions = false
                }
                
            })
        }
        
        }
        
        
        
        
    }
    
    
    //MARK: -Banners
    private var banners : bannersList = bannersList()
    
    private func cachedBanners(){
        if let cachedFeed = UserDefaults.standard.value(forKey: AppGlobal.BannersCache) as? String {
            self.banners = bannersList(json: cachedFeed)
        }
    }
    
    public func getBanners()-> bannersList{
        self.cachedBanners()
        return self.banners
    }
    
    public func fetchBanners(sender: UIViewController, force: Bool = false, completionHandler: @escaping (Bool) -> ()){
        
        
        let request = RequestHandler(type: .bannersList , requestURL: AppGlobal.HomeBannersList, shouldShowError: force, timeOut: 5, retry: 2, sender: sender, waiting: force, force: force)
        request.sendRequest(completionHandler: {data, success, msg in
            if success {
                self.banners = data as! bannersList
                UserDefaults.standard.setValue(self.banners.toJsonString(), forKey: AppGlobal.BannersCache)
            }
            completionHandler(success)
        })
        
    }
    
    //MARK: -GenreList
    
    private var genreList : GenresList = GenresList()
    
    private func cachedGenreList(){
        if let cachedListString = UserDefaults.standard.value(forKey: AppGlobal.GenresListCache) as? String {
            self.genreList = GenresList(json: cachedListString)
    }
    }
    
    public func getGenreList()->GenresList{
        self.cachedGenreList()
        return self.genreList
    }
    
    public func fetchGenreList(sender: UIViewController, force: Bool = false, completionHandler: @escaping (Bool) -> ()){
        
        let request = RequestHandler(type: .genreList , requestURL: AppGlobal.GenresListURL, shouldShowError: force, retry: 1, sender: sender, waiting: force, force: force)
        request.sendRequest(completionHandler: {
            data, success, msg in
            if success{
            self.genreList = data as! GenresList
                completionHandler(true)
            }
        })
    }
    
    public func setFavoriteGenres(sender: UIViewController,params: [String], completionHandler: @escaping (Bool) -> ()){
        let request = RequestHandler(type: .setFavoriteGenres , requestURL: AppGlobal.SetFavoriteGenresURL, stringArray : params ,shouldShowError: true, timeOut: 8, retry: 0, sender: sender, waiting: true, force: false)
        
        request.sendRequest(completionHandler: { data , success, msg in
            completionHandler(success)
        })
    }
    
    //MARK: -GenreMore
    public func getGenreMoreKaras(genreURL: String) ->genre_more{
        var result = genre_more()
        if let cacheString = UserDefaults.standard.value(forKey: genreURL) as? String{
            let cache = genre_more(json: cacheString)
            result = cache
        }
        return result
    }
    
    
    //MARK: -Render Posts
  
    
    /*var isRendering = false
    public func addPostToQueue(post: unrenderedPost){
        var previousList = unrederedPostList()
        
        if let cachedListString = UserDefaults.standard.value(forKey: AppGlobal.UnrenderedPostsList) as? String {
            previousList = unrederedPostList(json: cachedListString)
        }
        previousList.posts.append(post)
        UserDefaults.standard.set(previousList.toJsonString(), forKey: AppGlobal.UnrenderedPostsList)
        
    }
    
    
    public func renderPosts(){
        
        if self.isRendering{
            return
        }
        
        var postsList = unrederedPostList()
        if let cachedListString = UserDefaults.standard.value(forKey: AppGlobal.UnrenderedPostsList) as? String {
            postsList = unrederedPostList(json: cachedListString)
        }
        
        if !postsList.posts.isEmpty{
            var finalized = false
            let post = postsList.posts.first!
            
            
            
            if checkUnrenderedPost(post: post){
            self.isRendering = true
            checkAndRenderPost(post: post , completionHandler: {
                url in
                self.isRendering = false
                if !finalized{
                    finalized = true
                    if url != nil {
        
                        let userPostObject = userPost()
                        userPostObject.kara = post.kara
                        userPostObject.file.link = (url!.lastPathComponent)
                        AppManager.sharedInstance().addUserPost(post: userPostObject)
                        postsList.posts.remove(at: 0)
                        UserDefaults.standard.set(postsList.toJsonString(), forKey: AppGlobal.UnrenderedPostsList)
                        self.presentNotification("Hi", notifBody: "Your song is ready! listen now!")
                        self.renderPosts()
    
                    }else{
                        postsList.posts.remove(at: 0)
                        UserDefaults.standard.set(postsList.toJsonString(), forKey: AppGlobal.UnrenderedPostsList)
                        self.renderPosts()
                    }
                }
            })
                
        }else{
            postsList.posts.remove(at: 0)
            UserDefaults.standard.set(postsList.toJsonString(), forKey: AppGlobal.UnrenderedPostsList)
            renderPosts()
        }
        }
        
        
    }
    
    func checkUnrenderedPost(post: unrenderedPost)->Bool{
        
        do{
            guard let karaURL = URL(string: post.playbackURL ) else { return false }
            guard let voiceURL = URL(string: post.voiceURL ) else { return false }
            _ = try AVAudioFile(forReading: karaURL)
            _ = try AVAudioFile(forReading: voiceURL)
            
        }catch{
            return false
        }
        
        if post.duration < 1 {
            return false
        }
        
        return true
    }
    
    
    
    func checkAndRenderPost(post: unrenderedPost , completionHandler: @escaping (URL?) -> ()){
        
        let playbackURL = URL(string: (post.playbackURL))
        let recordedURL = URL(string : (post.voiceURL))
        
            if (playbackURL != nil) && (recordedURL != nil) {
                if !(post.audioRendered){
                    self.renderAudio(effect: post.effect, playbackVol: post.playbackVolume, yourVolume: post.recordVolume , playbackURL: playbackURL!, duration: (post.duration), recordedURL: recordedURL!, completionHandler: {
                    url in
                    if url != nil{
                        post.audioRendered = true
                        post.finalAudio = url
                        if (post.videoRendered){
                            self.renderPost(post: post, completionHandler: {
                                finalURL in
                                if finalURL != nil {
                                    
                                    completionHandler(finalURL)
                                
                                }else{
                                    completionHandler(nil)
                                }
                            })
                        }
                    }else{
               completionHandler(nil)
                    }
                })
            }
            }else{
               completionHandler(nil)
            }
        
        if !(post.videoRendered){
            self.prepareVideo(post: post, completionHandler: {
                url in
                if url != nil{
                    post.silentVideo = url
                    post.videoRendered = true
                    if post.audioRendered{
                    self.renderPost(post: post, completionHandler: {
                        finalURL in
                        if finalURL != nil {
                            post.finalVideo = finalURL!
                            post.videoRendered = true
                        }else{
                            completionHandler(nil)
                        }
                    })
                }
                }else{
               completionHandler(nil)
                }
            })
        }
        
    }
    
    
    private func renderAudio(effect: soundFx, playbackVol : Float, yourVolume: Float , playbackURL : URL,duration : Double, recordedURL: URL, completionHandler: @escaping (URL?) -> ()){
        let audioMixer = MixManager(karaURL: playbackURL , recordedFileURL: recordedURL , sound: false)
        audioMixer.setMixer(effect: effect)
        audioMixer.setPlaybackVolume(volume: playbackVol)
        audioMixer.setYourVolume(volume: yourVolume)
        audioMixer.render(duration: duration, completionHandler: {
            url in
            if url != nil {
                try? FileManager.default.removeItem(at: playbackURL)
                try? FileManager.default.removeItem(at: recordedURL)
                completionHandler(url!)
            }else{completionHandler(nil)}
        })
    }
    
     */
    func prepareVideo(post: unrenderedPost, completionHandler: @escaping (URL?) -> ()){
        
        let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
//        let currentDateTime = NSDate()
//        let formatter = DateFormatter()
//        formatter.dateFormat = "ddMMyyyy-HHmmss"
//        let date = formatter.string(from: currentDateTime as Date)
        
        let karaAudioName = [dirPath, "Temp" + "SILENT.mp4"]
        let outputURL = NSURL.fileURL(withPathComponents: karaAudioName)
        
        if post.captured{
            guard let url = URL(string: post.videoURL) else{
                completionHandler(nil)
                return
            }
            MediaHelper.cropAndWatermark(capturingVideoPath: url, silentVideoPath: outputURL!, completionHandler: { success in
                if success{
                    completionHandler(outputURL!)
                }else{ //error
                    completionHandler(nil)
                }})
        }else{
            let previewImage = MediaHelper.userKaraPic(kara: post.kara)
            MediaHelper.writeSingleImageToMovie(image: previewImage , movieLength: post.duration, outputFileURL: outputURL!, completion: {_ in
                completionHandler(outputURL!)
            })
        }
    }
    
    
    /*
    private func renderPost(post: unrenderedPost, completionHandler: @escaping (URL?) -> ()){
        if !post.audioRendered || !post.videoRendered{
            return
        }
        let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let currentDateTime = NSDate()
        let formatter = DateFormatter()
        formatter.dateFormat = "ddMMyyyy-HHmmss"
        let date = formatter.string(from: currentDateTime as Date)
        
        let karaAudioName = [dirPath, date + "FINAL.mp4"]
        let outputURL = NSURL.fileURL(withPathComponents: karaAudioName)
        
        MediaHelper.mixAudioVideo(audio: post.finalAudio!, video: post.silentVideo!, output: outputURL!, completionHandler: {
            success in
            if success {
                completionHandler(outputURL!)
            }else{
                completionHandler(nil)
            }
        })
        
        
    }
 
    func presentNotification(_ notifAction: String, notifBody: String) {
        let application = UIApplication.shared
        
        let localNotification = UILocalNotification()
        localNotification.alertBody = notifBody
        localNotification.alertAction = notifAction
        localNotification.soundName = UILocalNotificationDefaultSoundName
        localNotification.applicationIconBadgeNumber += 1
        application.presentLocalNotificationNow(localNotification)
        
    }
 */
    
}










