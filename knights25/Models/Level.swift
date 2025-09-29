//
//  Level.swift
//  knights25
//
//  Created by Vadim Bashurov on 20.09.2025.
//

struct Level: Equatable, Codable {
    let num: Int 
    let moveQuota: Int
    let numColors: Int
    let isBonus: Bool
    let isCleaning: Bool
    var bestScore = 0
    var totalBestScore = 0
    var todayBestScore = 0
    var drops: [Int]
    
    init(for num: Int) {
        let n = num-1
        let colors: [Int] =  [
            2,3,4,5,2,
            3,4,2,3,2,
            3,2,3,4,2,
            3,2,3,4,2,
            3,2,3,4,2,
            3,2,3,2,2,
            3,2,3,2,3,
 ]
        let numColors = n<colors.count ? colors[n] :  2
        
        let moves = [
            15,20,20,15,50,
            20,20,20,20,15,
            10,10,10,10,15,
            10,10,10,10,15,
            10,10,15,20,15,
            15,20,15,10,10]
        
        let moveQuota: Int = n<moves.count ? moves[n] : 10
        var drops = (0..<10).map { _ in Int.random(in: 1...numColors) }
        
        if num > 1 && num < 9 {
            for i in  0..<4 {
                drops[i] = numColors
            }
        }
        if num >= 9 {
            let color = Int.random(in: 1...numColors)
            for i in 0..<3 {
                drops[i] = color
            }
        }
        
        self.num = num
        self.moveQuota = moveQuota
        self.numColors = numColors
        self.isBonus = (num != 13)
        self.isCleaning = (num>20 && num<28) || num==3 || num==4
        self.drops = drops
    }
    
}
