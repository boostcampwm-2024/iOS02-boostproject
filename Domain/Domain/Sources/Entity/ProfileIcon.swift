//
//  ProfileIcon.swift
//  Domain
//
//  Created by 최정인 on 11/12/24.
//

public enum ProfileIcon: String, CaseIterable, Codable {
    case angel = "😇"
    case heart = "🥰"
    case hot = "🥵"
    case sick = "🤢"
    case devil = "😈"
    case ghost = "👻"
    case cold = "🥶"
    case foggy = "😶‍🌫️"
    case poop = "💩"

    public var emoji: String {
        self.rawValue
    }

    public var colorHex: String {
        switch self {
        case .angel: return "FFE29A"
        case .heart: return "FFCCBF"
        case .hot: return "FFAE79"
        case .sick: return "B8D888"
        case .devil: return "E2B4FF"
        case .ghost: return "DAD9D7"
        case .cold: return "9ACCFF"
        case .foggy: return "E2F5FF"
        case .poop: return "BEA571"
        }
    }
}
