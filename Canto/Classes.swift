//
//  Classes.swift
//  NoheKhan
//
//  Created by WhoTan on 9/9/17.
//  Copyright © 2017 WhoTan. All rights reserved.
//

import UIKit
import EVReflection
import AVFoundation

class homeKaraokeFeed: EVObject, EVArrayConvertable{
   public var genres : [homeGenre] = []
    
    func convertArray(_ key: String, array: Any) -> NSArray {
        return [] as NSArray
    }
    
    override func setValue(_ value: Any!, forUndefinedKey key: String) {
            if let results = value as? NSArray {
                self.genres = []
                for item in results {
                    self.genres.append((item as? homeGenre)!)
                }
            }
    }
}

class homeGenre: EVObject, EVArrayConvertable{
    var name : String = ""
    var files_link : String = ""
    var link : String = ""
    var posts : [karaoke] = []
    
        override func setValue(_ value: Any!, forUndefinedKey key: String) {
                if let results = value as? NSArray {
                    self.posts = []
                    for post in results {
                        self.posts.append((post as? karaoke)!)
                }
            }
    }
    
        func convertArray(_ key: String, array: Any) -> NSArray {
            return [] as NSArray
        }
}

class karaoke: EVObject{
    var id : Int = 0
    var artist : Artist = Artist()
    var name : String = ""
//    var desc : String = ""
    var cover_photo : File = File()
//    var created_date : String = ""
//    var type : String = ""
	var price : Int = 0
	var count : Int = 0
   // var owner : Owner = Owner()
//    var liked_it : Bool = false
    var link : String = ""
    var content : karaoke_content = karaoke_content()
//    var like : Int = 0
//    var is_favorite : Bool = false
//    var is_premium : Bool = false
	
        override func setValue(_ value: Any!, forUndefinedKey key: String) {
            switch key{
//                case "owner":
//                if let Owner = value as? Owner{
//                    self.owner = Owner
//                }else{
//                    self.owner = Owner()
//                }
    
            case "cover_photo" :
                if let File = value as? File{
                    self.cover_photo = File
                }else{
                    self.cover_photo = File()
                }
            case "content" :
                if let content = value as? karaoke_content{
                    self.content = content
                }else{
                    self.content = karaoke_content()
                }
                
            case "description" :
                break
//                self.desc = (value as? String)!
            default : break
            }
        }
}

class karaoke_content : EVObject, EVArrayConvertable{
    var artist : Artist = Artist()
    var karaoke_file_url : String = ""
    var original_file_url : String = ""
//    var lyric : Lyrics = Lyrics()
    var link : String = ""
//    var length : String = ""
    var liveLyrics : [LyricLine] = []
    
    override func setValue(_ value: Any!, forUndefinedKey key: String) {
        
        if key == "midi" {

        
            if let lines = value as? NSArray{
                self.liveLyrics = []
                for line in lines{
//                    if let txt = line["text"] as? String{
//                        if let tm = line["time"] as? Float{
//
//                        }
//                    }
                    if let data = line as? NSDictionary{
                        var _line = LyricLine(dictionary:data)
                        
//                        _line.text = _line.text.replacingOccurrences(of: "\\", with: "\"" , options: .literal, range: nil)
//                        _line.text = _line.text
						_line.text = _line.text.replacingOccurrences(of: "\\n", with: "", options: .literal , range: nil)
						if _line.text.count > 0{
                        	self.liveLyrics.append(_line)
						}
                        
                    }
                }
            }
        
    }
    }
    
    func convertArray(_ key: String, array: Any) -> NSArray {
        return [] as NSArray
    }
    
}

class karaList: EVObject, EVArrayConvertable {
	
	var more : String = ""
	var data : [karaoke] = []
	var name : String = ""
	
	override func setValue(_ value: Any!, forUndefinedKey key: String) {
		
		if let results = value as? NSArray {
			self.data = []
			for post in results {
				self.data.append((post as? karaoke)!)
			}
		}
	}
	
	func convertArray(_ key: String, array: Any) -> NSArray {
		return [] as NSArray
	}
	
}





class genre_more : EVObject , EVArrayConvertable{
    var count : Int = 0
    var next : String = ""
    var previous : String = ""
    var results : [karaoke] = []
    var desc : String = ""
    
    override func setValue(_ value: Any!, forUndefinedKey key: String) {

            if let results = value as? NSArray {
                self.results = []
                for post in results {
                    self.results.append((post as? karaoke)!)
                }
            }
    }
    
    func convertArray(_ key: String, array: Any) -> NSArray {
        return [] as NSArray
    }
}

class LyricLine : EVObject{
    var text : String = ""
    var time : Float = 600.000
}

class Lyrics : EVObject {
    var poet = Artist()
    var text : String = ""
    var ling : String = ""
}

//class postSongClass : EVObject {
//    var name = ""
//    var desc = ""
//    var file = File()
//
//}
//

class userPost: EVObject{
    var kara : karaoke = karaoke()
    var file : File = File()
}

class userPostsList : EVObject, EVArrayConvertable{
    var posts : [userPost] = []
    
    override func setValue(_ value: Any!, forUndefinedKey key: String) {
        if let results = value as? NSArray {
            self.posts = []
            for post in results {
                self.posts.append((post as? userPost)!)
            }
        }
    }
    
    func convertArray(_ key: String, array: Any) -> NSArray {
        return [] as NSArray
    }
}

class package : EVObject{
    var name : String = ""
    var price : Int = 0
    var icon : String = ""
    var serial_number : String = ""
}

class packagesList : EVObject, EVArrayConvertable{
    var results : [package] = []
    var count : Int = 0
    var next : String = ""
    var previous : String = ""
    
    func convertArray(_ key: String, array: Any) -> NSArray {
        return [] as NSArray
    }
    override func setValue(_ value: Any!, forUndefinedKey key: String) {
        if let array = value as? NSArray {
            self.results = []
            for post in array {
                self.results.append((post as? package)!)
            }
        }
    }
    
}



class song: EVObject , EVArrayConvertable {
    var id : Int = 0
    var owner : Owner = Owner()
    var link : String = ""
    var name : String = ""
    var file : File = File()
    var like : Int = 0
    var poet : Artist = Artist()
    var genre : Genre = Genre()
//    var composer : Artist = Artist()
//    var singer : Artist = Artist()
//    var related_poem : Poem = Poem()
    var desc : String = ""
    var cover_photo : File = File()
    var created_date : String = ""
    var liked_it : Bool = false
    var is_favorite : Bool = false
    var length : String = ""
    var file_url : String = ""


    override func setValue(_ value: Any!, forUndefinedKey key: String) {
        switch key{
            case "owner":
            if let Owner = value as? Owner{
                self.owner = Owner
            }else{
                self.owner = Owner()
            }

        case "poet" :
            if let Poet = value as? Artist{
                self.poet = Poet
            }else{
                self.poet = Artist()
            }

        case "file" :
            if let File = value as? File{
                self.file = File
            }else{
                self.file = File()
            }
        case "cover_photo" :
            if let File = value as? File{
                self.cover_photo = File
            }else{
                self.cover_photo = File()
            }

        case "genre" :
            if let Genre = value as? Genre{
                self.genre = Genre
            }else{
                self.genre = Genre()
            }

//        case "composer" :
//            if let Composer = value as? Artist{
//                self.composer = Composer
//            }else{
//                self.composer = Artist()
//            }

//        case "singer" :
//            if let Singer = value as? Artist{
//                self.singer = Singer
//            }else{
//                self.singer = Artist()
//            }

//        case "related_poem" :
//            if let Poem = value as? Poem{
//                self.related_poem = Poem
//            }else{
//                self.related_poem = Poem()
//            }

        case "description" :
            self.desc = (value as? String)!
        default : break
        }
    }

    func convertArray(_ key: String, array: Any) -> NSArray {
        return [] as NSArray
    }
}
//
class Artist: EVObject{
    var id : Int = 0
    var name : String = ""
    var link : String = ""
    var poems_count : Int = 0
}

//class Poem: EVObject , EVArrayConvertable{
//    var name : String = ""
//    var poet : Artist?
//    var text : String = ""
//    var desc : String = ""
//    var cover_photo : File = File()
//    var link : String = ""
//    var id : Int = 0
//    var created_date : String = ""
//    var owner : Owner = Owner()
//    var liked_it : Bool = false
//
//    override func setValue(_ value: Any!, forUndefinedKey key: String) {
//        if key == "owner"{
//            if let Owner = value as? Owner{
//                self.owner = Owner
//            }else{
//                self.owner = Owner()
//            }
//        }else if key == "cover_photo"{
//            if let Cover = value as? File{
//                self.cover_photo = Cover
//            }else{
//                self.cover_photo = File()
//            }
//        }
//
//    }
//
//    func convertArray(_ key: String, array: Any) -> NSArray {
//        return [] as NSArray
//    }
//}
//

class ActionLog: EVObject{
    
    var timestamp : String = ""
    var action : String = ""
    var session : String = ""
    var detail : String = ""
}

class ActionLogList: EVObject, EVArrayConvertable{
    var list: [ActionLog] = []
    
    override func setValue(_ value: Any!, forUndefinedKey key: String) {
        if key == "list"{
              if let array = value as? NSArray {
                self.list = []
                for item in array {
                    self.list.append((item as? ActionLog)!)
                }
            }
        }
    }
    func convertArray(_ key: String, array: Any) -> NSArray {
        return [] as NSArray
    }
}

class Genre: EVObject {
    var link : String = ""
    var cover_photo : File = File()
    var files_link : String = ""
    var liked_it : Bool = false
    var name : String = ""
    var karas : genre_more = genre_more()
}



class GenresList : EVObject, EVArrayConvertable{
    var next : String = ""
    var previous : String = ""
    var results : [Genre] = []
    var count : Int = 0
    
    override func setValue(_ value: Any!, forUndefinedKey key: String) {
        if key == "results"{
            if (value as? NSArray) != nil {
                self.results = []
                for item in results {
                    self.results.append((item as? Genre)!)
                }
            }
        }
    }
    func convertArray(_ key: String, array: Any) -> NSArray {
        return [] as NSArray
    }
}

class Feed: EVObject {
//    var link : String = ""
    var cover_photo : File = File()
    var files_link : String = ""
    var liked_it : Bool = false
    var name : String = ""
    var karas : genre_more = genre_more()
    
    override func setValue(_ value: Any!, forUndefinedKey key: String) {
        if key == "link" {
            self.files_link = (value as? String)!
        }
    }
    

}

class FeedsList : EVObject, EVArrayConvertable{
    var next : String = ""
    var previous : String = ""
    var results : [Feed] = []
    var count : Int = 0
    
    override func setValue(_ value: Any!, forUndefinedKey key: String) {
        if key == "results"{
            if (value as? NSArray) != nil {
                self.results = []
                for item in results {
                    self.results.append((item as? Feed)!)
                }
            }
        }
    }
    func convertArray(_ key: String, array: Any) -> NSArray {
        return [] as NSArray
    }
}




class handShakeResult : EVObject{
    
    var force_update = false
    var is_token_valid = true
    var suggest_update = false
    var url : String = ""
    
}


class Owner: EVObject {
    var username : String = ""
    var gender : Int = 0
    var birth_date : String = ""
    var image : String = ""
    var mobile : String = ""
    var email : String = ""
    var bio : String = ""
    var first_name : String = ""
    var last_name : String = ""
    var follower_count : Int = 0
    var following_count : Int = 0
    var post_count : Int = 0
    var is_public : Bool = false
    var is_following : Bool = false
}

class bannersList : EVObject, EVArrayConvertable{
    
    var count : Int = 0
    var next : String = ""
    var previous : String = ""
    var results : [banner] = []
    
    override func setValue(_ value: Any!, forUndefinedKey key: String) {
        if key == "results"{
            if (value as? NSArray) != nil {
                    self.results = []
                    for banner in results {
                    self.results.append((banner as? banner)!)
                }
            }
        }
}
    func convertArray(_ key: String, array: Any) -> NSArray {
        return [] as NSArray
    }
}


class banner : EVObject{
    var title : String = ""
    var file : String = ""
    var link : String = ""
    var content_type : String = ""
    var desc : String = ""
    
    override func setValue(_ value: Any!, forUndefinedKey key: String) {
        if key == "description" {
            self.desc = value as! String
        }
    }
}

class UserInventory: EVObject, EVArrayConvertable{

	var posts : [InventoryPost] = []
	var coins : Int = 0
	var premium_days : Int = 0
	
	
	override func setValue(_ value: Any!, forUndefinedKey key: String) {

		if key == "posts"{
			if let results = value as? NSArray {
				self.posts = []
				for post in results {
					self.posts.append((post as? InventoryPost)!)
				}
			}
		}
	}
	
	func convertArray(_ key: String, array: Any) -> NSArray {
		return [] as NSArray
	}
}

class InventoryPost : EVObject{
	var count = 0
	var id = 0
}

class user: EVObject{
    var username : String = ""
    var gender : Int = 0
//    var birth_date : String = ""
    var image : String = ""
    var mobile : String = ""
    var email : String = ""
//    var bio : String = ""
    var first_name : String = ""
    var last_name : String = ""
//    var follower_count : Int = 0
//    var following_count : Int = 0
//    var post_count : Int = 0
//    var is_public : Bool = false
//    var poems : [Poem] = []
//    var songs : [song] = []
//    var is_following : Bool = false
//    var is_premium : Bool = false
    var premium_days : Int = 0
	var coins : Int = 0

//    override func setValue(_ value: Any!, forUndefinedKey key: String) {
//        switch key {
////        case "poems":
////            if let results = value as? NSArray {
////                self.poems = []
////                for poem in results {
////                    self.poems.append((poem as? Poem)!)
////                }
////            }
//
//        case "songs":
//            if let results = value as? NSArray {
//                self.songs = []
//                for song in results {
//                    self.songs.append((song as? song)!)
//                }
//            }
//        default: break
//        }
//    }

//    func convertArray(_ key: String, array: Any) -> NSArray {
//        return [] as NSArray
//    }

}

//class poemsGetAPI : EVObject , EVArrayConvertable{
//    var count : Int = 0
//    var next : String = ""
//    var previous : String = ""
//    var results : [Poem] = []
//
//    override func setValue(_ value: Any!, forUndefinedKey key: String) {
//        if key == "results"{
//         if let results = value as? NSArray {
//            self.results = []
//            for poem in results {
//                self.results.append((poem as? Poem)!)
//            }
//            }
//        }
//    }
//
//    func convertArray(_ key: String, array: Any) -> NSArray {
//        return [] as NSArray
//    }
//
//}
//
//
//class songsGetAPI : EVObject , EVArrayConvertable{
//    var count : Int = 0
//    var next : String = ""
//    var previous : String = ""
//    var results : [song] = []
//
//    override func setValue(_ value: Any!, forUndefinedKey key: String) {
//        if key == "results"{
//            if let results = value as? NSArray {
//                self.results = []
//                for song in results {
//                    self.results.append((song as? song)!)
//                }
//            }
//        }
//    }
//    func convertArray(_ key: String, array: Any) -> NSArray {
//        return [] as NSArray
//    }
//
//}

class File : EVObject{
    var id : Int = 0
    var link : String = ""
}

class DownloadedFiles : EVObject{
    var filesURL : [String] = []
}


class unrenderedPost : EVObject{
    var videoURL : String = ""
    var voiceURL : String = ""
    var playbackURL : String = ""
    var captured : Bool = false
    var effect : soundFx = .none
    var duration : Double = 1.0
    var playbackVolume : Float = 1.0
    var recordVolume : Float = 1.0
    var kara : karaoke = karaoke()
    var audioRendered = false
    var videoRendered = false
    var finalAudio : URL?
    var silentVideo : URL?
    var finalVideo : URL?
    
    override func setValue(_ value: Any!, forUndefinedKey key: String) {
    
        if key == "effect"{
        if let fx = value as? String{
            switch fx {
            case "none" :
                self.effect = .none
                break
            case "helium":
                self.effect = .helium
                break
            case "grunge":
                self.effect = .grunge
                break
            case "multiline":
                self.effect = .multiline
                break
            case "reverb":
                self.effect = .reverb
                break
            default:
                self.effect = .none
                break
            }
            }
   
        }
    }
    
}


class unrederedPostList : EVObject, EVArrayConvertable{
    var posts : [unrenderedPost] = []
    
    func convertArray(_ key: String, array: Any) -> NSArray {
        return [] as NSArray
    }
    override func setValue(_ value: Any!, forUndefinedKey key: String) {
        if let array = value as? NSArray {
            self.posts = []
            for post in array {
                self.posts.append((post as? unrenderedPost)!)
            }
        }
    }
    
}

class mySlider: UISlider{
    
    let coinEnd = UIImage(/*HERE_LEFT_BLANK_IMG*/).resizableImage(withCapInsets:
    UIEdgeInsetsMake(0,7,0,7), resizingMode: .stretch)
 
    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        var result = super.trackRect(forBounds: bounds)
        result.origin.x = 0
        result.size.width = bounds.size.width
        result.size.height = 11 //added height for desired effect
        return result
    }
    
    override func thumbRect(forBounds bounds: CGRect, trackRect rect: CGRect, value: Float) -> CGRect {
        return super.thumbRect(forBounds:
            bounds, trackRect: rect, value: value)
            .offsetBy(dx: 0/*Set_0_value_to_center_thumb*/, dy: 0)
    }
    
}

class mySlider2: UISlider{
    
    let coinEnd = UIImage(/*HERE_LEFT_BLANK_IMG*/).resizableImage(withCapInsets:
        UIEdgeInsetsMake(0,7,0,7), resizingMode: .stretch)
    
    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        var result = super.trackRect(forBounds: bounds)
        result.origin.x = 0
        result.size.width = bounds.size.width
        result.size.height = 4 //added height for desired effect
        return result
    }
    
    override func thumbRect(forBounds bounds: CGRect, trackRect rect: CGRect, value: Float) -> CGRect {
    
        
        return super.thumbRect(forBounds:
            bounds, trackRect: rect, value: value)
            .offsetBy(dx: 0/*Set_0_value_to_center_thumb*/, dy: 0)
    }
    
}




//
//class uploadResult : EVObject{
//    var upload_id : Int = 0
//}

//class playBackAudio {
//    let url:URL
//    var node = AVAudioPlayerNode()
//    var selected = false
//    var isPlaying = false
//    var engine = AVAudioEngine()
//    var pitch = AVAudioUnitTimePitch()
//    var paused = false
//    var attached = false
//    var capacity : AVAudioFrameCount = 0
//    var file = AVAudioFile()
//
//    init( fileURL: URL) {
//        self.url = fileURL
//    }
//
//    func select() {
//        self.selected = true
//    }
//
//    func deselect(){
//        self.selected = false
//    }
//
//    public func setup(engine: AVAudioEngine){
//
//        self.engine = engine
//        if self.attached{
//            engine.detach(node)
//        }
//        engine.attach(node)
//        engine.attach(pitch)
//
//        do{try file = AVAudioFile(forReading: self.url)} catch{print("failed to read file")}
//        let format = file.processingFormat
//        capacity = AVAudioFrameCount(file.length)
//        let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: capacity)
//        do{try file.read(into: buffer!)}catch{}
//
//        node.scheduleBuffer(buffer!, at: nil, options: [], completionHandler: nil)
//        node.volume = 0.7
//        engine.connect(node, to: pitch, format: engine.mainMixerNode.inputFormat(forBus: 0))
//        engine.connect(pitch, to: engine.mainMixerNode, format: engine.mainMixerNode.inputFormat(forBus: 0))
//        self.attached = true
//
//    }
//
//    public func play(){
//        node.play(at: AVAudioTime(hostTime: 0))
//        self.paused = false
//        self.isPlaying = true
//    }
//
//    public func stop(){
//        node.stop()
//        node = AVAudioPlayerNode()
//        pitch = AVAudioUnitTimePitch()
//        self.isPlaying = false
//    }
//
//    public func pause(){
//        node.pause()
//        self.paused = true
//        self.isPlaying = false
//    }
//
//    public func setRate(rate: Float){
//        self.pitch.rate = rate
//    }
//
//    public func setVolume(volume: Float){
//        self.node.volume = volume
//    }
//
//    public func setPitch(pitch: Float){
//        self.pitch.pitch = pitch
//    }
//
//    public func seektoTime(time : CMTime, duration: CMTime){
//
//        let sampleRate = node.outputFormat(forBus: 0).sampleRate
//        let newsampletime = AVAudioFramePosition(sampleRate * time.seconds)
//        let length = duration.seconds - time.seconds
//        let framestoplay = AVAudioFrameCount(sampleRate * length)
//        node.stop()
//        if framestoplay > 1000 {
//            node.scheduleSegment(file, startingFrame: newsampletime, frameCount: framestoplay, at: nil,completionHandler: nil)
//        }
//        node.play()
//    }
//}















