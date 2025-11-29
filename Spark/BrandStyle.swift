//
//  BrandStyle.swift
//  Spark
//
//  Shared brand colors and fonts
//

// A skeleton starter code for this page was AI generated

import SwiftUI

extension Color {
    static let brandDominant = Color("dominant")
    static let brandAccent = Color("accent")
    static let brandSecondary = Color("secondary")
    static let brandCard = Color("card")
}

enum SparkFont {
    static func ui(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight, design: .default)
    }
    static func logo(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight, design: .serif)
    }
}

enum BrandStyle {
    // Use asset colors if available, otherwise fallback to system colors
    static var background: Color {
        if UIColor(named: "background") != nil {
            return Color("background")
        }
        return Color(uiColor: .systemBackground)
    }
    
    static var card: Color {
        if UIColor(named: "card") != nil {
            return Color("card")
        }
        return Color.white
    }
    
    static let primary = Color.brandDominant
    static let accent = Color.brandAccent
    static let secondary = Color.brandSecondary
    
    static var textPrimary: Color {
        if UIColor(named: "textPrimary") != nil {
            return Color("textPrimary")
        }
        return Color.primary
    }
    
    static var textSecondary: Color {
        if UIColor(named: "textSecondary") != nil {
            return Color("textSecondary")
        }
        return Color.secondary
    }

    // Fonts
    static let title = SparkFont.ui(22, weight: .semibold)
    static let body = SparkFont.ui(16)
    static let caption = SparkFont.ui(13)
    static let button = SparkFont.ui(17, weight: .medium)
    static let sectionTitle = SparkFont.ui(19, weight: .semibold)
}

extension Notification.Name {
    static let resetCreateFlow = Notification.Name("resetCreateFlow")
    static let switchToHomeTab = Notification.Name("switchToHomeTab")
}
