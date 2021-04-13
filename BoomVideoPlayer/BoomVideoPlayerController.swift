//
//  BoomVideoPlayerController.swift
//  BoomVideoPlayer
//
//  Created by jianghongbao on 2021/4/13.
//
 
import UIKit
import AVFoundation
//import ReachabilitySwift

class BoomVideoPlayerController: UIViewController {
    
    //MARK: - Parameters
    // 播放器
    var avplayer = AVPlayer.init()
    // 播放Item
    var playerItem : AVPlayerItem?
    // 显示器
    var playerLayer = AVPlayerLayer.init()
    // link
    var link:CADisplayLink!
    // 返回按钮
    var backBtn = UIButton()
    // 是否已添加观察者
    var kIfMovedObserver = true
    // 控制视图
    var controlView = BoomVideoPlayerControlView()
    //隐藏状态栏
    var statusbarShouldHide : Bool = true
    //全屏锁定
    var lockFullScreen : Bool = true
    
    let bottomLayer = CALayer.init()

    //MARK: - init
    init(url : String) {
        super.init(nibName: nil, bundle: nil)
        setPlayerViewWithUrl(url: url)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - interface
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        self.view.backgroundColor = .black
        self.addPlayView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(becomeActive), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
    }
    
    @objc func becomeActive() {
        let orientationTarget = NSNumber.init(value: (UIInterfaceOrientation.landscapeLeft).hashValue)
        UIDevice.current.setValue(orientationTarget, forKey: "orientation")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.becomeActive()
        
//        BoomReachability.instance.netorkStatusCallBack = { [weak self](reachable,networkType) in
//             self?.doSomeThingWithNetworkStatus(reachable, networkType)
//        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        backBtn.frame = CGRect.init(x: 0, y: 0, width: 30, height: 30)
        controlView.frame = CGRect.init(x: 0, y: self.view.bounds.size.height - 60, width: self.view.bounds.size.width, height: 60)
        playerLayer.frame = self.view.bounds
        bottomLayer.frame = playerLayer.frame
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        self.doSomeThingWithNetworkStatus(BoomReachability.instance.reachable, BoomReachability.instance.networkType)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        removeObserver()
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscapeRight
    }
    
    override var shouldAutorotate: Bool {
        return false
    }

    ///@布局子视图
    func addPlayView() {
        self.view.addSubview(UIView())
        
        backBtn.layer.cornerRadius = 15
//        backBtn.setImage( #imageLiteral(resourceName: "redBack_image.png"), for: UIControlState.normal)
        backBtn.backgroundColor = UIColor.white
        backBtn.addTarget(self, action: #selector(BoomVideoPlayerController.backMainFace), for: UIControlEvents.touchUpInside)
        backBtn.transform = CGAffineTransform(translationX: 0, y: -60)
        self.view.addSubview(backBtn)
        
        self.controlView.controlButtonClickedHandler = { [weak self] (btn) in
            switch btn.tag {
            case 100://play
                self?.jb_play()
                break
            case 200://pause
                self?.jb_pause()
                break
            default:break
            }
        }
        self.controlView.progressChangedHandler = { [weak self] (slider) in
            print("slider >>> \(slider.value)")
            let cur = Float((self?.totalTime())!) * slider.value
            self?.controlView.currentTimeLabel.text = "\(Int(cur/60))'\(Int(cur.truncatingRemainder(dividingBy: 60)))\""
            self?.avplayer.currentItem?.seek(to: CMTime.init(value: CMTimeValue(cur), timescale: CMTimeScale(1)))
        }
//        self.controlView.transform = CGAffineTransform(translationX: 0, y: self.view.bounds.size.height + 60)
        self.view.addSubview(controlView)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
            UIView.animate(withDuration: 0.45, animations: {
//                self.controlView.transform = CGAffineTransform.identity
//                self.backBtn.transform = CGAffineTransform.identity
            })
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
 
    //MARK: - deinit(一定要在退出时移除通知与各监听)
    deinit{
        print("❤️ Deinit -> \(self)")
    }
}

//MARK: - Network Status
extension BoomVideoPlayerController {
    /*
    func doSomeThingWithNetworkStatus(_ reachable:Bool,_ networkType:JB_NetworkType?) {
        if !reachable {
            let alertVc = UIAlertController.init(title: "Wrong Network !", message: "The current network is useless, Please check in 'Personal Setting !'", preferredStyle: .alert)
            alertVc.addAction(UIAlertAction.init(title: "sure", style: .default, handler: { [weak self](action) in
                self?.backMainFace()
            }))
            self.present(alertVc, animated: true, completion: nil)
            print("Show Implement !")
        }else {
            guard let networkT = networkType else {
                return
            }
            var implementString = String()
            
            switch networkT {
            case .JB_NetworkTypeWiFi:
                print("💕 Current Network Type >>> WIFI")
                implementString = "Current Network Type >>> WIFI"
                break
            case .JB_NetworkTypeWWAN:
                print("💕 Current Network Type >>> WWAN")
                implementString = "Current Network Type >>> WWAN"
                break
            case .JB_NetworkTypeNone:
                print("💕 Current Network Type >>> NONE")
                implementString = "Current Network Type >>> NONE"
                break
            }
            
            let alertVc = UIAlertController.init(title: "Current Network !", message: implementString, preferredStyle: .alert)
            alertVc.addAction(UIAlertAction.init(title: "sure", style: .default, handler: { [weak self](action) in
                if networkT == .JB_NetworkTypeNone{
                    self?.backMainFace()
                }else{
                    
                }
            }))
            self.present(alertVc, animated: true, completion: nil)
        }
    }
 */
}

//MARK: - Observer
extension BoomVideoPlayerController {
    ///@添加观察者
    func addObserver() {
        if kIfMovedObserver==true {
            // 监听缓冲进度改变
            playerItem?.addObserver(self, forKeyPath: "loadedTimeRanges", options: NSKeyValueObservingOptions.new, context: nil)
            // 监听状态改变
            playerItem?.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions.new, context: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(jb_playFinished), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
            self.link = CADisplayLink(target: self, selector: #selector(update))
            kIfMovedObserver=false
        }
    }
    
    ///@移除观察者
    func removeObserver() {
        if kIfMovedObserver==false {
            playerItem?.removeObserver(self, forKeyPath: "loadedTimeRanges")
            playerItem?.removeObserver(self, forKeyPath: "status")
            NotificationCenter.default.removeObserver(self)
            self.link.invalidate()
            self.link = nil
            kIfMovedObserver=true
        }
    }
    
    //MARK: - 实现监听方法
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let playerItem = object as? AVPlayerItem else { return }
        if keyPath == "loadedTimeRanges"{
            //通过监听AVPlayerItem的"loadedTimeRanges"，可以实时知道当前视频的进度缓冲
            let loadedTime = avalableDurationWithplayerItem()
            let totalTime = CMTimeGetSeconds(playerItem.duration)
            let percent = loadedTime / totalTime
            print("💖percent:"+"\(percent)")
            self.controlView.bufferView.setProgress(Float(percent), animated: true)
            if percent >= 1 {
                self.controlView.bufferView.setProgress(1, animated: true)
            }
        }else if keyPath == "status"{
            switch playerItem.status {
            case .failed:
                print("加载failed")
                break
            case .readyToPlay:
                jb_play()
                break
            case .unknown:
                print("加载unknown")
                break
            }
        }
    }
}

//MARK: - Details
extension BoomVideoPlayerController {
    //MARK: - 创建播放
    func setPlayerViewWithUrl(url:String) {
        if url.isEmpty || (url == "") {
            assert(false, "URL can not be nil or empty !")
            return
        }
        // 检测连接是否存在 不存在报错
        playerItem = AVPlayerItem(url:URL.init(string: url)!) // 创建视频资源
        addObserver()
        // 将视频资源赋值给视频播放对象
        self.avplayer = AVPlayer(playerItem: playerItem)
        // 初始化视频显示layer
        playerLayer = AVPlayerLayer(player: self.avplayer)
        bottomLayer.backgroundColor = UIColor.black.cgColor
        
        // 设置显示模式
        playerLayer.videoGravity = AVLayerVideoGravity.resizeAspect
        playerLayer.contentsScale = UIScreen.main.scale
        // 位置放在最底下
        self.view.layer.insertSublayer(playerLayer, at: 1)
        self.view.layer.insertSublayer(bottomLayer, at: 0)
    }
    
    ///@play
    func jb_play() {
        self.avplayer.play()
        self.link.add(to: RunLoop.main, forMode: RunLoopMode.defaultRunLoopMode)
        self.link.isPaused = false
    }
    
    ///@pause
    func jb_pause() {
        self.avplayer.pause()
        self.link.isPaused = true
    }
    
    ///@播放完毕
    @objc func jb_playFinished() {
        print("<<< 播放完毕 >>>")
        removeObserver()
    }
    
    ///@获取时间
    func avalableDurationWithplayerItem() -> TimeInterval{
        guard let loadedTimeRanges = avplayer.currentItem?.loadedTimeRanges,let first = loadedTimeRanges.first else {fatalError()}
        let timeRange = first.timeRangeValue
        let startSeconds = CMTimeGetSeconds(timeRange.start)
        let durationSecound = CMTimeGetSeconds(timeRange.duration)
        let result = startSeconds + durationSecound
        return result
    }
    
    ///@update
    @objc func update(){
        let currentTime = CMTimeGetSeconds(self.avplayer.currentTime())
        let totalTime = TimeInterval((self.avplayer.currentItem?.duration.value)!) / TimeInterval((self.avplayer.currentItem?.duration.timescale)!)
        
        print("Time: \(Int(currentTime/60))'\(Int(currentTime.truncatingRemainder(dividingBy: 60)))\" | \(Int(totalTime/60))'\(Int(totalTime.truncatingRemainder(dividingBy: 60)))\"")
        controlView.sliderView.value = Float(currentTime/totalTime)
        controlView.currentTimeLabel.text = "\(Int(currentTime/60))'\(Int(currentTime.truncatingRemainder(dividingBy: 60)))\""
        controlView.totalTimeLabel.text = "\(Int(totalTime/60))'\(Int(totalTime.truncatingRemainder(dividingBy: 60)))\""
        /*
         let current = self.avplayer.currentTime()
         let currentValue = Int(current.value)/Int(current.timescale)
         print("CurrentTime >>> \(currentValue))")
         print("TotalTime >>> \(String(describing: self.avplayer.currentItem?.asset.duration.seconds))")
         */
    }
    
    ///@getCurrentTime
    func currentTime() -> (Int) {// 秒为单位
        return Int(CMTimeGetSeconds(self.avplayer.currentTime()))
    }
    
    ///@getTotalTime
    func totalTime() -> (Int) {
        return Int(TimeInterval((self.avplayer.currentItem?.duration.value)!) / TimeInterval((self.avplayer.currentItem?.duration.timescale)!))
    }
    
    ///@back
    @objc func backMainFace() {
        //self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }
}

