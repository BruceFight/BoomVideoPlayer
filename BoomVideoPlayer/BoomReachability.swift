//
//  BoomReachability.swift
//  BoomVideoPlayer
//
//  Created by jianghongbao on 2021/4/13.
//


import UIKit
//import ReachabilitySwift

enum JB_NetworkType {
    case JB_NetworkTypeWiFi
    case JB_NetworkTypeWWAN
    case JB_NetworkTypeNone
}

class BoomReachability: NSObject {
/*
    public static let instance   = BoomReachability()
    fileprivate var reachability = Reachability()
    public var netorkStatusCallBack : ((_ isEnable:Bool,_ networkType:JB_NetworkType) -> Void)?
    
    public var reachable = Bool()
    public var networkType : JB_NetworkType?
    // 开始监听网络
    func startNotifier() {
        guard let reachability = Reachability.init() else{return}
        self.reachability = reachability
        
        do {
            try reachability.startNotifier()
            NotificationCenter.default.addObserver(self, selector: #selector(getCurrentNetwork), name: ReachabilityChangedNotification, object: nil)
        } catch _ {
            
        }
    }
    
    // 获取网络状态及类型
    @objc func getCurrentNetwork() {
        // 检测网络连接状态
        guard let reachable = self.reachability?.isReachable else {
            return
        }
        self.reachable = reachable
        
        
        if (self.reachability?.isReachable)! {
            print("网络连接：可用")
        } else {
            print("网络连接：不可用")
        }
        
        // 检测网络类型
        if (self.reachability?.isReachableViaWiFi)! {
            print("网络类型：Wifi")
            networkType = JB_NetworkType.JB_NetworkTypeWiFi
        } else if (self.reachability?.isReachableViaWWAN)! {
            print("网络类型：移动网络")
            networkType = JB_NetworkType.JB_NetworkTypeWWAN
        } else {
            print("网络类型：无网络连接")
            networkType = JB_NetworkType.JB_NetworkTypeNone
        }
        
        guard let networkT = networkType else {
            return
        }
        self.networkType = networkT
        netorkStatusCallBack?(reachable,self.networkType!)
    }
 */
}
