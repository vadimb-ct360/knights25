//
//  AppDelegate.swift
//  knights25
//
//  Created by Vadim on 18. 9. 2025..
//

import UIKit
import AVFAudio
import GoogleMobileAds


@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        addAdMobBanner()
        addSoundModule()
        addTitleFont()
        return true
    }
    
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }
    
    private func addSoundModule() {
        do {
            // .ambient respects the mute switch. Use .playback to ignore mute switch.
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch { print("AudioSession error:", error) }
    }
    
    private func addAdMobBanner() {
        MobileAds.shared.start(completionHandler: nil)
    }
    
    
    private func addTitleFont() {
        
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithDefaultBackground()
        appearance.titleTextAttributes = [
            .font: AppFont.font(25, weight: .semibold),
            .foregroundColor: UIColor.label
        ]
        appearance.largeTitleTextAttributes = [
            .font: AppFont.font(25, weight: .bold),
            .foregroundColor: UIColor.label
        ]
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().tintColor = .systemBlue
        
    }
    
}

