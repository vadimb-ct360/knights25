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
    var levelName: String = "Papa Buba"
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
        
        let names = [
            "Beggins", "Keepubu","KNavy","Safubu", "Polgar",
            "Stephano","Wane","Lenin","Olga","Diablo",
            "Leo","Nikki","Diablo","Keepubu","Aceana",
            "Safubu","Emma","Keepubu","Mentor","Safubu",
            "Wabubu","Keepubu","Anandu","Diego","Mario",
            "Diablo","Emmica","Espozito","GarryK","Keepubu",
            "Magnus","Fisher","","","",
            
        ]
        
        
        let moves = [
            15,20,20,15,67,
            25,10,30,25,20,
            10,10,20,10,15,
            10,15,10,20,15,
            10,10,10,10,10,
            20,10,10,10,10]
        
        let gNum = [
            13, 1, 2, 1, 3,
            4, 15, 11, 10, 14,
            9, 6, 14, 1, 7,
            1, 17, 1, 8, 1,
            2, 1, 16, 9, 12,
            14, 5, 13, 3, 1,
            6, 12,
        ]
        
        let iNum = [
            0, 2, 8, 2, 1,
            15, 22, 4, 14, 20,
            6, 13, 20, 2, 17,
            2, 7, 2, 0, 2,
            11, 2, 21, 18, 12,
            20, 7, 10, 23, 2,
            24, 11,
        ]
        
        let moveQuota: Int = n<moves.count ? moves[n] : 10
      //     let moveQuota: Int = 3
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
        self.isCleaning = num==14 || num==16 || num==18 || num==20 || num==22 || num==30 || num==2 || num==4
        self.drops = drops
        self.ground = n<gNum.count ? "bg_\(gNum[n])" : "bg_1"
        self.icon = n<iNum.count ? "level_\(iNum[n])" : "level_2"
        self.levelName = n<names.count ? names[n] : "Papa Buba"
    
        
    }
    
}
