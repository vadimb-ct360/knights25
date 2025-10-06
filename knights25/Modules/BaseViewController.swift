//
//  BaseViewController.swift
//  knights25
//
//  Created by Vadim Bashurov on 25.09.2025.
//


// Base/BaseViewController.swift
import UIKit
import GoogleMobileAds

class BaseViewController: UIViewController, BannerViewDelegate {
    private var bannerView: BannerView?
    var showsSoundButton: Bool = true
    var isSoundOn: Bool = true

    private lazy var soundItem = UIBarButtonItem(
        image: nil,
        style: .plain,
        target: self,
        action: #selector(didTapSound)
    )


    override func viewDidLoad() {
        super.viewDidLoad()
        //      setupAdBanner()
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
    
    deinit { NotificationCenter.default.removeObserver(self) }

    
   
    private func setupAdBanner() {
        let banner = BannerView(adSize: AdSizeBanner) // temporary size; we’ll set adaptive size below
        banner.adUnitID = "ca-app-pub-3793510413673173/5434020692"   // TODO: your banner unit id
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
        // Safe-area width for adaptive anchored banner
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

    // MARK: - Actions

    @objc private func didTapSound() {
        SoundManager.shared.toggle()
        updateSoundItem()
        soundSettingDidChange(isOn: SoundManager.shared.isOn) // hook for subclasses
    }

    @objc private func handleSoundChanged(_ note: Notification) {
        updateSoundItem()
        if let isOn = note.userInfo?["isOn"] as? Bool {
            soundSettingDidChange(isOn: isOn) // hook for subclasses
        }
    }

    // MARK: - UI

    private func updateSoundItem() {
        let isOn = SoundManager.shared.isOn
        // SF Symbols (iOS 13+). Replace with your own images if you prefer.
        let name = isOn ? "speaker.wave.2.fill" : "speaker.slash.fill"
        soundItem.image = UIImage(systemName: name)
        soundItem.accessibilityLabel = isOn ? "Sound On" : "Sound Off"
        isSoundOn = isOn
  
    }

    // MARK: - Override point for screens to react (start/stop music, etc.)
    @objc func soundSettingDidChange(isOn: Bool) {
        // Subclasses override to start/stop their players or SFX
        self.isSoundOn = isOn
    }
    
    
    func playSound(_ sound: String) {
        SFX.shared.playIfOn(sound, isOn: isSoundOn)
    }
  
}
