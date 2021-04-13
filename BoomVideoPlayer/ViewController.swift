//
//  ViewController.swift
//  BoomVideoPlayer
//
//  Created by jianghongbao on 2021/4/13.
//


import UIKit

class ViewController: UIViewController {
    
    private var button = UIButton()
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

    override var shouldAutorotate: Bool {
        return true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let orientationTarget = NSNumber.init(value: (UIInterfaceOrientation.portrait).hashValue)
        UIDevice.current.setValue(orientationTarget, forKey: "orientation")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        button.backgroundColor = .lightGray
        button.setTitle("进入播放视频", for: .normal)
        button.addTarget(self, action: #selector(click), for: UIControlEvents.touchUpInside)
        self.view.addSubview(button)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        button.sizeToFit()
        button.frame = CGRect.init(x: 0, y: 0, width: button.bounds.size.width + 50, height: 50)
        button.center = self.view.center
    }
    
    @objc func click() {
        // http://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4
        // http://vjs.zencdn.net/v/oceans.mp4
        // https://media.w3.org/2010/05/sintel/trailer.mp4
        let url = "https://media.w3.org/2010/05/sintel/trailer.mp4"
        let checkVc = BoomVideoPlayerController.init(url:url)
        //self.navigationController?.pushViewController(checkVc, animated: true)
        checkVc.modalPresentationStyle = .fullScreen
        self.present(checkVc, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}


