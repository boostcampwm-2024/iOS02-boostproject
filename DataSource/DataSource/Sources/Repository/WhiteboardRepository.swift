//
//  DefaultWhiteboardRepository.swift
//  DataSource
//
//  Created by 최다경 on 11/12/24.
//

import Combine
import Domain
import Foundation

public final class WhiteboardRepository: WhiteboardRepositoryInterface {
    public weak var delegate: WhiteboardRepositoryDelegate?
    private var nearbyNetwork: NearbyNetworkInterface
    private let filePersistence: FilePersistenceInterface
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private var cancellables: Set<AnyCancellable>

    public init(
        nearbyNetworkInterface: NearbyNetworkInterface,
        filePersistence: FilePersistenceInterface
    ) {
        self.nearbyNetwork = nearbyNetworkInterface
        self.filePersistence = filePersistence
        cancellables = []
        self.nearbyNetwork.connectionDelegate = self
    }

    public func republish(whiteboard: Whiteboard) {
        nearbyNetwork.stopPublishing()
        nearbyNetwork.startPublishing(
            with: whiteboard.name,
            connectedPeerInfo: whiteboard
                .participantIcons
                .map { $0.emoji })
    }

    public func send(whiteboardObject: WhiteboardObject, isDeleted: Bool) async -> Bool {
        guard
            let dto = convertToDTO(whiteboardObject: whiteboardObject, isDeleted: isDeleted)
        else { return false }
        return await nearbyNetwork.send(data: dto)
    }

    public func send(whiteboardObjects: [WhiteboardObject], to profile: Profile) async -> Bool {
        let connection = RefactoredNetworkConnection(
            id: profile.id,
            name: profile.nickname,
            connectedPeerInfo: [profile.profileIcon.emoji])

        let result = await withTaskGroup(of: Bool.self, returning: Bool.self) { taskGroup in
            whiteboardObjects.forEach { object in
                guard let dto = convertToDTO(whiteboardObject: object, isDeleted: false)
                else { return }
                taskGroup.addTask {
                    return await self.nearbyNetwork.send(data: dto, to: connection)
                }
            }
            for await childResult in taskGroup {
                if !childResult { return false }
            }
            return true
        }
        return result
    }

    public func disconnectWhiteboard() {
        nearbyNetwork.disconnectAll()
        nearbyNetwork.stopPublishing()
    }

    private func convertToDTO(
        whiteboardObject: WhiteboardObject,
        isDeleted: Bool
    ) -> AirplaINDataDTO? {
        let type: AirplaINDataType?
        switch whiteboardObject {
        case is TextObject:
            type = .text
        case is DrawingObject:
            type = .drawing
        case is PhotoObject:
            type = .photo
        case is GameObject:
            type = .game
        default:
            type = nil
        }

        guard
            let objectData = try? encoder.encode(whiteboardObject),
            let type
        else { return nil }

        let dto = AirplaINDataDTO(
            id: whiteboardObject.id,
            data: objectData,
            type: type,
            isDeleted: isDeleted)
        return dto
    }

    private func bind() {
        nearbyNetwork
            .reciptDataPublisher
            .sink { [weak self] dto in
                guard let self else { return }

                switch dto.type {
                case .text, .photo, .drawing, .game:
                    guard
                        let whiteboardObject = try? decoder.decode(dto.type.decodableType, from: dto.data)
                    else { return }
                    if dto.isDeleted {
                        self.delegate?.whiteboardRepository(self, didDelete: whiteboardObject)
                    } else {
                        self.delegate?.whiteboardRepository(self, didReceive: whiteboardObject)
                    }
                case .imageData:
                    self.handlePhotoData(dto: dto)
                default:
                    break
                }
            }
            .store(in: &cancellables)
    }

    private func handlePhotoData(dto: AirplaINDataDTO) {
        guard
            let savedURL = filePersistence.save(dto: dto)
        else { return }

        if !dto.isDeleted {
            delegate?.whiteboardRepository(
                self,
                didReceive: dto.id,
                savedURL: savedURL)
        }
    }
}

extension WhiteboardRepository: NearbyNetworkConnectionDelegate {
    public func nearbyNetwork(
        _ sender: NearbyNetworkInterface,
        didConnect connection: RefactoredNetworkConnection
    ) {
        guard let icon = connection
            .connectedPeerInfo
            .compactMap({ ProfileIcon(rawValue: $0) })
            .first
        else { return }

        let profile = Profile(
            id: connection.id,
            nickname: connection.name,
            profileIcon: icon)
        delegate?.whiteboardRepository(self, newPeer: profile)
    }
    
    public func nearbyNetwork(
        _ sender: NearbyNetworkInterface,
        didDisconnect connection: RefactoredNetworkConnection
    ) {
        guard let icon = connection
            .connectedPeerInfo
            .compactMap({ ProfileIcon(rawValue: $0) })
            .first
        else { return }

        let profile = Profile(
            id: connection.id,
            nickname: connection.name,
            profileIcon: icon)
        delegate?.whiteboardRepository(self, lostPeer: profile)
    }
}

fileprivate extension AirplaINDataType {
    var decodableType: WhiteboardObject.Type {
        switch self {
        case .text:
            TextObject.self
        case .photo:
            PhotoObject.self
        case .drawing:
            DrawingObject.self
        case .game:
            GameObject.self
        default:
            WhiteboardObject.self
        }
    }
}
