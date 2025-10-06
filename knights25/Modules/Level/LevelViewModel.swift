//
//  LevelViewModel.swift
//  knights25
//
//  Created by Vadim on 18. 9. 2025..
//

import Foundation

final class LevelViewModel {
    let level: Level
    let totalScore: Int
    let bestLevelScore: Int
    let userId: String?
    private let scoreService: ScoreService
 
    
    var onNextLevelPreviewUpdate: (() -> Void)?
 
    var nextLevelBestScore: Int?
    
    init(level: Level,
         totalScore: Int,
         bestLevelScore: Int,
         userId: String? = nil,
         scoreService: ScoreService = DefaultScoreService()) {
        self.level = level
        self.totalScore = totalScore
        self.bestLevelScore = bestLevelScore
        self.userId = userId
        self.scoreService = scoreService
    }

    var nextLevel: Level {
        Level(for: level.num + 1)
    }

    var nextLevelDescription: String {
        if let n = nextLevelBestScore {
            return "Best Score: \(n)"
        }
        return ""
    }

 
    
    func saveScore(completion: @escaping (Bool) -> Void) {
        scoreService.saveScore(userId: userId, score: totalScore, level: level.num, rate: 0) { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let info):
                        self?.nextLevelBestScore = Int(info.bestLevelScore)
                        self?.onNextLevelPreviewUpdate?()
                        completion(true)
                    case .failure:
                        completion(false)
                    }
                }
            }
        }

}
