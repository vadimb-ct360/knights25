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
    var icon: String = "level_2"
    var ground: String = "bg_1"
    var drops: [Int]
    var diablo: Int { num==10 ? 1 : num==13 ? 2 : num==26 ? 3 : 0}
   
    init(for num: Int) {
        let n = num-1
        let colors: [Int] =  [
            2,3,4,5,2,
            3,4,2,3,2,
            3,2,3,4,2,
            3,2,3,4,2,
            3,2,3,2,2,
            3,2,3,2,2,
            3,2,3,2,3,
        ]
        let numColors = n<colors.count ? colors[n] :  2
        
        let moves = [
           15,20,20,15,67,
            25,10,25,10,20,
            10,10,20,10,15,
            10,15,10,20,15,
            10,10,10,10,10,
            20,10,10,10,10]
        
        let gNum = [
            13, 2, 1, 1, 3,
            4, 12, 5, 10, 15,
            9, 6, 14, 7, 1,
            1, 1, 1, 1, 1,
            2, 8, 11, 9, 12,
            14, 2, 13, 3, 9,
        ]

        let iNum = [
            0, 1, 2, 2, 16,
            4, 22, 15, 7, 29,
            6, 8, 31, 19, 21,
            12, 13, 14, 20, 16,
            17,  9, 10, 18, 12,
            30, 22, 23, 24, 18,
        ]

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
        self.isCleaning = (num>=15 && num<=20) || num==3 || num==4
        self.drops = drops
        self.ground = n<gNum.count ? "bg_\(gNum[n])" : "bg_1"
        self.icon = n<iNum.count ? "level_\(iNum[n])" : "level_2"
    
        
    }
    
}
