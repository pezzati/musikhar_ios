//
//  AudioHelper.swift
//  Canto
//
//  Created by Whotan on 10/12/18.
//  Copyright © 2018 WhoTan. All rights reserved.
//

import UIKit

class AudioHelper: NSObject {

    
    
    
    func getAudioFile(post: karaoke, original: Bool) {
     
        let urlString = original ? post.content.original_file_url : post.content.karaoke_file_url
        let url = URL(string: urlString)
        let fileName = original ? post.id.description + "K.mp3" : post.id.description + "O.mp3"
        var documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        documentsURL.appendPathComponent("karaokes")
        try! FileManager.default.createDirectory(atPath: documentsURL.path, withIntermediateDirectories: true, attributes: nil)
        documentsURL.appendPathComponent(fileName!)
        var filePath = documentsURL
        
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            return (documentsURL, [.removePreviousFile])
        }
        
        if let downloadedListString = UserDefaults.standard.value(forKey: AppGlobal.FilesCache) as? String {
            let downloadedList = DownloadedFiles(json: downloadedListString)
            
            var index = 0
            for file in downloadedList.filesURL{
                if file == urlString! && FileManager.default.fileExists(atPath: (filePath?.path)!){
                    
                        if !success {
                            //Downloaded file was not readable
                            downloadedList.filesURL.remove(at: index)
                            UserDefaults.standard.set(downloadedList.toJsonString() , forKey: AppGlobal.FilesCache)
                            try? FileManager.default.removeItem(at: self.filePath!)
                            //should download the file
                        }
                        else{
                            DispatchQueue.main.async {
                                //file was already downloaded
                            }
                        }
                }
            }
        }else{
            let template = DownloadedFiles()
            UserDefaults.standard.set(template.toJsonString() , forKey: AppGlobal.FilesCache)
        }
        
        
    }
    
    
    
    
    
    
    
    func downloadKaraoke(){
        //if all retries were failed, show dialogue
//
//        let tempPost = self.post
//
//        var urlString : String? = nil
//
//        if self.original { urlString = self.post.content.original_file_url }
//        else{
//            urlString =  self.post.content.karaoke_file_url
//        }
//        let url = URL(string: urlString!)
//
//        var fileName : String? = nil
//        var scrWidth = Float(0)
//        DispatchQueue.main.async {
//            scrWidth = Float(self.view.frame.width)
//        }
//        if !self.original{
//            fileName = self.post.id.description + "K.mp3"
//        }else{
//            fileName = self.post.id.description + "O.mp3"
//        }
//
//
//
//        var documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
//        documentsURL.appendPathComponent("karaokes")
//        try! FileManager.default.createDirectory(atPath: documentsURL.path, withIntermediateDirectories: true, attributes: nil)
//        documentsURL.appendPathComponent(fileName!)
//        filePath = documentsURL
//
//        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
//            return (documentsURL, [.removePreviousFile])
//        }
        
//        if let downloadedListString = UserDefaults.standard.value(forKey: AppGlobal.FilesCache) as? String {
//
//            let downloadedList = DownloadedFiles(json: downloadedListString)
//
//            var index = 0
//            for file in downloadedList.filesURL{
//
//                if file == urlString! && FileManager.default.fileExists(atPath: (filePath?.path)!){
//
//                    self.recordManager.read(fileUrl: filePath!, completionHandler: {success in
//                        if !success {
//                            print("HEEEELP")
//                            self.songDuration = AVAsset(url: self.filePath!).duration.seconds
//                            downloadedList.filesURL.remove(at: index)
//                            try? FileManager.default.removeItem(at: self.filePath!)
//                            self.downloadKaraoke()
//                        }
//                        else{
//                            DispatchQueue.main.async {
//
//                                self.songDuration = AVAsset(url: self.filePath!).duration.seconds
//                                self.timeBarWidthConstraint.constant = self.view.frame.width
//                                self.shouldDownload = false
//                                self.effectImageView.alpha = 1
//                                self.eventLabel.text = "آماده شروع"
//                                print("File was already downloaded")
//                                self.recordButton.alpha = 1
//                                self.recordImageView.alpha = 1
//                                self.isReady = true
//                                self.bottomBarView.isHidden = false
//                                self.bottomBarView.shake()
//                                self.recordImageView.shake()
//                            }
//                        }
//                    })
//                }
//                index += 1
//            }
//        }else{
//            let template = DownloadedFiles()
//            UserDefaults.standard.set(template.toJsonString() , forKey: AppGlobal.FilesCache)
//        }
//
        if !self.shouldDownload { return }
        
        self.retry = self.retry - 1
        DispatchQueue.main.async {
            
            self.eventLabel.text = "در حال دریافت فایل"
            self.downloadRequest = Alamofire.download(url!, to: destination).downloadProgress(closure: { (progress) in
                DispatchQueue.main.async {
                    if !self.shouldDownload {self.downloadRequest?.cancel() }
                    let width = Float(Float(progress.completedUnitCount) / Float(progress.totalUnitCount)) * scrWidth
                    self.timeBarWidthConstraint.constant = CGFloat(width)
                    self.eventLabel.text = "در حال دریافت فایل" + " " + Int(Float(progress.completedUnitCount) / Float(progress.totalUnitCount)*100).description.persianDigits + "%"
                    self.downloadedBytes = Int(progress.completedUnitCount)
                }}).responseData { response in
                    if self.recordManager == nil {
                        return
                    }
                    if (response.error != nil){
                        print(response.error!)
                    } else if response.result.isSuccess && FileManager.default.fileExists(atPath: (self.filePath?.path)!)  {
                        //                    self.songDuration = AVAsset(url: filePath!).duration.seconds
                        self.recordManager.read(fileUrl: self.filePath!, completionHandler: {success in
                            if !success { print("HEEEELP")
                                if (tempPost == self.post) && (self.shouldDownload) && (self.retry > 0){
                                    try? FileManager.default.removeItem(at: self.filePath!)
                                    
                                    self.downloadKaraoke()
                                }
                            }
                            else {
                                self.effectImageView.alpha = 1
                                self.songDuration = AVAsset(url: self.filePath!).duration.seconds
                                self.timeBarWidthConstraint.constant = self.view.frame.width
                                let cacheString = UserDefaults.standard.value(forKey: AppGlobal.FilesCache) as? String
                                let downloadList = DownloadedFiles(json: cacheString)
                                downloadList.filesURL.append(urlString!)
                                UserDefaults.standard.set(downloadList.toJsonString(), forKey: AppGlobal.FilesCache)
                                self.eventLabel.text = "آماده شروع"
                                self.recordButton.alpha = 1
                                self.recordImageView.alpha = 1
                                print("download completed")
                                self.isReady = true
                                self.bottomBarView.isHidden = false
                                self.bottomBarView.shake()
                                self.recordImageView.shake()
                            }
                            
                        })
                        
                    }else{
                        print("couldn't download")
                        if (tempPost == self.post) && (self.shouldDownload) && (self.retry > 0){
                            self.downloadKaraoke()
                        }
                    }
            }
        }
    }
    
}
