//
//  Record_VC.swift
//  Canto
//
//  Created by WhoTan on 11/17/17.
//  Copyright © 2017 WhoTan. All rights reserved.
//

import UIKit
import AVFoundation
import Alamofire


class Record_VC: UIViewController,  AVCaptureFileOutputRecordingDelegate, UITableViewDelegate, UITableViewDataSource {

        //Outlets
    
    @IBOutlet weak var lyricTableView: UITableView!
    @IBOutlet weak var bottomBarDarkBackground: UIView!
    @IBOutlet weak var pitchStepper: UIStepper!
    @IBOutlet weak var volStepper: UIStepper!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var bottomBarView: UIView!
    @IBOutlet weak var previewImage: UIImageView!
    @IBOutlet weak var camButtonImage: UIImageView!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var innerDarkLayer: UIView!
    @IBOutlet weak var timeBarWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var PreviewView: UIView!
    @IBOutlet weak var LyricsTextView: UITextView!
//    @IBOutlet weak var blurryView: UIImageView!
    @IBOutlet weak var loadingBarView: UIView!
    @IBOutlet weak var backButton: UIButton!
    
    @IBOutlet weak var tempoStepper: UIStepper!
    @IBOutlet weak var volumeLabel: UILabel!
    @IBOutlet weak var tempoLabel: UILabel!
    @IBOutlet weak var pitchLabel: UILabel!
    @IBOutlet weak var prepareButtonsVerticalConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var eventLabel: UILabel!
    @IBOutlet weak var ReverbEffectLabel: UILabel!
    
    @IBOutlet weak var echoEffectLabel: UILabel!
    @IBOutlet weak var GrungeEffectLabel: UILabel!
    
    @IBOutlet weak var HeliumEffectLabel: UILabel!
    @IBOutlet weak var noEffectLabel: UILabel!
    
    @IBOutlet weak var recordImageView: UIImageView!
    
    @IBOutlet weak var bottomBarShadowView: UIView!
    @IBOutlet weak var prviewViewBottomConstraint: NSLayoutConstraint!
    
    
    @IBOutlet weak var equalizerButton: UIButton!
    
    @IBOutlet weak var camSwitcherButton: UIButton!
    @IBOutlet weak var previewViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var grungeEffectImageButton: UIImageView!
    
    @IBOutlet weak var playbackVolumeSlider: UISlider!
    @IBOutlet weak var yourVolumeSlider: UISlider!
    @IBOutlet weak var playbackVolumeLabel: UILabel!
    @IBOutlet weak var yourVolumeLabel: UILabel!
    @IBOutlet weak var playButton: UIImageView!
    @IBOutlet weak var playSlider: UISlider!
    
    
    @IBOutlet weak var previewViewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var heliumEffectImageButton: UIImageView!
    @IBOutlet weak var loadingShadowContainerView: UIView!
    @IBOutlet weak var recordButtonVerticalConstraint: NSLayoutConstraint!

    //Video capturing objects
    var captureSession: AVCaptureSession?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var currentCaptureDevice : AVCaptureDevice?
    var frontCaptureDevice : AVCaptureDevice?
    var backCaptureDevice : AVCaptureDevice?
    var movieOutput = AVCaptureMovieFileOutput()
    var videoPlayer : AVPlayer!
    var playerItem : AVPlayerItem!
    var playerLayer : AVPlayerLayer!
    
    @IBOutlet weak var noEffectImageButton: UIImageView!
    
    @IBOutlet weak var reverbEffectImageButton: UIImageView!
    @IBOutlet weak var multiLineEffectImageButton: UIImageView!
    @IBOutlet weak var effectsVerticalConstraint: NSLayoutConstraint!
    
    //logics
    var camera_On = !AppGlobal.debugMode
    var isRecording = false
    var micPlugged = false
    
    var post : karaoke = karaoke()
    var original = false
    var isReady = false
    var songDuration = Double(100)
    var elapsedTime = Double(0)
    var shouldDownload = true
    var retry = 2
    var downloadRequest : Alamofire.Request?
    var isEditingConfig = false
    var recordManager : RecordManager!
//    var mixManager : MixManager!
    var audioMixer : AudioMixer!
    var recordingDone = false
    var isPlaying = false
    var isMovingSlider = false
    var effect : soundFx = .none
    var timer : Timer? = nil
    
    
    //URLS
    var capturingVideoPath : URL!
    var karaAudioPath: URL!
    var recordedVoicePath: URL!
    
    //effects
    @IBOutlet weak var effectsView: UIView!
    @IBOutlet weak var darkView: UIView!
    
    @IBOutlet weak var effectImageView: UIImageView!
    var renderObjc = unrenderedPost()
    var downloadedBytes = 0
    var elapsedDownloadTime = 0.0

    override func viewDidLoad() {
        
        self.createURL()
        self.cleanFolder()
        AppManager.sharedInstance().addAction(action: "View Did Appear", session: "Record" + post.id.description, detail: "")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 3
        style.alignment = .center
        self.LyricsTextView.setContentOffset(CGPoint.zero, animated: false)
//        let attributes = [NSAttributedStringKey.paragraphStyle : style]
//        self.LyricsTextView.attributedText = NSAttributedString(string: self.post.content.lyric.text, attributes: attributes)
//        self.LyricsTextView.attributedText = NSAttributedString(string: self.post.content.liveLyrics[0].text, attributes: attributes )
        self.LyricsTextView.setContentOffset(CGPoint.zero, animated: false)
        self.LyricsTextView.font = UIFont.boldSystemFont(ofSize: 15)
        self.eventLabel.text = "در حال بررسی..."
//        self.PreviewView.layer.cornerRadius = 10
        
        let hasLyrics = post.content.liveLyrics.count > 0
        LyricsTextView.isHidden = hasLyrics
        lyricTableView.isHidden = !hasLyrics
        lyricTableView.allowsSelection = !self.original

        if self.original{
            var i = 0
            for n in 0...self.post.content.liveLyrics.count - 1 {
                if self.post.content.liveLyrics.count > i+1 && self.post.content.liveLyrics[i].text.count < 2 {
                    self.post.content.liveLyrics.remove(at: i)
                }else{
                    i += 1
                }
            }
        }
        
        AppGlobal.debugMode ? turnOffCamera() : turnOnCamera()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        UIApplication.shared.isIdleTimerDisabled = true
        super.viewDidAppear(true)
        
        if self.timer == nil{
            self.timer = Timer.scheduledTimer(timeInterval: 0.001, target: self, selector: #selector(self.updateTimerLine), userInfo: nil, repeats: true)
        }
        
        self.LyricsTextView.setContentOffset(CGPoint.zero, animated: false)
        self.LyricsTextView.isHidden = false
        self.createURL()
        self.cleanFolder()
        
        self.previewImage.image = MediaHelper.userKaraPic(kara: self.post)
        self.LyricsTextView.setContentOffset(CGPoint.init(x: 0, y: 0) , animated: true)
        
//        self.camera_On = false
        setAudioEngine()
        
        
        let currentRoute = AVAudioSession.sharedInstance().currentRoute
        if currentRoute.outputs.count != 0 {
            for item in currentRoute.outputs{
                if item.portType == AVAudioSessionPortHeadphones{
                    micPlugged = true
                }else if item.portType == AVAudioSessionPortHeadsetMic{
                    micPlugged = true
                }
            }
        }
        
        if !micPlugged{
            let dialog = DialougeView()
            dialog.plugHeadphones(sender: self)
        }
        DispatchQueue.main.async {
          self.downloadKaraoke()
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        AppManager.sharedInstance().addAction(action: "Memory Warning", session: "Record\(post.id)", detail: "")
    }
    
    override func viewWillLayoutSubviews() {
        videoPreviewLayer?.frame = PreviewView.bounds
        videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        PreviewView.layer.shadowColor = UIColor.black.cgColor
        PreviewView.layer.shadowOffset = CGSize(width: 0, height: 2)
        PreviewView.layer.shadowRadius = 5
        PreviewView.layer.shadowOpacity = 0.7
        loadingShadowContainerView.layer.shadowColor = UIColor.lightGray.cgColor
        loadingShadowContainerView.layer.shadowOpacity = 0.5
        loadingShadowContainerView.layer.shadowRadius = 2
        loadingShadowContainerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        

        bottomBarShadowView.layer.shadowColor = UIColor.black.cgColor
        bottomBarShadowView.layer.shadowOpacity = 0.7
        bottomBarShadowView.layer.shadowRadius = 3
        bottomBarShadowView.layer.shadowOffset = CGSize(width: 0, height: -2)
        bottomBarDarkBackground.layer.cornerRadius = bottomBarDarkBackground.frame.height/2
        doneButton.layer.cornerRadius = 10
        
    }
    
    //MARK: -Downloading file / reading from memory
    
    var filePath : URL? = nil
    
    
    func downloadKaraoke(){
        //if all retries were failed, show dialogue
        
        let tempPost = self.post
        
        var urlString : String? = nil
        
        if self.original { urlString = self.post.content.original_file_url }
        else{
        urlString =  self.post.content.karaoke_file_url
        }
        let url = URL(string: urlString!)
        
        var fileName : String? = nil
        let scrWidth = Float(self.view.frame.width)
        if !self.original{
            fileName = self.post.id.description + "K.mp3"
        }else{
            fileName = self.post.id.description + "O.mp3"
        }
        
        
        
        var documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        documentsURL.appendPathComponent("karaokes")
        try! FileManager.default.createDirectory(atPath: documentsURL.path, withIntermediateDirectories: true, attributes: nil)
        documentsURL.appendPathComponent(fileName!)
        filePath = documentsURL
        
        
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            return (documentsURL, [.removePreviousFile])
        }
        
        if let downloadedListString = UserDefaults.standard.value(forKey: AppGlobal.FilesCache) as? String {
            
            let downloadedList = DownloadedFiles(json: downloadedListString)
            
            var index = 0
            for file in downloadedList.filesURL{
                
                if file == urlString! && FileManager.default.fileExists(atPath: (filePath?.path)!){
                    
                    self.recordManager.read(fileUrl: filePath!, completionHandler: {success in
                        if !success {
                            print("HEEEELP")
                            self.songDuration = AVAsset(url: self.filePath!).duration.seconds
                            downloadedList.filesURL.remove(at: index)
                            try? FileManager.default.removeItem(at: self.filePath!)
                            self.downloadKaraoke()
                        }
                        else{
                            self.songDuration = AVAsset(url: self.filePath!).duration.seconds
                            self.timeBarWidthConstraint.constant = self.view.frame.width
                            self.shouldDownload = false
                            self.effectImageView.alpha = 1
                            self.eventLabel.text = "آماده شروع"
                            print("File was already downloaded")
                            self.recordButton.alpha = 1
                            self.recordImageView.alpha = 1
                            self.isReady = true
                            self.recordImageView.shake()
                            
                        }
                    })
                }
                index += 1
            }
        }else{
            let template = DownloadedFiles()
            UserDefaults.standard.set(template.toJsonString() , forKey: AppGlobal.FilesCache)
        }
        
        if !self.shouldDownload { return }
        
        self.retry = self.retry - 1
        
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
    
    //MARK: -config sliders
    
    
    @IBAction func pitchStepper(_ sender: UIStepper) {
        if self.isEditingConfig{
            self.recordManager.set(pitch: Float(sender.value * 100 ))
            self.pitchLabel.text = sender.value.description
        }
        AppManager.sharedInstance().addAction(action: "Set Pitch", session: "Record" + post.id.description, detail: sender.value.description)
    }
    
    @IBAction func tempoStepper(_ sender: UIStepper) {
        if self.isEditingConfig{
            self.recordManager.set(rate: Float(sender.value / 100 ))
            self.tempoLabel.text = sender.value.description + "%"
        }
        AppManager.sharedInstance().addAction(action: "Set Tempo", session: "Record" + post.id.description, detail: sender.value.description)
    }
    
    @IBAction func volumeStepper(_ sender: UIStepper) {
        if self.isEditingConfig{
            self.recordManager.set(volume: Float(sender.value / 100) )
            self.volumeLabel.text = sender.value.description + "%"
        }
        AppManager.sharedInstance().addAction(action: "Set Volume", session: "Record" + post.id.description, detail: sender.value.description)
    }
    
    
    //MARK: -Setting Audio Engine
    func setAudioEngine(){
        self.recordManager = RecordManager(karaOutputURL: self.karaAudioPath, recordOutputURL: self.recordedVoicePath, duration: self.songDuration)
        self.recordManager.setNotification()
        self.recordManager.setMonitor()
    }
    
    //MARK: -Lyrics TableView
    
    var currentLine = 0
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 0))
        let text = post.content.liveLyrics[indexPath.row].text.replacingOccurrences(of: "\\n", with: "", options: .literal , range: nil)
//        text = text.replacingOccurrences(of: "\\"", with: "", options: .literal, range: nil)
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.text = text
        cell.textLabel?.textAlignment = .center
        cell.textLabel?.font = UIFont.systemFont(ofSize: 16)

        if indexPath.row > currentLine - 1 && !self.original {
            cell.textLabel?.textColor = UIColor.gray
        }else{
            cell.textLabel?.textColor = UIColor.black
        }
        cell.selectedBackgroundView?.backgroundColor = UIColor.white
        cell.contentView.backgroundColor = UIColor.white
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return post.content.liveLyrics.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        lyricTableView.deselectRow(at: indexPath, animated: false)
        if !self.original && self.isRecording {
            if self.post.content.liveLyrics[indexPath.row].time > 1{
                self.recordManager.seekTo(time : Double(self.post.content.liveLyrics[indexPath.row].time - 0.4) )
                if (indexPath.row != 0) {
                    self.currentLine = indexPath.row - 1
                }else{
                    self.currentLine = 0
                }
                lyricTableView.reloadData()
            }
        }
    }
    
    
    
    
    //MARK: -Setting Camera
    let rotator = UIImageView(image: UIImage(named: "camera_switcher"))
    
    func turnOnCamera(){
        self.setCaptureDevices()
//        camRotatorImgView.image = UIImage(named : "switch-camera")
        camButtonImage.image = UIImage(named: "video")
        videoPreviewLayer?.removeFromSuperlayer()
        var input : AVCaptureDeviceInput? = nil
        
        if currentCaptureDevice == nil{
            self.turnOffCamera()
            self.camera_On = false
            return
        }
        do {
            input = try AVCaptureDeviceInput(device: currentCaptureDevice!)
        }catch {
            print(error)
            self.turnOffCamera()
            self.camera_On = false
            return
            
        }
        
        captureSession = AVCaptureSession()
        captureSession?.addInput(input!)
        
        movieOutput = AVCaptureMovieFileOutput()
        movieOutput.movieFragmentInterval = kCMTimeInvalid
        captureSession?.addOutput(movieOutput)
        
        captureSession?.sessionPreset = .high
        
        
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
        videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        videoPreviewLayer?.masksToBounds = true
        videoPreviewLayer?.frame = PreviewView.bounds
        PreviewView.layer.addSublayer(videoPreviewLayer!)
        
        captureSession?.commitConfiguration()
        captureSession?.startRunning()
        self.previewImage.alpha = 0.0
        
//        let rotator = UIImageView(image: UIImage(named: "camera_switcher"))
        rotator.frame = CGRect(x: 10, y: 10, width: 40, height: 40)
        PreviewView.addSubview(rotator)
        PreviewView.layoutSubviews()
        
        let rotateTap = UITapGestureRecognizer { (gesture:UIGestureRecognizer?) in
         
            self.RotateCamera(self)
        }
        rotator.addGestureRecognizer(rotateTap!)
        rotator.isUserInteractionEnabled = true
        
        
        
//        self.camRotatorImgView.alpha = 1
    }
    
    func turnOffCamera(){
//        camRotatorImgView.image = UIImage(named : "switch-camera-off")
        camButtonImage.image = UIImage(named: "video-off")
//        micImageView.image = UIImage(named: "microphone")
        videoPreviewLayer?.removeFromSuperlayer()
        captureSession?.stopRunning()
        self.previewImage.alpha = 1
        
        rotator.removeFromSuperview()
//        self.camRotatorImgView.alpha = 0.5
    }
    //MARK: -UIButton Actions
    @IBAction func close(_ sender: Any) {
        
        AppManager.sharedInstance().addAction(action: "Close Tapped", session: "Record" + post.id.description, detail: "")
        if self.isRecording || self.recordingDone {
        let ask = DialougeView()
            
        ask.shouldRemove(vc: self, completionHandler: {
         remove in
            if remove {
                ask.hide()
                
                if self.isRecording{  self.recordManager.stopRecording() }
                if self.audioMixer != nil {
                    self.pause()
                    self.audioMixer = nil
                }
//                try? FileManager.default.removeItem(at: self.recordedVoicePath!)
//                try? FileManager.default.removeItem(at: self.karaAudioPath!)
//                try? FileManager.default.removeItem(at: self.capturingVideoPath!)
                
                self.dismiss(animated: true, completion: nil)
            }else{
                ask.hide()
            }
        })
        }else{
//            try? FileManager.default.removeItem(at: self.recordedVoicePath!)
//            try? FileManager.default.removeItem(at: self.karaAudioPath!)
//            try? FileManager.default.removeItem(at: self.capturingVideoPath!)

        self.dismiss(animated: true, completion: nil)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        if self.recordManager != nil {
            self.recordManager.stopRecording()
            self.recordManager.removeNotification()
            self.recordManager = nil
            
        }

        
        if self.camera_On{
            if recordingDone{
                if self.videoPlayer != nil{
                    self.videoPlayer.pause()
                }
                if playerLayer != nil{
                    playerLayer.removeFromSuperlayer()
                }
                self.playerItem = nil
                self.videoPlayer = nil
                self.playerLayer = nil
            }else{
                self.turnOffCamera()
            }
            self.backCaptureDevice = nil
            self.frontCaptureDevice = nil
            self.currentCaptureDevice = nil
        }
        
        self.shouldDownload = false
        if self.recordManager != nil {
            self.recordManager.removeNotification()
        }
        
        self.recordManager = nil
        self.isPlaying = false
        
        if self.timer != nil{
            timer?.invalidate()
            timer = nil
        }
        
        
    }
    
    
//    @IBAction func soundMonitorToggle(_ sender: Any) {
//        if micImageView.image == UIImage(named: "microphone"){
//            micImageView.image = UIImage(named: "microphone-off")
//            self.recordManager.setMonitor(on: false)
//            AppManager.sharedInstance().addAction(action: "Sound Monitor Set Off", session: "Record" + post.id.description, detail: "")
//        }else{
//            micImageView.image = UIImage(named: "microphone")
//            self.recordManager.setMonitor(on: true)
//            AppManager.sharedInstance().addAction(action: "Sound Monitor Set On", session: "Record" + post.id.description, detail: "")
//        }
//
//    }
    
    @IBAction func effectsTapped(_ sender: Any) {
       
        AppManager.sharedInstance().addAction(action: "Pre-Record Setting Tapped", session: "Record" + post.id.description, detail: "")
        
        self.effectsView.layer.shadowColor = UIColor.gray.cgColor
        self.effectsView.layer.shadowRadius = 10
        self.effectsView.layer.shadowOpacity = 0.5
        self.effectsView.layer.cornerRadius = 40
        
        if !isEditingConfig && !self.isRecording && self.isReady  {
            
            self.recordManager.pause()
            self.darkView.isHidden = false
            let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.light )
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            blurEffectView.frame = view.bounds
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            blurEffectView.alpha = 0.5
            view.addSubview(blurEffectView)
            
            view.bringSubview(toFront: darkView)
            
            
            let cancelTap =  UITapGestureRecognizer { (gesture:UIGestureRecognizer?) in
                self.darkView.isHidden = true
                blurEffectView.removeFromSuperview()
                self.isEditingConfig = false
                self.recordManager.pause()
            }
            self.innerDarkLayer.addGestureRecognizer(cancelTap!)
            self.innerDarkLayer.isUserInteractionEnabled = true
            
            self.isEditingConfig = true
           

            self.recordManager.play()
        
        }
    }
    
    @IBAction func CameraSwitcher(_ sender: Any) {
        if self.isRecording{return}else{
        if camera_On {
            turnOffCamera()
//            camButtonImage.image = UIImage(named: "no_camera")
            AppManager.sharedInstance().addAction(action: "Camera Turned Off", session: "Record" + post.id.description, detail: "")
            camera_On = false
        } else {
            turnOnCamera()
            AppManager.sharedInstance().addAction(action: "Camera Turned On", session: "Record" + post.id.description, detail: "")
//            camButtonImage.image = UIImage(named: "camera_on")
            camera_On = true
        }
        }
    }
    
    @IBAction func RotateCamera(_ sender: Any) {
        if self.isRecording  {
            return
            
        }else if !self.camera_On{
            self.turnOnCamera()
            self.camera_On = true
        }
            
        else{
        if currentCaptureDevice?.position == AVCaptureDevice.Position.front{
            self.currentCaptureDevice = self.backCaptureDevice
            AppManager.sharedInstance().addAction(action: "Rotate Camera", session: "Record" + post.id.description, detail: "Back")
        }else{
            self.currentCaptureDevice = self.frontCaptureDevice
            AppManager.sharedInstance().addAction(action: "Rotate Camera", session: "Record" + post.id.description, detail: "Front")
        }
        turnOnCamera()
        }
    }
    
    
    
    @IBAction func StartRecording(_ sender: Any) {
        if self.isReady{
        if !isRecording && !self.recordingDone{
            if self.camera_On{
                if (movieOutput.connection(with: AVMediaType.video)?.isActive)!{
                    movieOutput.startRecording(to: self.capturingVideoPath!, recordingDelegate: self)
                    rotator.removeFromSuperview()
                }
            }
    
//            self.prepareButtonsVerticalConstraint.constant = 150
            
       
            UIView.animate(withDuration: 1.5, animations: {() -> Void in
//                self.camRotatorImgView.alpha = 0
//                self.micImageView.alpha = 0
                self.effectImageView.alpha = 0
                self.camButtonImage.alpha = 0
                self.camSwitcherButton.alpha = 0
                self.bottomBarDarkBackground.alpha = 0
//                self.camRotaterButton.alpha = 0
                self.equalizerButton.alpha = 0
//                self.soundMonitorButton.alpha = 0
                self.view.layoutIfNeeded()
            })
            
            
            DispatchQueue.main.async {
                
                
            if self.timer == nil{
                    self.timer = Timer.scheduledTimer(timeInterval: 0.001, target: self, selector: #selector(self.updateTimerLine), userInfo: nil, repeats: true)
                }
            }
            
            self.isRecording = true
            startAudioRecording()
            
        
            
            self.recordImageView.image = UIImage(named: "stop")
//            self.recordButton.setImage(UIImage(named: "stop"), for: .normal)
            self.timeBarWidthConstraint.constant = 0
            self.eventLabel.text = "در حال ضبط"
            AppManager.sharedInstance().addAction(action: "Recording Started", session: "Record" + post.id.description, detail: "")
        }else{
            
            self.songDuration = self.recordManager.currentTime()/Double(self.tempoStepper.value/100)
            self.songDuration = AVAsset(url: self.karaAudioPath!).duration.seconds
            self.elapsedTime = 0.0
            stopAudioRecording()
            AppManager.sharedInstance().addAction(action: "Recording Stopped", session: "Record" + post.id.description, detail: self.songDuration.description)
            self.view.isUserInteractionEnabled = false
            
            self.isRecording = false
            self.recordingDone = true
            if self.camera_On{
                movieOutput.stopRecording()
                captureSession?.stopRunning()
            }
         
//            let waiting = DialougeView()
//            waiting.waitingBox(vc: self)
            
            self.renderObjc.kara = self.post
            self.renderObjc.videoURL = self.capturingVideoPath.absoluteString
            self.renderObjc.captured = self.camera_On
            self.renderObjc.duration = self.songDuration
            
            self.prepareToReview()
            
            AppManager.sharedInstance().prepareVideo(post:  self.renderObjc, completionHandler: {
                url in
                if url != nil{
                print("Video is ready")
                DispatchQueue.main.async(execute: {
                    self.renderObjc.silentVideo = url
                    self.eventLabel.text = ""
                    self.doneButton.alpha = 1
                    AppManager.sharedInstance().addAction(action: "Silent video rendering finished", session: "Record" + self.post.id.description , detail: "")
                })
                }else{
                    AppManager.sharedInstance().addAction(action: "Silent video rendering failed", session: "Record" + self.post.id.description , detail: "")
                }
            })
        }
        }else{
            AppManager.sharedInstance().addAction(action: "Recording Tapped While Not Ready", session: "Record" + post.id.description, detail: "")
        }
    }
    
    //Setups
    func setCaptureDevices(){
        if self.currentCaptureDevice == nil{
        
//        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera ], mediaType: AVMediaType.video, position: AVCaptureDevice.Position.unspecified)
//            let devices = deviceDiscoverySession.devices
            
            
        let devices = AVCaptureDevice.devices(for: AVMediaType.video)
        
            
        
        for device in devices {
            if device.hasMediaType(AVMediaType.video){
            if device.position == AVCaptureDevice.Position.back {
                backCaptureDevice = device
            } else if device.position == AVCaptureDevice.Position.front {
                frontCaptureDevice = device
            }
        }
            }
        currentCaptureDevice = frontCaptureDevice
        }
        
    }
    
    func createURL(){
        let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        // Get the current date which will be used as the name of the file
//        let currentDateTime = NSDate()
//        let formatter = DateFormatter()
//        formatter.dateFormat = "ddMMyyyy-HHmmss"
//        let date = formatter.string(from: currentDateTime as Date)
        
        let karaAudioName = [dirPath, "Temp" + "K.caf"]
        let recordedAudioName = [dirPath, "Temp" + "R.caf"]
        let capturedVideoName = [dirPath, "Temp" + "C.mp4"]
        self.karaAudioPath = NSURL.fileURL(withPathComponents: karaAudioName)
        self.recordedVoicePath = NSURL.fileURL(withPathComponents: recordedAudioName)
        self.capturingVideoPath = NSURL.fileURL(withPathComponents: capturedVideoName)

    }
    
    func startAudioRecording(){
        self.recordManager.pause()
//        let tapBuffer : AVAudioFrameCount = 4096 * 4
//        engine.mainMixerNode.removeTap(onBus: 0)
//        kara?.play()
//        mixer.installTap(onBus: 0, bufferSize: tapBuffer , format:mixer.outputFormat(forBus: 0), block:{ buffer, when in
//            do{ try self.outputFile.write(from: buffer)}
//            catch { print(NSString(string: "Write failed"))
//            }})
        self.recordManager.startRecording()
    }
    
    var lastDownloadBye = 0
    
    @objc func updateTimerLine(){
        if self.isRecording{
            DispatchQueue.main.async {

                if self.recordManager != nil {
                    self.elapsedTime = self.recordManager.currentTime()
                    if !self.original {
                    if self.post.content.liveLyrics.count > self.currentLine + 1 {
                        if Float(self.elapsedTime) + 0.001  >= self.post.content.liveLyrics[self.currentLine].time {
                            
                            if self.post.content.liveLyrics[self.currentLine].text.count > 1 {
                                
                                let indexPath = IndexPath(row: self.currentLine, section: 0)
                                
                                
                                let deadlineTime = DispatchTime.now() + .milliseconds(1)
                                DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
//                                    self.lyricTableView.beginUpdates()
                                    self.lyricTableView.reloadRows(at: [indexPath], with: .none )
                                    self.lyricTableView.scrollToRow(at: indexPath, at: .top , animated: true)
                                   
//                                    self.lyricTableView.endUpdates()
                                    
                                }
                                
                                self.currentLine += 1
                            }else{
                                self.currentLine += 1
//                                self.lyricTableView.reloadData()
                            }
                            
                        }
                    }
                }
                }
            }
            
            let scrWidth = self.view.frame.width
            let width = CGFloat(Float(self.elapsedTime) / Float(self.songDuration)) * scrWidth
            self.timeBarWidthConstraint.constant = CGFloat(width)
         
            
        }else if self.recordingDone && self.isPlaying{
            if !isMovingSlider {
            DispatchQueue.main.async {
                
            
            if self.elapsedTime <= self.songDuration {
                self.playSlider.value = Float(Float(self.elapsedTime) / Float(self.songDuration))
                self.elapsedTime += 0.001
            }else{
                self.playSlider.value = 0.0
//                self.mixManager.seekTo(second: 0, duration: Float(self.songDuration))
                self.audioMixer.seekTo(time: 0)
                self.elapsedTime = 0.0
                if self.camera_On{
                    self.videoPlayer.pause()
                    self.videoPlayer.seek(to: kCMTimeZero)
                    self.videoPlayer.play()
                }
                self.audioMixer.play()
//                self.mixManager.play()
            }
            
        }
            }
        }else if !self.isReady && self.shouldDownload{
            if downloadedBytes > lastDownloadBye {
                lastDownloadBye = downloadedBytes
                self.elapsedDownloadTime = 0.0
            }else if self.elapsedDownloadTime > 7{
                self.downloadedBytes = 0
                self.lastDownloadBye = 0
                self.downloadRequest?.suspend()
                self.downloadKaraoke()
                self.elapsedDownloadTime = 0
            }else{
                self.elapsedDownloadTime += 0.001
            }
            
        }
    }
    
    func stopAudioRecording(){
        self.recordManager.stopRecording()
        self.recordManager.removeNotification()
        self.recordManager = nil
        print("Recording done")
    }
    
    //video capture delegate
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
    }
    
    
    func prepareToReview(){
        self.recordingDone = true
        
        
        audioMixer = AudioMixer(recordedFileURL: self.recordedVoicePath, karaFileURL: self.karaAudioPath)
        audioMixer.setNotification()
        audioMixer.seekTo(time: 0.0)
        audioMixer.setVoiceVol(vol: 0.5)
        if self.micPlugged{
            audioMixer.setPlaybackVol(vol: 0.5)
            playbackVolumeSlider.value = 0.5
        }else{
            audioMixer.setPlaybackVol(vol: 0.0)
            playbackVolumeSlider.value = 0.0
        }
        
//        mixManager = MixManager(karaURL: self.karaAudioPath , recordedFileURL: self.recordedVoicePath , sound: true)
//        mixManager.setNotification()
//        mixManager.seekTo(second: 0.0, duration: Float(self.songDuration))
//        mixManager.play()
       
       
        self.eventLabel.text = "در حال پردازش...."
        self.backButton.setTitle("", for: .normal)
        self.backButton.layer.cornerRadius = 10
        self.backButton.isUserInteractionEnabled = false
        
        if self.camera_On{
            videoPreviewLayer?.removeFromSuperlayer()
            captureSession?.stopRunning()
            playerItem = AVPlayerItem(url: self.capturingVideoPath!)
            videoPlayer = AVPlayer(playerItem: playerItem)
            playerLayer = AVPlayerLayer(player: videoPlayer)
            playerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
            playerLayer.frame = PreviewView.bounds
            playerLayer?.masksToBounds = true
            
            self.PreviewView.layer.addSublayer(playerLayer!)
        }
        self.setActionForEffectButtons()
        
        UIView.animate(withDuration: 1.5, animations: {() -> Void in
            self.recordButtonVerticalConstraint.constant = 150
            self.prviewViewBottomConstraint.priority = UILayoutPriority.init(rawValue: 997)
            self.effectsVerticalConstraint.constant = -15
            self.previewViewTrailingConstraint.constant = 35
            self.recordButton.alpha = 0.2
            self.recordImageView.alpha = 0.2
            self.previewViewTopConstraint.priority = UILayoutPriority.init(rawValue: 999)
            self.loadingShadowContainerView.alpha = 0
//            self.blurryView.alpha = 0
            self.LyricsTextView.alpha = 0
            self.loadingBarView.alpha = 0
            self.playSlider.alpha = 1
            self.playButton.alpha = 1
            self.yourVolumeLabel.alpha = 1
            self.yourVolumeSlider.alpha = 1
            self.playbackVolumeLabel.alpha = 1
            self.playbackVolumeSlider.alpha = 1
//            self.doneButton.alpha = 1
            self.PreviewView.layer.cornerRadius = 10
            self.yourVolumeSlider.value = 0.5
//            self.playbackVolumeSlider.value = 0.5
            self.backButton.setTitle("حذف ", for: .normal)
            self.backButton.backgroundColor = UIColor.red
            self.backButton.setTitleColor(UIColor.white, for: .normal)
            self.backButton.alpha = 1
            self.backButton.isUserInteractionEnabled = true
            self.view.layoutIfNeeded()
        })
        
       
        self.view.isUserInteractionEnabled = true
        self.setActionForEffectButtons()
        self.noEffectLabel.textColor = UIColor.purple
        self.noEffectImageButton.isUserInteractionEnabled = true
        self.reverbEffectImageButton.isUserInteractionEnabled = true
        self.multiLineEffectImageButton.isUserInteractionEnabled = true
        self.grungeEffectImageButton.isUserInteractionEnabled = true
        self.heliumEffectImageButton.isUserInteractionEnabled = true

        self.elapsedTime = 0.0
        self.pause()
        
    }
    
    func setActionForEffectButtons(){
        
        let noEffect = UITapGestureRecognizer { (gesture:UIGestureRecognizer?) in
            self.deactiveAllEffects()
            self.noEffectImageButton.image = UIImage(named:"normal-a")
//            self.mixManager.setMixer(effect: .none )
            self.audioMixer.setEffect(effect: .none)
            self.effect = .none
            self.noEffectLabel.textColor = UIColor.purple
            AppManager.sharedInstance().addAction(action: "Effect Tapped", session: "Record" + self.post.id.description, detail: "No Effect")
            self.pause()
            self.play()
            
        }
        self.noEffectImageButton.addGestureRecognizer(noEffect!)
        
        let multiLine = UITapGestureRecognizer { (gesture:UIGestureRecognizer?) in
            self.deactiveAllEffects()
            self.multiLineEffectImageButton.image = UIImage(named: "flanger-a")
//            self.mixManager.setMixer(effect: .multiline )
            self.audioMixer.setEffect(effect: .multiline)
            self.effect = .multiline
            self.echoEffectLabel.textColor = UIColor.purple
            AppManager.sharedInstance().addAction(action: "Effect Tapped", session: "Record" + self.post.id.description, detail: "Echo")
            self.pause()
            self.play()
            
        }
        self.multiLineEffectImageButton.addGestureRecognizer(multiLine!)
        
        let reverb = UITapGestureRecognizer { (gesture:UIGestureRecognizer?) in
            self.deactiveAllEffects()
            self.reverbEffectImageButton.image = UIImage(named:"reverb-a")
//            self.mixManager.setMixer(effect: .reverb )
            self.audioMixer.setEffect(effect: .reverb)
            self.effect = .reverb
            self.ReverbEffectLabel.textColor = UIColor.purple
            AppManager.sharedInstance().addAction(action: "Effect Tapped", session: "Record" + self.post.id.description, detail: "Reverb")
            self.pause()
            self.play()
            
        }
        self.reverbEffectImageButton.addGestureRecognizer(reverb!)
        
        let grunge = UITapGestureRecognizer { (gesture:UIGestureRecognizer?) in
            self.deactiveAllEffects()
            self.grungeEffectImageButton.image = UIImage(named:"grunge-a")
//            self.mixManager.setMixer(effect: .grunge )
            self.audioMixer.setEffect(effect: .grunge)
            self.effect = .grunge
            self.GrungeEffectLabel.textColor = UIColor.purple
            AppManager.sharedInstance().addAction(action: "Effect Tapped", session: "Record" + self.post.id.description, detail: "Distortion")
            self.pause()
            self.play()
            
        }
        self.grungeEffectImageButton.addGestureRecognizer(grunge!)
        
        let helium = UITapGestureRecognizer { (gesture:UIGestureRecognizer?) in
            self.deactiveAllEffects()
            self.heliumEffectImageButton.image = UIImage(named:"helium-a")
//            self.mixManager.setMixer(effect: .helium )
            self.audioMixer.setEffect(effect: .helium)
            self.effect = .helium
            self.HeliumEffectLabel.textColor = UIColor.purple
            AppManager.sharedInstance().addAction(action: "Effect Tapped", session: "Record" + self.post.id.description, detail: "Helium")
            self.pause()
            self.play()
            
        }
        self.heliumEffectImageButton.addGestureRecognizer(helium!)
        
        let playButtonTap = UITapGestureRecognizer { (gesture:UIGestureRecognizer?) in
            if self.isPlaying{
                self.playButton.image = UIImage(named: "play")
                self.pause()
            }else{
                self.playButton.image = UIImage(named: "pause")
                self.play()
            }
        }
        self.playButton.addGestureRecognizer(playButtonTap!)
        self.playButton.isUserInteractionEnabled = true
        
    }
    
    func play(){
        
//        mixManager.seekTo(second: self.elapsedTime, duration: Float(self.songDuration))
        audioMixer.seekTo(time: self.elapsedTime)
        self.isPlaying = false
        if self.camera_On{
            let seekTime = CMTime(seconds: self.elapsedTime , preferredTimescale: videoPlayer.currentTime().timescale )
            playerItem?.seek(to: seekTime, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero)
            videoPlayer.pause()
        }
        
//        mixManager.play()
        audioMixer.play()
        self.isPlaying = true
        if self.camera_On{
            videoPlayer.play()
        }
        self.playButton.image = UIImage(named: "pause")
        
    }
    
    func pause(){
        
        self.isPlaying = false
//        mixManager.pause()
        audioMixer.pause()
        if self.camera_On{
            videoPlayer.pause()
        }
        self.playButton.image = UIImage(named: "play")
    }
    
    
    
    func deactiveAllEffects(){
        
        self.noEffectImageButton.image = UIImage(named: "normal-d")
        self.reverbEffectImageButton.image = UIImage(named: "reverb-d")
        self.multiLineEffectImageButton.image = UIImage(named: "flanger-d")
        self.grungeEffectImageButton.image = UIImage(named: "grunge-d")
        self.heliumEffectImageButton.image = UIImage(named: "helium-d")
        
        self.noEffectLabel.textColor = UIColor.darkGray
        self.echoEffectLabel.textColor = UIColor.darkGray
        self.ReverbEffectLabel.textColor = UIColor.darkGray
        self.HeliumEffectLabel.textColor = UIColor.darkGray
        self.GrungeEffectLabel.textColor = UIColor.darkGray
        
    }
    
    @IBAction func playSliderTuchDown(_ sender: UISlider) {
        self.isMovingSlider = true
        if self.camera_On{
            videoPlayer.pause()
        }
//        mixManager.pause()
        audioMixer.pause()
    }
    

    @IBAction func playSliderTouchUpInside(_ sender: Any) {
        self.elapsedTime = Double(self.playSlider.value)*self.songDuration
//        mixManager.seekTo(second: self.elapsedTime, duration: Float(self.songDuration))
        audioMixer.seekTo(time: self.elapsedTime)
        if self.camera_On {
            let seekTime = CMTime(seconds: self.elapsedTime , preferredTimescale: videoPlayer.currentTime().timescale )
            playerItem?.seek(to: seekTime, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero)
            videoPlayer.play()
        }
//        mixManager.play()
        audioMixer.play()
        self.isPlaying = true
        self.isMovingSlider = false
        self.playButton.image = UIImage(named : "pause")

    }
    
    @IBAction func yourVolumeChanged(_ sender: Any) {
//        mixManager.setYourVolume(volume: self.yourVolumeSlider.value)
        audioMixer.setVoiceVol(vol: self.yourVolumeSlider.value)
    }
    
    @IBAction func playbackVolumeChanged(_ sender: Any) {
//        mixManager.setPlaybackVolume(volume: self.playbackVolumeSlider.value)
        audioMixer.setPlaybackVol(vol: self.playbackVolumeSlider.value)
    }
    
    
//    @IBAction func yourVolumeReleased(_ sender: UISlider) {
//        AppManager.sharedInstance().addAction(action: "Recorded Volume Changed", session: "Record" + post.id.description, detail: sender.value.description)
//    }
//
//
//    @IBAction func playbackVolumeReleased(_ sender: UISlider) {
//          AppManager.sharedInstance().addAction(action: "Karaoke Volume Changed", session: "Record" + post.id.description, detail: sender.value.description)
//    }
    
    var chunckLength = 0.0
    var delay = 1.0
    var urlArray : [String] = []
    var dialog : DialougeView? = DialougeView()
    
    
    
    
    
    @IBAction func done(_ sender: Any) {
        //show dialogue
        let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let currentDateTime = NSDate()
        let formatter = DateFormatter()
        formatter.dateFormat = "ddMMyyyy-HHmmss"
        let date = formatter.string(from: currentDateTime as Date)
        let akOutput = [dirPath, "Temp" + "AudioKit.caf"]
        try? FileManager.default.removeItem(at:  (NSURL.fileURL(withPathComponents: akOutput))!)
        
        AppManager.sharedInstance().addAction(action: "Done Tapped", session: "Record" + post.id.description, detail: "")
        AppManager.sharedInstance().addAction(action: "Recorded Volume Set", session: "Record" + post.id.description, detail: self.yourVolumeSlider.value.description)
        AppManager.sharedInstance().addAction(action: "Karaoke Volume Set", session: "Record" + post.id.description, detail: self.playbackVolumeSlider.value.description)
        
        self.pause()
//        mixManager.soundOff()
//        self.mixManager = nil
        self.viewWillDisappear(false)
//        let audioMixer = AudioMixer(recordedFileURL: self.recordedVoicePath, karaFileURL: karaAudioPath)

        audioMixer.render(url: (NSURL.fileURL(withPathComponents: akOutput))!)
        NotificationCenter.default.removeObserver(audioMixer)
        audioMixer = nil
        

        dialog?.shouldRender(vc: self, completionHandler: {

            save in

            if save{
               DispatchQueue.main.async  {
                AppManager.sharedInstance().addAction(action: "Save Tapped", session: "Record" + self.post.id.description, detail: "")
                self.dialog?.hide()
                self.dialog?.waitingBox(vc: self)

//            var pieces = 1
//
//            for i in 1...10{
//
//                if self.songDuration/Double(i) > 10 {
//                    pieces = i
//                }
//
//            }
//
//            self.chunckLength = self.songDuration/Double(pieces)
//
//
//            print("Song Duration is :\(self.songDuration) according to Record VC")

//            self.mixManager = MixManager(karaURL: self.karaAudioPath, recordedFileURL: self.recordedVoicePath, sound: false, pieceCount: pieces)
//            self.mixManager.setNotification()
//            self.mixManager.soundOff()
//            self.mixManager.setYourVolume(volume: self.yourVolumeSlider.value)
//            self.mixManager.setPlaybackVolume(volume: self.playbackVolumeSlider.value)



//            for i in 0...pieces - 1{
//                let karaAudioName = [dirPath, "Temp" + "Part\(i).caf"]
//                self.urlArray.append((NSURL.fileURL(withPathComponents: karaAudioName)?.absoluteString)!)
//            }
//
//            self.mixManager.setMixer(effect: self.effect)
//            self.mixManager.seekTo(second: 0.0, duration: Float(self.songDuration), index: 0)
//            self.mixManager.renderChunk(index: 0, chunckLength: self.chunckLength, duration: self.songDuration, urlString: self.urlArray[0])
//
//            if pieces > 1{
//            for i in 1...pieces-1{
//                self.mixManager.seekTo(second: self.chunckLength*Double(i) - self.delay , duration: Float(self.songDuration), index: i)
//            }
//
//            for i in 1...pieces-1{
//                self.mixManager.renderChunk(index: i, chunckLength: self.chunckLength, duration: self.songDuration, urlString: self.urlArray[i])
//            }
//            }

            let karaAudioName = [dirPath, date + "FINAL.mp4"]
            self.renderObjc.finalVideo = NSURL.fileURL(withPathComponents: karaAudioName)
            
//            MediaHelper.mixMultipleAudioWithVideo(duration: self.songDuration ,audio: self.urlArray, delay : self.delay, length: self.chunckLength, video: self.renderObjc.silentVideo!, output: self.renderObjc.finalVideo!, completionHandler: {
            MediaHelper.mixAudioVideo(audio:  (NSURL.fileURL(withPathComponents: akOutput))!, video: self.renderObjc.silentVideo!, output: self.renderObjc.finalVideo!, completionHandler: {
                
                success in
                
                
                if success {
                    print("DONEEEE CHECKOUT!!!!")
                    
                    let userPostObject = userPost()
                    userPostObject.kara = self.post
                    userPostObject.file.link = (self.renderObjc.finalVideo!.lastPathComponent)
                    AppManager.sharedInstance().addUserPost(post: userPostObject)
                    
                }
                
                try? FileManager.default.removeItem(at: self.karaAudioPath)
                try? FileManager.default.removeItem(at: self.recordedVoicePath)
                try? FileManager.default.removeItem(at: self.renderObjc.silentVideo!)
                try? FileManager.default.removeItem(at:  self.capturingVideoPath!)
                for item in self.urlArray{
                    let url = URL(string: item)
                    try? FileManager.default.removeItem(at: url!)
                }
                self.dialog?.hide()
                self.dialog = nil
                self.dismiss(animated: true, completion: nil)
            })
            
            }
            }else{
                AppManager.sharedInstance().addAction(action: "Delete Tapped", session: "Record" + self.post.id.description, detail: "")
                self.close(self)
            }
        })
        
    }
    

    
//    @objc func finalizeRender(){
//
//        DispatchQueue.main.async {
//
////        print("turning engine Off")
////        self.mixManager.stopRendering()
////        print("engine turned Off")
////        self.mixManager.removeNotification()
////        self.mixManager = nil
//
//            MediaHelper.mixMultipleAudioWithVideo(duration: self.songDuration ,audio: self.urlArray, delay : self.delay, length: self.chunckLength, video: self.renderObjc.silentVideo!, output: self.renderObjc.finalVideo!, completionHandler: {
//        success in
//
//
//        if success {
//        print("DONEEEE CHECKOUT!!!!")
//
//        let userPostObject = userPost()
//        userPostObject.kara = self.post
//        userPostObject.file.link = (self.renderObjc.finalVideo!.lastPathComponent)
//        AppManager.sharedInstance().addUserPost(post: userPostObject)
//
//        }
//
//
//        try? FileManager.default.removeItem(at: self.karaAudioPath)
//        try? FileManager.default.removeItem(at: self.recordedVoicePath)
//        try? FileManager.default.removeItem(at: self.renderObjc.silentVideo!)
//        try? FileManager.default.removeItem(at:  self.capturingVideoPath!)
//        for item in self.urlArray{
//        let url = URL(string: item)
//        try? FileManager.default.removeItem(at: url!)
//        }
//            self.dialog?.hide()
//        self.dialog = nil
//        self.dismiss(animated: true, completion: nil)
//        })
//    }
//    }
    
    func cleanFolder() {
        
        let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        
        if !self.isRecording && !self.isReady{
        try? FileManager.default.removeItem(at: self.karaAudioPath)
        try? FileManager.default.removeItem(at: self.recordedVoicePath)
            
        let capture = [dirPath, "Temp" + "C.mp4"]
        let captureURL = NSURL.fileURL(withPathComponents: capture)
        try? FileManager.default.removeItem(at: captureURL!)
        
        let silent = [dirPath, "Temp" + "SILENT.mp4"]
        let silentURL = NSURL.fileURL(withPathComponents: silent)
        try? FileManager.default.removeItem(at: silentURL!)
        
        for i in 0...10{
            let path = [dirPath, "Temp" + "Part\(i).caf"]
            let url = NSURL.fileURL(withPathComponents: path)
            try? FileManager.default.removeItem(at: url!)
        }
        
    }
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        AppManager.sharedInstance().addAction(action: "View Did Disappear", session: "Record" + post.id.description, detail: "")
    }
    
}

