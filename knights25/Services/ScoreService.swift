//
//  ScoreService.swift
//  knights25
//
//  Created by Vadim Bashurov on 21.09.2025.
//

import Foundation

enum ScoreLogic {
    static func getRate(for score: Int, _ bonus: Int, _ level: Int) -> [Int] {
        var rate = 1
        let sMax = 30000
        let bMax = 300
        let lMax = 30
      
        if score >= sMax/5 { rate += 1 }
        if score >= sMax/2 { rate += 1 }
        if score >= sMax { rate += 1 }

        if bonus >= bMax-50 { rate += 1 }
        if bonus >= bMax-25 { rate += 1 }
        if bonus >= bMax { rate += 1 }

        if level >= lMax-20 { rate += 1 }
        if level >= lMax-10 { rate += 1 }
        if level >= 30 { rate += 1 }

        return [rate, sMax, bMax, lMax]
        }
    static func getName(rate: Int) -> String {
        return [
                "Donald Trump","Mikhail Tal", "Emanuel Lasker", "Viswanat Anand",
                "Boris Spassky","Garry Kasparov", "Magnus Carlsen", "Vlad Kramnik",
                "Alexander Alekhine","Mikhail Botvinnik",
                "Tigran Petrosian", "Ding Liren", "Bobby Fischer",
                "Anatol Karpov", "J R Capablanca",][rate-1]
    }
}



protocol ScoreService {
    /// Returns bestLevelScore for NEXT level (N+1) if provided by server
    func saveScore(userId: String?, score: Int, level: Int, rate: Int,
                   completion: @escaping (Result<SaveScoreResponse, Error>) -> Void)
  
}

struct SaveScoreResponse: Decodable {
    let userId: String
    let userName: String
    let bestTotalScore: String
    let bestTodayScore: String
    let bestLevelScore: String
}


final class DefaultScoreService: ScoreService {
    
    func saveScore(userId: String?, score: Int, level: Int, rate: Int,
                   completion: @escaping (Result<SaveScoreResponse, Error>) -> Void) {
        var comps = URLComponents()
        comps.scheme = "https"                   // use "http" only if your server isn’t TLS
        comps.host   = "bashurov.net"
        comps.path   = "/knights25/api/save_score.php"
        comps.queryItems = [
            .init(name: "userid", value: userId),
            .init(name: "score",  value: String(score)),
            .init(name: "level",  value: String(level)),
            .init(name: "rate",  value: String(rate))
    ]
        guard let url = comps.url else {
            return completion(.failure(NSError(domain: "ScoreService", code: -1,
                                               userInfo: [NSLocalizedDescriptionKey: "Bad URL"])))
        }

        var req = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 15)
        req.setValue("application/json", forHTTPHeaderField: "Accept")

        URLSession.shared.dataTask(with: req) { data, response, error in
            if let error = error { return completion(.failure(error)) }
            guard let http = response as? HTTPURLResponse else {
                return completion(.failure(NSError(domain: "ScoreService", code: -2,
                                                   userInfo: [NSLocalizedDescriptionKey: "No HTTP response"]))) }
            guard (200...299).contains(http.statusCode) else {
                let body = data.flatMap { String(data: $0, encoding: .utf8) } ?? "<empty>"
                return completion(.failure(NSError(domain: "ScoreService", code: http.statusCode,
                                                   userInfo: [NSLocalizedDescriptionKey: "HTTP \(http.statusCode): \(body)"]))) }
            guard let data = data, !data.isEmpty else {
                return completion(.failure(NSError(domain: "ScoreService", code: -3,
                                                   userInfo: [NSLocalizedDescriptionKey: "Empty response body"]))) }

            do {
                let dto = try JSONDecoder().decode(SaveScoreResponse.self, from: data)
                completion(.success(dto))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

}
