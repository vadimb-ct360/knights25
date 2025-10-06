//
//  PlayViewModel.swift
//  knights25
//
//  Created by Vadim on 18. 9. 2025..
//

import Foundation
import UIKit

final class PlayViewModel {
    
    private let gameService: GameService
    private(set) var state: GameState!
    
    // setup in Coordinator
    var onShowBest: (() -> Void)?
    var onShowHelp: ((Bool) -> Void)?
    
    var onShowLevelView: ((Level, Int) -> Void)?
    var onShowFinalView: ((FinalSummary) -> Void)?

    var onSoundChanged: ((Bool) -> Void)?
    var onLevelFinished: ((Bool) -> Void)?
    var onFreeMove: (() -> Void )?
    
    var onDropKnight: (_ target: (Int, Int)) -> Void = { _ in }
    var onDropTwoKnights: ( _ target1: (Int, Int), _ target2: (Int, Int)) -> Void = { _,_ in }
    
    
    private let soundKey = "soundOn"
    var isSoundOn: Bool {
        get {
            if UserDefaults.standard.object(forKey: soundKey) == nil { return true }
            return UserDefaults.standard.bool(forKey: soundKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: soundKey)
            onSoundChanged?(newValue)
        }
    }
    
    
    // Bindings to VC
    var onStateChanged: ((GameState) -> Void)?
    
    init(gameService: GameService) {
        self.gameService = gameService
    }
    
    func start(levelNumber: Int = 1) {
        state = gameService.initGame(levelNumber: levelNumber)
        onStateChanged?(state)
    }
    
    func toggleSound() { isSoundOn.toggle() }
    
    func exitToBest() {
        onShowBest?()
    }
    
    func exitToHelp() {
        onShowHelp?(isSoundOn)
    }
    
  

    func isValidMove(from: (Int,Int), to: (Int,Int)) -> Int {
         return gameService.isValidMove(in: state, from: from, to: to)
    }
    
    func validTargetsForDrag(from src: (Int,Int)) -> (merges: [(Int,Int)], bombEmpties: [(Int,Int)]) {
        return gameService.validTargets(from: src, in: state)
    }
    
    
    func applyUserBootstrap( bestLevel: String) {
        state.level.bestScore = Int(bestLevel) ?? 77
        onStateChanged?(state)
    }
    
    func bombTapped() {
        gameService.bombTapped(to: &state)
        onStateChanged?(state)
    
    }
    
    func showLevelView() {
        onShowLevelView?(state.level, state.score)
    }
    
    func showFinalView() {
        let s = FinalSummary(totalScore: state.score, levelsCleared: state.level.num-1, bonus: state.bonus, bestScore: state.level.totalBestScore, todayBestScore: state.level.todayBestScore)
        onShowFinalView?(s)
    }
  
    func checkEnd() -> Bool {
        
        if gameService.checkEnd(in: state) {
            state.status = .gameOver
            return true
        }
        return false
    }

    
    func makeMove(_ move: Move) -> (Int, Int) {
        let srcColor = state.board[move.from.0][move.from.1]
        let dstColor = state.board[move.to.0][move.to.1]
        let mergedColor: Int? = (srcColor > 0 && dstColor == srcColor) ? srcColor : nil
        
        var delta = gameService.applyMove(move, to: &state)
        var bonus = 0
      
        if state.remainingMoves == 0 {
            
            if let color = mergedColor {
                let mergeResult = gameService.applyMergeBonus(for: color, to: &state)
                if mergeResult > 0 {
                    delta += mergeResult
                    gameService.spawnOneDrop(from:0, to: &state)
                }
            }
        
            
            state.bomb += state.level.isBonus ? 1 : 0
            var d = state.level.num + state.bonus
            state.bonus += state.level.isCleaning ? 0 : 1
            d += gameService.clear13(for: &state)
    
            state.score += d
            delta += d
            onLevelFinished?(true)
            return (delta, bonus)
        }
        
        // Post-merge bonus ONLY for the merged color
        if let color = mergedColor {
            let mergeResult = gameService.applyMergeBonus(for: color, to: &state)
            if mergeResult > 0 {
                delta += mergeResult
                let target1 = gameService.spawnOneDrop(from:0, to: &state)
                let target2 = gameService.spawnOneDrop(from:1, to: &state)
                onDropTwoKnights(target1, target2)
                print("onDropTwoKnights")
            } else {
                bonus = gameService.isSuperBonus(in: state)
                let target = gameService.spawnOneDrop(from:0, to: &state)
                if bonus>1 {
                    let b = bonus - 2
                    state.bomb += b
                    let d = (state.level.num + state.bonus) * b
                    state.score += d
                    delta += d
                    state.bonus += b
                }
      
                onDropKnight(target)
           }
        } else {
            onFreeMove?()
         }
        
        onStateChanged?(state)
      return  (delta, bonus)
        
        
    }
    
    func isSuperBonus() -> Bool {
        let b = gameService.isSuperBonus(in: state)
        if b>1 {
            state.score += b * state.bonus
            state.bomb += b-1
            state.bonus += b
            onStateChanged?(state)
        
        }
        return b>0
    }
  
   
    func shiftDrops() -> Void {
        gameService.shiftDrops(to: &state)
    }
    
    func nextLevel(_ best: Int? ) {
        gameService.advanceToLevel(state.level.num + 1, state: &state)
        if let best {
            state.level.bestScore = best
        }
        onStateChanged?(state)
    }
    
 }
