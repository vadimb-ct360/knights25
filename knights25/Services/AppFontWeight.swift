//
//  AppFontWeight.swift
//  knights25
//
//  Created by Vadim Bashurov on 24.09.2025.
//


import UIKit

enum AppFontWeight {
    case light, regular, medium, semibold, bold, extrabold, black
}

enum AppFont {
    static func font(_ size: CGFloat, weight: AppFontWeight = .regular) -> UIFont {
        let name: String
        switch weight {
        case .light:     name = "AlanSans-Light"
        case .regular:   name = "AlanSans-Regular"
        case .medium:    name = "AlanSans-Medium"
        case .semibold:  name = "AlanSans-SemiBold"
        case .bold:      name = "AlanSans-Bold"
        case .extrabold: name = "AlanSans-ExtraBold"
        case .black:     name = "AlanSans-Black"
        }
        return UIFont(name: name, size: size) ?? .systemFont(ofSize: size)
    }

    // Dynamic Type–aware
    static func scaled(_ size: CGFloat,
                       weight: AppFontWeight = .regular,
                       textStyle: UIFont.TextStyle = .body) -> UIFont {
        let base = font(size, weight: weight)
        return UIFontMetrics(forTextStyle: textStyle).scaledFont(for: base)
    }

    // Debug check (call once at startup if you like)
    static func assertLoaded() {
        precondition(UIFont(name: "AlanSans-Regular", size: 10) != nil,
                     "AlanSans-Regular not found. Check UIAppFonts & target membership.")
    }
}
