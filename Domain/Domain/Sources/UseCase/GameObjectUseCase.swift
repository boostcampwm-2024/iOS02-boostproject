//
//  GameObjectUseCase.swift
//  Domain
//
//  Created by 최정인 on 11/27/24.
//

import Foundation

public final class GameObjectUseCase: GameObjectUseCaseInterface {
    private let repository: GameRepositoryInterface
    private let defaultGameSize = CGSize(width: 120, height: 50)

    public init(repository: GameRepositoryInterface) {
        self.repository = repository
    }

    public func createGame(centerPoint point: CGPoint) -> GameObject {
        let gameAnswer = repository.randomGameAnswer()
        return GameObject(
            id: UUID(),
            centerPosition: point,
            size: defaultGameSize,
            gameAnswer: gameAnswer)
    }
}
