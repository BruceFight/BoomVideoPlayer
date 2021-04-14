//
//  BoomReachability.swift
//  BoomVideoPlayer
//
//  Created by jianghongbao on 2021/4/13.
//


import UIKit
import ReachabilitySwift

enum BoomNetworkType {
    case BoomNetworkTypeWiFi
    case BoomNetworkTypeWWAN
    case BoomNetworkTypeNone
}

class BoomReachability: NSObject {

    public static let instance = BoomReachability()
    private var reachability = Reachability()
    public var reachable: Bool = false
    public var networkType: BoomNetworkType?
    public var networkStatusCallBack: ((_ isEnable: Bool, _ networkType: BoomNetworkType) -> Void)?
    
    /// 开始监听网络
    func startNotifier() {
        guard let reachability = Reachability() else { return }
        self.reachability = reachability
        do {
            try reachability.startNotifier()
            NotificationCenter.default.addObserver(self, selector: #selector(getCurrentNetwork), name: ReachabilityChangedNotification, object: nil)
        } catch _ {
            
        }
    }
    
    /// 获取网络状态及类型
    @objc func getCurrentNetwork() {
        // 检测网络连接状态
        guard let _reachable = self.reachability?.isReachable else { return }
        self.reachable = _reachable
        
        _reachable ? print("网络连接：可用") : print("网络连接：不可用")
        
        guard let _reachability = self.reachability else { return }
        // 检测网络类型
        if (_reachability.isReachableViaWiFi) {
            print("网络类型：Wifi")
            networkType = BoomNetworkType.BoomNetworkTypeWiFi
        } else if (_reachability.isReachableViaWWAN) {
            print("网络类型：移动网络")
            networkType = BoomNetworkType.BoomNetworkTypeWWAN
        } else {
            print("网络类型：无网络连接")
            networkType = BoomNetworkType.BoomNetworkTypeNone
        }
        
        guard let networkT = networkType else {
            return
        }
        self.networkType = networkT
        networkStatusCallBack?(_reachable, networkT)
    }
 
}
