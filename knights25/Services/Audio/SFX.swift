//
//  SFX.swift
//  knights25
//
//  Created by Vadim Bashurov on 20.09.2025.
//

import AVFoundation

final class SFX {
    static let shared = SFX()
    private var players: [String: [AVAudioPlayer]] = [:]
    private let queue = DispatchQueue(label: "SFX.pool")
    
    func preload() {
        ["merge_1","merge_2","merge_3","drop","shift","score","click","bomb","level","alarm","final", "sling", "end", "clear", "pink", "stolen"].forEach { _ = warm($0) }
    }
    
    func play(_ name: String, volume: Float = 1.0) {
        queue.async {
            guard let p = self.idlePlayer(for: name) ?? self.warm(name) else { return }
            p.stop(); p.currentTime = 0; p.volume = volume; p.play()
        }
    }
    
    func playIfOn(_ name: String, volume: Float = 1.0, isOn: Bool) {
        guard isOn else { return }; play(name, volume: volume)
    }
    
    private func warm(_ name: String) -> AVAudioPlayer? {
        guard let url = Bundle.main.url(forResource: "sfx_\(name)", withExtension: "caf") else { return nil }
        do {
            let p = try AVAudioPlayer(contentsOf: url)
            p.prepareToPlay()
            var arr = players[name] ?? []
            arr.append(p)
            players[name] = arr
            return p
        } catch { print("SFX load error(\(name)):", error); return nil }
    }
    
    private func idlePlayer(for name: String) -> AVAudioPlayer? {
        if let arr = players[name], let idle = arr.first(where: { !$0.isPlaying }) { return idle }
        return nil
    }
}
