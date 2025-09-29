//
//  BestViewModel.swift
//  knights25
//
//  Created by Vadim on 18. 9. 2025..
//

// Modules/Best/BestViewModel.swift
import Foundation

final class BestViewModel {
    let userId: String?

    init(userId: String?) { self.userId = userId }

    // Builds: https://bashurov.net/knights25/api/best.php?uid=<userId>
    // (If your endpoint is http://, see Info.plist note below)
    var url: URL? {
        var comp = URLComponents()
        comp.scheme = "https"            // change to "http" if needed
        comp.host   = "bashurov.net"
        comp.path   = "/knights25/api/best.php"
        comp.queryItems = [ URLQueryItem(name: "uid", value: userId) ]
        return comp.url
    }
}
