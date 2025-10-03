//
//  GameService.swift
//  knights25
//
//  Created by Vadim on 18. 9. 2025..
//

import Foundation

// MARK: - Move
struct Move {
    let from: (Int, Int)
    let to:   (Int, Int)
    init(from: (Int, Int), to: (Int, Int)) {
        self.from = from; self.to = to
    }
}

// MARK: - Protocol
protocol GameService {
    func initGame(levelNumber: Int) -> GameState
    @discardableResult
    func applyMove(_ move: Move, to state: inout GameState) -> Int
    func isLevelFinished(_ state: GameState) -> Bool
    func isGameOver(_ state: GameState) -> Bool
    func advanceToLevel(_ nextLevelNum: Int, state: inout GameState)
    func isSuperBonus(in state: GameState) -> Int 
    
    func bombTapped(to state: inout GameState)
    
    @discardableResult
    func applyMergeBonus(for color: Int,
                         to state: inout GameState) -> Int
    
    @discardableResult
    func spawnOneDrop(from index: Int, to state: inout GameState) -> (Int, Int)
    
 
    func shiftDrops(to state: inout GameState)
    func clear13(for state: inout GameState) -> Int
 
    func isValidMove(in state: GameState, from: (Int,Int), to: (Int,Int)) -> Int
    func validTargets(from: (Int,Int), in state: GameState) -> (merges: [(Int,Int)], bombEmpties: [(Int,Int)])
    func checkEnd(in state: GameState) -> Bool
}


// MARK: - Default Implementation
final class DefaultGameService: GameService {
    private let size = 5
    
    
    func initGame(levelNumber levelNum: Int) -> GameState {
        let lvl  = Level(for: levelNum)
        let board = generateBoard(size: size, numColors: lvl.numColors)
        return GameState.make(level: lvl, board: board)
    }
    
    
    
    
    // Services/DefaultGameService.swift
    @discardableResult
    func applyMergeBonus(for color: Int, to state: inout GameState) -> Int
    {
        
        
        // Count only the specified color and remember its last position
        var count = 0
        var delta = 0
        var lastPos: (Int,Int)?
        for r in 0..<state.board.count {
            for c in 0..<state.board[r].count where state.board[r][c] == color {
                count += 1
                lastPos = (r,c)
            }
        }
        
        
        guard count == 1, let p = lastPos else { return 0 }
        
        // Remove the last knight of that color
        state.board[p.0][p.1] = 0
        // Reward: +1 bomb
        state.bomb += 1
        state.bonus += 1
        state.score += state.bonus
        delta += state.bonus
        return delta
    }
    
    
    private func inBounds(_ rc:(Int,Int), size: Int) -> Bool {
        (0..<size).contains(rc.0) && (0..<size).contains(rc.1)
    }
    private func candidateMoves(from a:(Int,Int), size: Int) -> [(Int,Int)] {
        let d = [(1,2),(2,1),(-1,2),(-2,1),(1,-2),(2,-1),(-1,-2),(-2,-1)]
        return d.compactMap { (a.0 + $0.0, a.1 + $0.1) }.filter { inBounds($0, size: size) }
    }
    
    func isValidMove(in state: GameState, from a:(Int,Int), to b:(Int,Int)) -> Int {
        let dr = abs(a.0 - b.0), dc = abs(a.1 - b.1)
        guard (dr == 1 && dc == 2) || (dr == 2 && dc == 1) else { return 0 }
        let color = state.board[a.0][a.1]
        let dest  = state.board[b.0][b.1]
        
        if dest == 0 && state.allowFreeMove { return 1 }
        if dest == color && dest > 0 {
            return countColor(in: state, color)<3 ? 3 : 2
        }
        return 0
    }
    
    func checkEnd(in state: GameState) -> Bool {
        guard state.bomb == 0 else { return false }
        
        for r1 in 0..<state.board.count {
            for c1 in 0..<state.board[r1].count where state.board[r1][c1] > 0 {
                let color = state.board[r1][c1]
                for r2 in 0..<state.board.count {
                    for c2 in 0..<state.board[r2].count where state.board[r2][c2] == color {
                        let dr = abs(r2 - r1), dc = abs(c2 - c1)
                        if (dr == 1 && dc == 2) || (dr == 2 && dc == 1) {
                            return false
                        }
                    }
                }
            }
        }
        return true
    }
    
    
    private func countColor(in state: GameState, _ color: Int) -> Int {
        var count = 0
        for r in 0..<state.board.count {
            for c in 0..<state.board[r].count where state.board[r][c] == color {
                count += 1
            }
        }
        return count
    }
    
    func isSuperBonus(in state: GameState) -> Int {
        let color = state.level.drops[0]
        
        
        
        var count = 0
        var lastPos: (Int,Int)?
        for r in 0..<state.board.count {
            for c in 0..<state.board[r].count where state.board[r][c] == color {
                count += 1
                lastPos = (r,c)
            }
        }
        
        guard count == 1, let p = lastPos else { return 0 }
        // check empties
        var ecount = 0
        var gcount = 0
        for r in 0..<state.board.count {
            for c in 0..<state.board[r].count where state.board[r][c] == 0 {
                ecount += 1
                
                let dr = abs(p.0 - r), dc = abs(p.1 - c)
                if (dr == 1 && dc == 2) || (dr == 2 && dc == 1) {
                    
                    gcount += 1
                }
            }
        }
        
        
        
        return gcount==ecount ? ecount : 0
        
    }
    
    
    
    func validTargets(from src:(Int,Int), in state: GameState) -> (merges: [(Int,Int)], bombEmpties: [(Int,Int)]) {
        let N = state.board.count
        guard inBounds(src, size: N) else { return ([],[]) }
        let color = state.board[src.0][src.1]
        
        var merges: [(Int,Int)] = []
        var empties: [(Int,Int)] = []
        for dst in candidateMoves(from: src, size: N) {
            let v = state.board[dst.0][dst.1]
            if v == color && v > 0 { merges.append(dst) }
            else if v == 0 && state.allowFreeMove { empties.append(dst) }
        }
        return (merges, empties)
    }
    
    func advanceToLevel(_ nextLevelNum: Int, state: inout GameState) {
        
        let next = Level(for: nextLevelNum)
        state.level = next
        state.moves = 0
        state.score += next.num
        
    }
    
    
    func bombTapped(to state: inout GameState)  {
        var numShift = 0
        let rand = Int.random(in: 1...state.level.numColors)
        var numc = 0
        
        for r in 0..<state.board.count {
            for c in 0..<state.board[r].count where state.board[r][c] > 0 {
                state.board[r][c] = rand
                numc += 1
            }
        }
        
        
        for c in 0..<5 {
            var flag  = true
            for r in 0..<4 {
                let b = state.board[r][c]
                let d = state.board[r+1][c]
                if b>0 && d==0 && flag {
                    numShift += 1
                    flag = false
                    state.board[r+1][c] = b
                    state.board[r][c] = 0
                }
            }
        }
        
        if numc == 2 && Int.random(in: 0...2) == 0 {
            var r1 = 0
            var c1 = 0
            for r in 0..<state.board.count {
                for c in 0..<state.board[r].count where state.board[r][c] > 0 {
                    r1 = r
                    c1 = c
                    state.board[r][c] = 0
                }
            }
            
            state.board[r1][c1] = 6
            state.board[r1>2 ? r1-2 : r1 + 2][c1>1 ? c1-1 : c1 + 1] = 6
        }
        state.score += numc + numShift * state.level.num
    }
    
    
    @discardableResult
    func applyMove(_ move: Move, to state: inout GameState) -> Int {
        let N = state.board.count
        var ret = 0
        guard inBounds(move.from, N), inBounds(move.to, N) else { return ret }
        guard isKnightMove(from: move.from, to: move.to) else { return ret }
        
        let a = move.from, b = move.to
        let color = state.board[a.0][a.1]; guard color > 0 else { return ret }
        let dest = state.board[b.0][b.1]
        if color == state.lastColor {
            state.numLastColor += 1
        } else {
            state.numLastColor = 1
            state.lastColor = color
        }
        
        if dest == color && dest > 0 {
            state.board[a.0][a.1] = 0
            state.score += state.numLastColor
            state.moves += 1
            
            ret += state.numLastColor
            
              
            return ret
        } else if dest == 0 && state.bomb > 0 {
            state.score += state.numLastColor
            ret += state.numLastColor
            
            state.bomb -= 1
            state.board[a.0][a.1] = 0
            state.board[b.0][b.1] = color
            state.moves += 1
            return ret
        }
        return ret
    }
    
    func isLevelFinished(_ state: GameState) -> Bool { state.remainingMoves==0 }
    
    func isGameOver(_ state: GameState) -> Bool { false }
    
    
    func clear13(for state: inout GameState) -> Int {
        guard state.level.diablo>0 else { return 0 }
        var nc = 0
        for r in 0..<state.level.diablo {
            for c in 0..<state.board[r].count where state.board[r][c] > 0 {
                nc += 1
                state.board[r][c] = 0
            }
        }
        return nc
        
    }
 
    @discardableResult
    func spawnOneDrop(from index: Int, to state: inout GameState) -> (Int, Int) {
        var empties: [(Int, Int)] = []
        for r in 0..<state.board.count {
            for c in 0..<state.board[r].count where state.board[r][c] == 0 {
                empties.append((r,c))
            }
        }
        let target = empties.randomElement() ?? (0,0)
        let color = state.level.drops[index]
        //      let rand = Int.random(in: 1...state.level.numColors)
        //      state.level.drops.append(rand)
        state.board[target.0][target.1] = color
        return target
    }
    
     func  shiftDrops(to state: inout GameState)  {
        state.level.drops.removeFirst()
        let rand = Int.random(in: 1...state.level.numColors)
        state.level.drops.append(rand)
     //   return color
    }
    
    
    // Helpers
    private func isKnightMove(from a: (Int, Int), to b: (Int, Int)) -> Bool {
        let dr = abs(a.0 - b.0), dc = abs(a.1 - b.1)
        return (dr == 1 && dc == 2) || (dr == 2 && dc == 1)
    }
    private func inBounds(_ rc: (Int, Int), _ N: Int) -> Bool {
        (0..<N).contains(rc.0) && (0..<N).contains(rc.1)
    }
    
    private func generateBoard(size: Int, numColors: Int) -> [[Int]] {
        var b = Array(repeating: Array(repeating: 0, count: size), count: size)
        for r in 0..<size { for c in 0..<size { b[r][c] = Int.random(in: 1...numColors) } }
        b[1][2] = 0
        //    b[3][3] = 0
        return b
    }
}

