//
//  SoundManager.swift
//  knights25
//
//  Created by Vadim on 6. 10. 2025..
//


import Foundation

extension Notification.Name {
    static let soundSettingDidChange = Notification.Name("soundSettingDidChange")
}

final class SoundManager {
    static let shared = SoundManager()
    private init() {}

    private let key = "soundOn"
    private let defaults = UserDefaults.standard

    var isOn: Bool {
        get { defaults.object(forKey: key) as? Bool ?? true } // default ON
        set {
            defaults.set(newValue, forKey: key)
            NotificationCenter.default.post(name: .soundSettingDidChange, object: self, userInfo: ["isOn": newValue])
        }
    }

    func toggle() { isOn.toggle() }
}
