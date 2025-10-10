//
//  BestViewModel.swift
//  knights25
//
//  Created by Vadim on 18. 9. 2025..
//

import Foundation

final class BestViewModel {
    let userId: String?
    
    init(userId: String?) { self.userId = userId }
    
    var url: URL? {
        var comp = URLComponents()
        comp.scheme = "https"
        comp.host   = "bashurov.net"
        comp.path   = "/knights25/api/best.php"
        comp.queryItems = [ URLQueryItem(name: "uid", value: userId) ]
        return comp.url
    }
}
