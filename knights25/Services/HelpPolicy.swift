//
//  HelpPolicy.swift
//  knights25
//
//  Created by Vadim on 18. 9. 2025..
//

import Foundation


// Services/HelpPolicy.swift
protocol HelpPolicy {
    func shouldShowHelp(afterReturningToPlayFrom source: String) -> Bool
    func markHelpShown()
}

final class DefaultHelpPolicy: HelpPolicy {
    private let key = "helpShown"
    func shouldShowHelp(afterReturningToPlayFrom source: String) -> Bool {
        !UserDefaults.standard.bool(forKey: key)
    }
    func markHelpShown() {
        UserDefaults.standard.set(true, forKey: key)
    }
}
