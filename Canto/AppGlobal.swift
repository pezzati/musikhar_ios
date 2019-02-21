//
//  AppGlobal.swift
//  Canto
//
//  Created by WhoTan on 11/24/17.
//  Copyright © 2017 WhoTan. All rights reserved.
//

import UIKit

struct AppGlobal {
    public static let debugMode = false
//    public static let NassabVersion = false
//    public static let NassabCantoScheme = "http://nassaab.com/open/Canto"
    //URLs
//    public static let ServerURL = "http://77.238.122.16/"
//    public static let ServerURL = "http://192.168.1.114:8000/"
    //Nassab Bundle : nassab.application.canto
    //Sibapp Bundle : com.canto.application
	
    public static let ServerURL = debugMode ? "https://stg.canto-app.ir/" : "https://canto-app.ir/"
//	public static let ServerURL = "http://192.168.1.145:8000/"
    public static let UserSignupURL =  ServerURL + "user/signup"
    public static let UserLoginURL = ServerURL + "user/login"
    public static let UserProfileURL = ServerURL + "user/profile"
    public static let SubmitVerificationCode = ServerURL + "user/profile/verify/"
    public static let ResendVerificationCode = ServerURL + "user/profile/verify?context=&username="
    public static let HomeFeed = ServerURL + "v2/song/home"
    public static let UploadProfilePicture = ServerURL + "user/profile/upload_pic/"
    public static let HomeBannersList = ServerURL + "analysis/banners"
    public static let GenresListURL = ServerURL + "song/genre/"
    public static let SetFavoriteGenresURL = ServerURL + "song/genre/favorite/"
    public static let PopularKaraokesGenre = ServerURL + "song/posts/popular/"
    public static let NewKaraokesGenre = ServerURL + "song/posts/news/"
    public static let FreeKaraokesGenre = ServerURL + "song/posts/free/"
    public static let SearchKaraokes = ServerURL + "song/karaokes/search?key="
    public static let PackagesList = ServerURL + "finance/packages/"
    public static let PackageSerialNumber = ServerURL + "finance/purchase"
    public static let UserActionsLog = ServerURL + "analysis/actions/"
    public static let HandShake = ServerURL + "handshake"
    public static let GoogleSignIn = ServerURL + "user/google_signup"
    public static let BacktoryUpload = "http://storage.backtory.com/files"
    public static let NassabLogin = ServerURL + "user/gettoken/"
    public static let Feed = ServerURL + "song/feeds"
	public static let UserInventory = ServerURL + "user/users/inventory"
	public static let AvatarsList = ServerURL + "user/avatar"

	
	
	
	//colors
	public static let dialogueTextColor = UIColor(red: 178/255, green: 178/255, blue: 178/255, alpha: 1)
	public static let darkBackgroundColor = UIColor(red: 36/255, green: 37/255, blue: 41/255, alpha: 1)
	

//    public static let AllPoemsURL = ServerURL + "song/poems"
//    public static let AllSongsURL = ServerURL + "song/songs/"
//    public static let UserSongsURL = ServerURL + "user/users/my_songs"
//    public static let LikePost = ServerURL + "analysis/like/id/like/"
//    public static let PostSongFile = ServerURL + "media-management/upload/song"
    
    
    //Key Names
    public static let Token = "Token"
    public static let BannersCache = "Banners"
    public static let HomeFeedCache = "HomeFeed"
    public static let userInfoCache = "UserInfo"
    public static let FilesCache = "CachedFiles"
    public static let UserProfilePictureURL = "UserProfPic"
    public static let GenresListCache = "GenresList"
    public static let UserPostsList = "UserPostsList"
    public static let UnrenderedPostsList = "UnrederedPostsList"
    public static let ActionLogList = "ActionLogList"
	
	public static let PAYMENT_REQUIRED = "PAY"
	public static let SHOULD_BUY = "BUY"
    
    //Modes Info
    public static let modeNames = [Modes.dubsmash : "دابسمش" ,
                                   Modes.karaoke : "کارایوکی" ,
                                   Modes.singing : "خوانندگی"]
    public static let modesDescription = [Modes.dubsmash : "موزیک دلخواه خود را پیدا کنید، در حال لب زدن با آن ، ویدیو کلیپ های خلاقانه بسازید",
                                          Modes.karaoke : "موبایل خود را مانند میکروفون در دست بگیرید و خواننده مهمانی های خود باشید\n برای استفاده از این قابلیت لازم است از بلندگو استفاده کنید" ,
                                          Modes.singing : "بجای خواننده مورد علاقه خود روی آهنگ دلخواهتان بخوانید و موزیک ویدیو منحصر به خودتان را بسازید\nبرای عملکرد بهتر این قابلیت از هندزفری استفاده کنید"]


}


public enum ResultStatus {
    case ServerError
    case InternetConnection
    case Forbidden
    case Success
}

public enum RequestType {
    case login
    case signUp
    case genrePosts
    case genreList
    case userInfo
    case bannersList
    case setFavoriteGenres
    case packageList
    case purchaseLink
    case codeVerification
    case googleSignIn
    case updateUserInfo
    case actionLog
    case handShake
    case karaoke
    case nassabLogin
    case feedList
	case homeFeed
	case inventory
	case sing
	case avatarsList
}

public enum RequestState {
    case initializing
    case waitingForResponse
    case timedOut
}

public enum soundFx : String{
	case none = "none"
	case reverb = "reverb"
	case multiline = "flanger"
	case helium = "helium"
	case grunge = "autoWah"
}

public enum Modes : Int {
	case singing = 0
    case dubsmash = 1
    case karaoke = 2
}

public enum controller : String {
	case micVolume = "mic"
	case reverb = "reverb"
	case pitch = "pitch"
	case rate = "speed"
	case playback = "playback"
}


public enum loginMethod {
	case phone
	case email
}




