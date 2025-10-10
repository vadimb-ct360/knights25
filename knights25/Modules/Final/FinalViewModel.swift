//
//  FinalViewModel.swift
//  knights25
//
//  Created by Vadim on 18. 9. 2025..
//

import Foundation

struct FinalSummary {
    let totalScore: Int
    let levelsCleared: Int
    let bonus: Int
    let bestScore: Int
    let todayBestScore: Int
}

final class FinalViewModel {
    let summary: FinalSummary
    let userId: String?
    private let scoreService: ScoreService
    var onScoreSaved: (() -> Void)?
    
    let rate: Int
    var sMax: Int = 15000
    var bMax: Int = 150
    var lMax: Int = 30
    var title: String = "Donald Trump"
    
    
    init(summary: FinalSummary,
         userId: String?,
         scoreService: ScoreService = DefaultScoreService()
    ) {
        self.summary = summary
        self.userId = userId
        self.scoreService = scoreService
        let logic = ScoreLogic.getRate(for: summary.totalScore, summary.bonus, summary.levelsCleared)
        self.rate = logic[0]
        self.sMax = logic[1]
        self.bMax = logic[2]
        self.lMax = logic[3]
        self.title = ScoreLogic.getName(rate: logic[0])
    }
    
    
    func saveScore(completion: @escaping (Bool) -> Void) {
        
        print("save final score")
        scoreService.saveScore(userId: userId, score: summary.totalScore, level: 0, rate: rate) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.onScoreSaved?()
                    completion(true)
                case .failure:
                    completion(false)
                }
            }
        }
    }
    
}
