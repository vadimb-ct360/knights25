// Services/UserService.swift


import Foundation

struct UserBootstrap: Decodable {
    let userId: Int
    let userName: String?
    var bestTotalScore: String
    var bestTodayScore: String
    var bestLevelScore: String   // best for Level 1 (per your API)
}

protocol UserService {
    func fetchUser(uid: String?, completion: @escaping (Result<UserBootstrap, Error>) -> Void)
}

final class DefaultUserService: UserService {
    func fetchUser(uid: String?, completion: @escaping (Result<UserBootstrap, Error>) -> Void) {
        var comps = URLComponents()
        comps.scheme = "https"
        comps.host   = "bashurov.net"
        comps.path   = "/knights25/api/user.php"
        comps.queryItems = [
            .init(name: "userid", value: uid),
            .init(name: "platform",  value: "iPhone"),
        ]
        guard let url = comps.url else {
            return completion(.failure(NSError(domain:"UserService", code:-1,
                                               userInfo:[NSLocalizedDescriptionKey:"Bad URL"])))
        }
        
        var req = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 15)
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        
        URLSession.shared.dataTask(with: req) { data, resp, err in
            if let err = err { return completion(.failure(err)) }
            guard let http = resp as? HTTPURLResponse, (200...299).contains(http.statusCode),
                  let data = data, !data.isEmpty else {
                return completion(.failure(NSError(domain:"UserService", code:-2,
                                                   userInfo:[NSLocalizedDescriptionKey:"Bad HTTP/empty body"])))
            }
            do {
                let dto = try JSONDecoder().decode(UserBootstrap.self, from: data)
                completion(.success(dto))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
