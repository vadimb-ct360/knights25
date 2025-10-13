//
//  GameState.swift
//  knights25
//
//  Created by Vadim on 18. 9. 2025..
//

enum Status {
    case playing
    case lastKnight 
    case levelCompleted
    case gameOver
}

struct GameState {
    var level: Level
    var board: [[Int]]
    var moves: Int
    var score: Int
    var bomb: Int = 0
    var bonus: Int = 1
    var lastColor: Int = 0
    var numLastColor: Int = 0
    var remainingMoves: Int { max(0, level.moveQuota - moves) }
    var allowFreeMove: Bool { bomb>0 && (level.isCleaning || remainingMoves > 1) }
    var status: Status = .playing
    
    static func make(level: Level,
                     board: [[Int]]
    ) -> GameState {
        GameState(level: level,
                  board: board,
                  moves: 0,
                  score: 0,
                  bomb: 0,
                  bonus: 1,
                  lastColor: 0,
                  numLastColor: 0)
    }
}
