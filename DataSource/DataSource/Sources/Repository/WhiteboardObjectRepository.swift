//
//  WhiteboardObjectRepository.swift
//  DataSource
//
//  Created by 박승찬 on 11/21/24.
//

import Combine
import Domain
import OSLog

public final class WhiteboardObjectRepository: WhiteboardObjectRepositoryInterface {
    public weak var delegate: WhiteboardObjectRepositoryDelegate?
    private var nearbyNetwork: NearbyNetworkInterface
    private let filePersistence: FilePersistenceInterface
    private var cancellables: Set<AnyCancellable>
    private let logger = Logger()

    public init(nearbyNetwork: NearbyNetworkInterface, filePersistence: FilePersistenceInterface) {
        self.nearbyNetwork = nearbyNetwork
        self.filePersistence = filePersistence
        cancellables = []
        bindNearbyNetwork()
    }

    public func send(
        whiteboardObject: Domain.WhiteboardObject,
        isDeleted: Bool,
        to profile: Profile
    ) async {
        await send(
            whiteboardObject: whiteboardObject,
            isDeleted: isDeleted,
            profile: profile)
    }

    public func send(whiteboardObject: WhiteboardObject, isDeleted: Bool) async {
        await send(
            whiteboardObject: whiteboardObject,
            isDeleted: isDeleted,
            profile: nil)
    }

    public func send(
        whiteboardObjects: [WhiteboardObject],
        isDeleted: Bool,
        to profile: Profile
    ) async {
        await withTaskGroup(of: Void.self) { taskGroup in
            whiteboardObjects.forEach { object in
                taskGroup.addTask {
                    await self.send(
                        whiteboardObject: object,
                        isDeleted: isDeleted,
                        profile: profile)
                }
            }
        }
    }

    private func send(
        whiteboardObject: WhiteboardObject,
        isDeleted: Bool,
        profile: Profile?
    ) async {
        let type: AirplaINDataType?
        let objectData = try? JSONEncoder().encode(whiteboardObject)

        switch whiteboardObject {
        case _ as TextObject:
            type = .text
        case _ as DrawingObject:
            type = .drawing
        case let photoObject as PhotoObject:
            await sendJPEG(
                photoID: photoObject.id,
                isDeleted: isDeleted,
                to: profile)
            type = .photo
        case _ as GameObject:
            type = .game
        default:
            type = nil
        }

        guard let type else { return }

        let objectInformation = DataInformationDTO(
            id: whiteboardObject.id,
            type: type,
            isDeleted: isDeleted)

        guard let url = filePersistence
            .save(dataInfo: objectInformation, data: objectData)
        else {
            logger.log(level: .error, "url저장 실패: 데이터를 보내지 못했습니다.")
            return
        }

        if let profile {
            let connection = NetworkConnection(
                id: profile.id,
                name: profile.nickname,
                info: [:])
            await nearbyNetwork.send(
                fileURL: url,
                info: objectInformation,
                to: connection)
        } else {
            await nearbyNetwork.send(fileURL: url, info: objectInformation)
        }
    }

    // TODO: - 사진 데이터를 photo Object와 따로 보내야함! 추후 전송 방식 개선하기
    private func sendJPEG(
        photoID: UUID,
        isDeleted: Bool,
        to profile: Profile?
    ) async {
        let dataInformation = DataInformationDTO(
            id: photoID,
            type: .imageData,
            isDeleted: isDeleted)

        guard let photoURL = filePersistence.fetchURL(dataInfo: dataInformation) else { return }

        if let profile {
            let connection = NetworkConnection(
                id: profile.id,
                name: profile.nickname,
                info: [:])
            await nearbyNetwork.send(
                fileURL: photoURL,
                info: dataInformation,
                to: connection)
        } else {
            await nearbyNetwork.send(fileURL: photoURL, info: dataInformation)
        }
    }

    private func bindNearbyNetwork() {
        nearbyNetwork.reciptURLPublisher
            .sink { [weak self] url, dataInfo in
                switch dataInfo.type {
                case .imageData:
                    self?.handlePhotoData(didReceiveURL: url, info: dataInfo)
                case .chat, .whiteboard:
                    break
                default:
                    self?.handleWhiteboardObject(didReceiveURL: url, info: dataInfo)
                }
            }
            .store(in: &cancellables)
    }

    private func handlePhotoData(didReceiveURL URL: URL, info: DataInformationDTO) {
        guard
            let receiveData = filePersistence.load(path: URL),
            let savedURL = filePersistence.save(dataInfo: info, data: receiveData)
        else { return }

        if !info.isDeleted {
            delegate?.whiteboardObjectRepository(
                self,
                didReceive: info.id,
                savedURL: savedURL)
        }
    }

    private func handleWhiteboardObject(didReceiveURL URL: URL, info: DataInformationDTO) {
        guard let receiveData = filePersistence.load(path: URL) else { return }

        filePersistence.save(dataInfo: info, data: receiveData)
        guard let whiteboardObject = try? JSONDecoder().decode(
            info.type.decodableType,
            from: receiveData)
        else {
            logger.log(level: .error, "WhiteboardObjectRepository: 전달받은 데이터 디코딩 실패")
            return
        }

        if info.isDeleted {
            delegate?.whiteboardObjectRepository(self, didDelete: whiteboardObject)
        } else {
            delegate?.whiteboardObjectRepository(self, didReceive: whiteboardObject)
        }
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
