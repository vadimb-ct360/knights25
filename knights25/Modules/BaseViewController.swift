//
//  BaseViewController.swift
//  knights25
//
//  Created by Vadim Bashurov on 25.09.2025.
//

import UIKit
import GoogleMobileAds
import AVFoundation

class BaseViewController: UIViewController, BannerViewDelegate {
    private var bannerView: BannerView?
    private var queuePlayer: AVQueuePlayer?
    private var looper: AVPlayerLooper?
    
    var showsSoundButton: Bool = true
    var isSoundOn: Bool = true
    var loopName: String?
    
    
    private lazy var soundItem = UIBarButtonItem(
        image: nil,
        style: .plain,
        target: self,
        action: #selector(didTapSound)
    )
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAdBanner()
        if showsSoundButton {
            navigationItem.rightBarButtonItems = [soundItem] + (navigationItem.rightBarButtonItems ?? [])
            updateSoundItem()
        }
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleSoundChanged(_:)),
            name: .soundSettingDidChange,
            object: nil
        )
    }
    
    deinit { NotificationCenter.default.removeObserver(self)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startGaplessLoop()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopGapless()
    }
    
    
    private func setupAdBanner() {
        let banner = BannerView(adSize: AdSizeBanner)
        banner.adUnitID = "ca-app-pub-3793510413673173/5434020692"
        banner.rootViewController = self
        banner.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(banner)
        let g = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            banner.centerXAnchor.constraint(equalTo: g.centerXAnchor),
            banner.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        print("Load AdMob banner")
        bannerView = banner
        banner.load(Request())
        updateAdaptiveBannerSize()
    }
    
    private func updateAdaptiveBannerSize() {
        guard let banner = bannerView else { return }
        let frame = view.frame.inset(by: view.safeAreaInsets)
        let width = frame.size.width
        banner.adSize = currentOrientationAnchoredAdaptiveBanner(width: width)
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateAdaptiveBannerSize()
        if let banner = bannerView {
            view.bringSubviewToFront(banner)
        }
    }
    
    
    @objc private func didTapSound() {
        SoundManager.shared.toggle()
        updateSoundItem()
        soundSettingDidChange(isOn: SoundManager.shared.isOn)
    }
    
    @objc private func handleSoundChanged(_ note: Notification) {
        updateSoundItem()
        if let isOn = note.userInfo?["isOn"] as? Bool {
            soundSettingDidChange(isOn: isOn)
        }
    }
    
    
    private func updateSoundItem() {
        let isOn = SoundManager.shared.isOn
        let name = isOn ? "speaker.wave.2.fill" : "speaker.slash.fill"
        soundItem.image = UIImage(systemName: name)
        soundItem.accessibilityLabel = isOn ? "Sound On" : "Sound Off"
        isSoundOn = isOn
    }
    
    
    @objc func soundSettingDidChange(isOn: Bool) {
        self.isSoundOn = isOn
        if isOn {
            startGaplessLoop()
        } else {
            stopGapless()
        }
    }
    
    
    
    func playSound(_ sound: String) {
        SFX.shared.playIfOn(sound, isOn: isSoundOn)
    }
    
    
    private func startGaplessLoop() {
        guard isSoundOn else { return }
        guard let name = loopName else { return }
        
        let url = Bundle.main.url(forResource: name, withExtension: "caf", subdirectory: "Resources/Sound")
        ?? Bundle.main.url(forResource: name, withExtension: "caf")
        guard let url else { print("loop caf not found"); return }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch { print(error) }
        
        let item = AVPlayerItem(url: url)
        let player = AVQueuePlayer()
        self.queuePlayer = player
        self.looper = AVPlayerLooper(player: player, templateItem: item) // infinite
        player.play()
    }
    
    private func stopGapless() {
        looper?.disableLooping()
        queuePlayer?.pause()
        queuePlayer = nil
        looper = nil
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }
}
