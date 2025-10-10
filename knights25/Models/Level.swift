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
    let isCleaning: Bool
    var bestScore = 102
    var totalBestScore = 0
    var todayBestScore = 0
    var icon: String = "level_0"
    var levelName: String = "Papa Buba"
    var ground: String = "bg_0"
    var drops: [Int]
    var diablo: Int { num==9 ? 1 : (num==14 || num==12) ? 2 : (num==19 || num==21) ? 3 : num==24 ? 4 : 0}
    
    init(for num: Int) {
        let n = num-1
        let colors: [Int] =  [
            2,3,4,5,2,
            3,4,2,3,4,
            2,3,3,4,2,
            3,2,3,4,2,
            3,2,3,2,2,
            3,2,3,2,2,
            2,2,2,2,2,
        ]
        let numColors = n<colors.count ? colors[n] :  2
        
        let names = [
            "Beggins", "Labu Keep","Aqua Red","Green Keeper", "Polgar",
            "Leo","Wane","Lenin","Diablo","Didi Keep",
            "Vaterflo","Diablo-2","Nikki","Diablo-2","Labu Keep",
            "Emma","M-mccay","Mario","Diablo-3","Boo Keep",
            "Diablo-3","Phil","Diego","Diablo-4","Last Keeper",
            "GarryK","Fisher","Magnus","Stepan", "Bilbo End",
            
        ]
        
        
        let moves = [
            15,20,20,15,67,
            25,25,30,25,15,
            10,20,10,20,15,
            10,10,10,20,15,
            20,10,10,20,10,
            20,10,10,10,10,
            10,10,20,20,20,
            50,50]
        
        let gNum = [
            13, 0, 2, 0, 3,
            10, 15, 11, 1, 0,
            7, 1, 6, 1,  0,
            5,  8, 12, 1, 0,
            1, 10, 13, 1, 0,
            14, 16, 15, 4, 0,
        ]
        
        let iNum = [
            0, 0, 8, 0, 2,
            6,  15,  3, 1, 0,
            17, 1, 13, 1, 0,
            7, 16, 12, 1,  0,
            1, 18, 10, 1, 0,
            11, 14, 4, 5, 0,
        ]
        
        let moveQuota: Int = n<moves.count ? moves[n] : 10
        //     let moveQuota: Int = 3
        var drops = (0..<10).map { _ in Int.random(in: 1...numColors) }
        
        if num > 1 && num < 9 {
            for i in  0..<3 {
                drops[i] = numColors
            }
        }
        if num >= 9 {
            let color = Int.random(in: 1...numColors)
            for i in 0..<2 {
                drops[i] = color
            }
        }
        
        self.num = num
        self.moveQuota = moveQuota
        self.numColors = numColors
        self.isCleaning = num==10 || num==15 || num==20 || num==25 || num>=30 || num==2 || num==4
        self.drops = drops
        self.ground = n<gNum.count ? "bg_\(gNum[n])" : "bg_0"
        self.icon = n<iNum.count ? "level_\(iNum[n])" : "level_0"
        self.levelName = n<names.count ? names[n] : "Buba Diop"
     }
}
