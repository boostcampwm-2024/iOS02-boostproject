//
//  ProfileIcon.swift
//  Domain
//
//  Created by 최정인 on 11/12/24.
//

public struct ProfileIcon: Codable {
    public let emoji: String
    public let colorHex: String
}

extension ProfileIcon {
    public static let profileIcons: [ProfileIcon] = [
        ProfileIcon(emoji: "😇", colorHex: "FFE29A"),
        ProfileIcon(emoji: "🥰", colorHex: "FFCCBF"),
        ProfileIcon(emoji: "🥵", colorHex: "FFAE79"),
        ProfileIcon(emoji: "🤢", colorHex: "B8D888"),
        ProfileIcon(emoji: "😈", colorHex: "E2B4FF"),
        ProfileIcon(emoji: "👻", colorHex: "DAD9D7"),
        ProfileIcon(emoji: "🥶", colorHex: "9ACCFF"),
        ProfileIcon(emoji: "😶‍🌫️", colorHex: "E2F5FF"),
        ProfileIcon(emoji: "💩", colorHex: "BEA571")
    ]
}
