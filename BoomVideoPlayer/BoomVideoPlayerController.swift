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
    var avplayer = AVPlayer()
    // 播放Item
    var playerItem: AVPlayerItem?
    // 显示器
    var playerLayer = AVPlayerLayer()
    // link
    var link:CADisplayLink!
    // 返回按钮
    var backBtn = UIButton()
    // 是否已添加观察者
    var kIfMovedObserver = true
    // 控制视图
    var controlView = BoomVideoPlayerControlView()
    //隐藏状态栏
    var statusbarShouldHide: Bool = true
    //全屏锁定
    var lockFullScreen: Bool = true
    
    let bottomLayer = CALayer()

    //MARK: - init
    
    init(url: String) {
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
        BoomReachability.instance.networkStatusCallBack = { [weak self] (reachable,networkType) in
            if let self = self {
                self.doSomeThingWithNetworkStatus(reachable, networkType)
            }
        }
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
        self.doSomeThingWithNetworkStatus(BoomReachability.instance.reachable, BoomReachability.instance.networkType)
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
        backBtn.layer.cornerRadius = 15
        backBtn.setImage(#imageLiteral(resourceName: "redBack_image.png"), for: .normal)
        backBtn.backgroundColor = .white
        backBtn.addTarget(self, action: #selector(BoomVideoPlayerController.backMainFace), for: UIControlEvents.touchUpInside)
        backBtn.transform = CGAffineTransform(translationX: 0, y: -60)
        self.view.addSubview(backBtn)
        
        self.controlView.controlButtonClickedHandler = { [weak self] (btn) in
            switch btn.tag {
            case 100://play
                self?.boomPlay()
                break
            case 200://pause
                self?.boomPause()
                break
            default:break
            }
        }
        self.controlView.progressChangedHandler = { [weak self] (slider) in
            if let self = self {
                print("slider >>> \(slider.value)")
                let cur = Float(self.totalTime()) * slider.value
                self.controlView.currentTimeLabel.text = "\(Int(cur / 60))'\(Int(cur.truncatingRemainder(dividingBy: 60)))\""
                self.avplayer.currentItem?.seek(to: CMTime.init(value: CMTimeValue(cur), timescale: CMTimeScale(1)))
            }
        }
        self.view.addSubview(controlView)
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
    
    func doSomeThingWithNetworkStatus(_ reachable: Bool, _ networkType: BoomNetworkType?) {
        if !reachable {
            let alertVc = UIAlertController.init(title: "Wrong Network !", message: "The current network is useless, Please check in 'Personal Setting !'", preferredStyle: .alert)
            alertVc.addAction(UIAlertAction.init(title: "sure", style: .default, handler: { [weak self] (action) in
                if let self = self {
                    self.backMainFace()
                }
            }))
            self.present(alertVc, animated: true, completion: nil)
            print("Show Implement !")
        }else {
            guard let networkT = networkType else {
                return
            }
            var implementString = ""
            
            switch networkT {
            case .BoomNetworkTypeWiFi:
                print("💕 Current Network Type >>> WIFI")
                implementString = "Current Network Type >>> WIFI"
                break
            case .BoomNetworkTypeWWAN:
                print("💕 Current Network Type >>> WWAN")
                implementString = "Current Network Type >>> WWAN"
                break
            case .BoomNetworkTypeNone:
                print("💕 Current Network Type >>> NONE")
                implementString = "Current Network Type >>> NONE"
                break
            }
            
            let alertVc = UIAlertController.init(title: "Current Network !", message: implementString, preferredStyle: .alert)
            alertVc.addAction(UIAlertAction.init(title: "sure", style: .default, handler: { [weak self](action) in
                if let self = self {
                    if networkT == .BoomNetworkTypeNone{
                        self.backMainFace()
                    }else{
                        
                    }
                }
            }))
            self.present(alertVc, animated: true, completion: nil)
        }
    }
    
}

//MARK: - Observer

extension BoomVideoPlayerController {
    
    /// 添加观察者
    func addObserver() {
        if kIfMovedObserver == true {
            // 监听缓冲进度改变
            playerItem?.addObserver(self, forKeyPath: "loadedTimeRanges", options: NSKeyValueObservingOptions.new, context: nil)
            // 监听状态改变
            playerItem?.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions.new, context: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(boomPlayFinished), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
            self.link = CADisplayLink(target: self, selector: #selector(update))
            kIfMovedObserver = false
        }
    }
    
    /// 移除观察者
    func removeObserver() {
        if kIfMovedObserver == false {
            playerItem?.removeObserver(self, forKeyPath: "loadedTimeRanges")
            playerItem?.removeObserver(self, forKeyPath: "status")
            NotificationCenter.default.removeObserver(self)
            self.link.invalidate()
            self.link = nil
            kIfMovedObserver = true
        }
    }
    
    /// 实现监听方法
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        guard let playerItem = object as? AVPlayerItem else { return }
        if keyPath == "loadedTimeRanges" {
            //通过监听AVPlayerItem的"loadedTimeRanges"，可以实时知道当前视频的进度缓冲
            let loadedTime = avalableDurationWithplayerItem()
            let totalTime = CMTimeGetSeconds(playerItem.duration)
            let percent = loadedTime / totalTime
            print("💖percent:" + "\(percent)")
            self.controlView.bufferView.setProgress(Float(percent), animated: true)
            if percent >= 1 {
                self.controlView.bufferView.setProgress(1, animated: true)
            }
        } else if keyPath == "status" {
            switch playerItem.status {
            case .failed:
                print("加载failed")
                break
            case .readyToPlay:
                boomPlay()
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
    
    /// 创建播放
    func setPlayerViewWithUrl(url: String) {
        if url.isEmpty {
            assert(false, "URL can not be nil or empty !")
            return
        }
        // 检测连接是否存在 不存在报错
        guard let _url = URL.init(string: url) else { return }
        playerItem = AVPlayerItem(url: _url) // 创建视频资源
        addObserver()
        // 将视频资源赋值给视频播放对象
        self.avplayer = AVPlayer(playerItem: playerItem)
        // 初始化视频显示layer
        playerLayer = AVPlayerLayer(player: self.avplayer)
        bottomLayer.backgroundColor = UIColor.black.cgColor
        
        // 设置显示模式
        playerLayer.videoGravity = .resizeAspect
        playerLayer.contentsScale = UIScreen.main.scale
        // 位置放在最底下
        self.view.layer.insertSublayer(playerLayer, at: 1)
        self.view.layer.insertSublayer(bottomLayer, at: 0)
    }
    
    /// play
    func boomPlay() {
        self.avplayer.play()
        self.link.add(to: .main, forMode: .defaultRunLoopMode)
        self.link.isPaused = false
    }
    
    /// pause
    func boomPause() {
        self.avplayer.pause()
        self.link.isPaused = true
    }
    
    /// 播放完毕
    @objc func boomPlayFinished() {
        print("<<< 播放完毕 >>>")
        removeObserver()
    }
    
    /// 获取时间
    func avalableDurationWithplayerItem() -> TimeInterval {
        guard let loadedTimeRanges = avplayer.currentItem?.loadedTimeRanges, let first = loadedTimeRanges.first else { fatalError() }
        let timeRange = first.timeRangeValue
        let startSeconds = CMTimeGetSeconds(timeRange.start)
        let durationSecound = CMTimeGetSeconds(timeRange.duration)
        let result = startSeconds + durationSecound
        return result
    }
    
    /// update
    @objc func update(){
        let currentTime = CMTimeGetSeconds(self.avplayer.currentTime())
        let totalTime = self.fetchTotalTimeParams().0 / self.fetchTotalTimeParams().1
        
        let currentMinutes = Int(currentTime / 60)
        let currentSeconds = Int(currentTime.truncatingRemainder(dividingBy: 60))
        let totalMinutes = Int(totalTime / 60)
        let totalSeconds = Int(totalTime.truncatingRemainder(dividingBy: 60))
        print("Time: \(currentMinutes)'\(currentSeconds)\" | \(totalMinutes)'\(totalSeconds)\"")
        
        controlView.sliderView.value = Float(currentTime / totalTime)
        controlView.currentTimeLabel.text = "\(currentMinutes)'\(currentSeconds)\""
        controlView.totalTimeLabel.text = "\(totalMinutes)'\(totalSeconds)\""
    }
    
    /// getCurrentTime
    func currentTime() -> Int {// 秒为单位
        return Int(CMTimeGetSeconds(self.avplayer.currentTime()))
    }
    
    /// getTotalTime
    func totalTime() -> Int {
        return Int(self.fetchTotalTimeParams().0 / self.fetchTotalTimeParams().0)
    }
    
    private func fetchTotalTimeParams() -> (TimeInterval, TimeInterval) {
        var totalInt: TimeInterval = 0
        var totalScale: TimeInterval = 1
        if let totalValue = self.avplayer.currentItem?.duration.value {
            totalInt = TimeInterval(totalValue)
        }
        if let totalScaleValue = self.avplayer.currentItem?.duration.timescale {
            totalScale = TimeInterval(totalScaleValue)
        }
        return (totalInt, totalScale)
    }
    
    /// back
    @objc func backMainFace() {
        self.dismiss(animated: true, completion: nil)
    }
    
}

