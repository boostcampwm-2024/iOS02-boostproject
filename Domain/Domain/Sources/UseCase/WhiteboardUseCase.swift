//
//  WhiteboardUseCase.swift
//  Domain
//
//  Created by 최다경 on 11/12/24.
//

public final class WhiteboardUseCase: WhiteboardUseCaseInterface {
    private let repository: WhiteboardRepositoryInterface
    private var participantsInfo: [String] = []

    public init(repository: WhiteboardRepositoryInterface, profile: Profile) {
        self.repository = repository
        participantsInfo.append(profile.profileIcon.emoji)
    }

    public func createWhiteboard(nickname: String) -> Whiteboard {
        return Whiteboard(name: nickname)
    }

    public func startPublishingWhiteboard() {
        repository.startPublishing(with: participantsInfo)
    }
}
