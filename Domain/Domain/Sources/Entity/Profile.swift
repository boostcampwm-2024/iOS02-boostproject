//
//  Profile.swift
//  Domain
//
//  Created by 최정인 on 11/12/24.
//

public struct Profile: Codable {
    public var nickname: String
    public let profileIcon: ProfileIcon

    public init(nickname: String, profileIcon: ProfileIcon) {
        self.nickname = nickname
        self.profileIcon = profileIcon
    }
}

extension Profile {
    static let adjectives = ["날쌘", "용감한", "귀여운", "활발한", "영리한", "씩씩한", "똑똑한", "빠른", "당찬", "호기심 많은"]
    static let animals = ["여우", "늑대", "토끼", "사자", "다람쥐", "독수리", "곰돌이", "호랑이", "표범", "고양이", "올빼미", "펭귄", "부엉이", "두더지", "물개", "강아지"]
    public static func randomNickname() -> String {
        return "\(adjectives.randomElement() ?? "용감한") \(animals.randomElement() ?? "강아지")"
    }
}
