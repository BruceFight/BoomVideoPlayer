//
//  BoomVideoPlayerControlView.swift
//  BoomVideoPlayer
//
//  Created by jianghongbao on 2021/4/13.
//


import UIKit

class BoomVideoPlayerControlView: UIView {

    private var playBtn = UIButton()
    private var pauseBtn = UIButton()
    public var bufferView = UIProgressView()
    public var sliderView = UISlider()
    public var currentTimeLabel = UILabel()
    public var totalTimeLabel = UILabel()
    var controlButtonClickedHandler: ((_ button:UIButton) -> Void)?
    var progressChangedHandler: ((_ slider:UISlider) -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        playBtn.frame = CGRect.init(x: 0, y: 0, width: frame.size.width/2, height: frame.size.height)
        pauseBtn.frame = CGRect.init(x: playBtn.frame.maxX, y: 0, width: playBtn.bounds.size.width, height: frame.size.height)
        bufferView.frame = CGRect.init(x: 0, y: frame.size.height-2, width: frame.size.width, height: 2)
        sliderView.frame = bufferView.bounds
        currentTimeLabel.sizeToFit()
        currentTimeLabel.frame = CGRect.init(x: 0, y: (frame.size.height-currentTimeLabel.bounds.size.height)/2, width: currentTimeLabel.bounds.size.width, height: currentTimeLabel.bounds.size.height)
        totalTimeLabel.sizeToFit()
        totalTimeLabel.frame = CGRect.init(x: frame.size.width-totalTimeLabel.bounds.size.width, y: (frame.size.height-totalTimeLabel.bounds.size.height)/2, width:totalTimeLabel.bounds.size.width, height: totalTimeLabel.bounds.size.height)
    }
    
    private func configureSubviews() {
        self.backgroundColor = UIColor.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.6)
        playBtn.tag = 100
        playBtn.setTitle("Play", for: .normal)
        playBtn.setTitleColor(.white, for: .normal)
        playBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 22)
        playBtn.addTarget(self, action: #selector(contentBtnClicked(btn:)), for: .touchUpInside)
          
        pauseBtn.tag = 200
        pauseBtn.setTitle("Pause", for: .normal)
        pauseBtn.setTitleColor(.white, for: .normal)
        pauseBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 22)
        pauseBtn.addTarget(self, action: #selector(contentBtnClicked(btn:)), for: .touchUpInside)
        
        self.addSubview(playBtn)
        self.addSubview(pauseBtn)
        
        bufferView.progressTintColor = .green
        bufferView.trackTintColor = .red
        self.addSubview(bufferView)
        
        sliderView.addTarget(self, action: #selector(changeProgress), for: .valueChanged)
        self.addSubview(sliderView)
        
        currentTimeLabel.font = .systemFont(ofSize: 12)
        currentTimeLabel.text = "00'00\""
        currentTimeLabel.textColor = .white
        
        totalTimeLabel.font = .systemFont(ofSize: 12)
        totalTimeLabel.text = "00'00\""
        totalTimeLabel.textAlignment = .right
        totalTimeLabel.textColor = .white
        
        self.addSubview(currentTimeLabel)
        self.addSubview(totalTimeLabel)
    }
    
    @objc func contentBtnClicked(btn: UIButton) {
        controlButtonClickedHandler?(btn)
    }

    @objc func changeProgress(slider: UISlider) {
        progressChangedHandler?(slider)
    }
    
}
