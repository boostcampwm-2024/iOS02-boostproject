//
//  GameObject.swift
//  Domain
//
//  Created by 최정인 on 11/27/24.
//

import Foundation

public final class GameObject: WhiteboardObject {
    public let gameAnswer: String
    public var gameWinners: [GameWinner]

    private enum CodingKeys: String, CodingKey {
        case gameAnswer
        case gameWinners
    }

    public init(
        id: UUID,
        centerPosition: CGPoint,
        size: CGSize,
        scale: CGFloat = 1,
        angle: CGFloat = 0,
        gameAnswer: String,
        selectedBy: Profile? = nil
    ) {
        self.gameAnswer = gameAnswer
        self.gameWinners = []
        super.init(
            id: id,
            centerPosition: centerPosition,
            size: size,
            scale: scale,
            angle: angle,
            selectedBy: selectedBy)
    }

    required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let gameAnswer = try container.decode(String.self, forKey: .gameAnswer)
        let gameWinners = try container.decode([GameWinner].self, forKey: .gameWinners)
        self.gameAnswer = gameAnswer
        self.gameWinners = gameWinners
        try super.init(from: decoder)
    }

    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(gameAnswer, forKey: .gameAnswer)
        try container.encode(gameWinners, forKey: .gameWinners)
        try super.encode(to: encoder)
    }

    override func deepCopy() -> WhiteboardObject {
        return GameObject(
            id: id,
            centerPosition: centerPosition,
            size: size,
            scale: scale,
            angle: angle,
            gameAnswer: gameAnswer,
            selectedBy: selectedBy)
    }
}

public struct GameWinner: Codable {
    public let id: UUID
    public let nickname: String
    public let triedCount: Int
}
