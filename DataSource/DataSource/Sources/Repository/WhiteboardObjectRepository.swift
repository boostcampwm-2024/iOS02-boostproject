//
//  WhiteboardObjectRepository.swift
//  DataSource
//
//  Created by 박승찬 on 11/21/24.
//

import Domain
import OSLog

public final class WhiteboardObjectRepository: WhiteboardObjectRepositoryInterface {
    public weak var delegate: WhiteboardObjectRepositoryDelegate?
    private var nearbyNetwork: NearbyNetworkInterface
    private let filePersistence: FilePersistenceInterface
    private let logger = Logger()

    public init(nearbyNetwork: NearbyNetworkInterface, filePersistence: FilePersistenceInterface) {
        self.nearbyNetwork = nearbyNetwork
        self.filePersistence = filePersistence
        self.nearbyNetwork.receiptDelegate = self
    }

    public func send(whiteboardObject: WhiteboardObject, isDeleted: Bool) async {
        switch whiteboardObject {
        case let textObject as TextObject:
            await send(
                whiteboardObject: textObject,
                type: .text,
                isDeleted: isDeleted)
        case let drawingObject as DrawingObject:
            await send(
                whiteboardObject: drawingObject,
                type: .drawing,
                isDeleted: isDeleted)
        case let photoObject as PhotoObject:
            async let sendJPEGTask: () = sendJPEG(
                photoObject: photoObject,
                type: .jpg,
                isDeleted: isDeleted)
            async let sendPhotoObjectTask: () = send(
                whiteboardObject: photoObject,
                type: .photo,
                isDeleted: isDeleted)
            await sendJPEGTask
            await sendPhotoObjectTask
        default:
            break
        }
    }

    private func send(
        whiteboardObject: WhiteboardObject,
        type: AirplaINDataType,
        isDeleted: Bool
    ) async {
        let objectData = try? JSONEncoder().encode(whiteboardObject)
        let objectInformation = DataInformationDTO(
            id: whiteboardObject.id,
            type: type,
            isDeleted: isDeleted)
        guard let url = filePersistence
            .save(dataInfo: objectInformation, data: objectData, fileType: nil)
        else {
            logger.log(level: .error, "url저장 실패: 데이터를 보내지 못했습니다.")
            return
        }
        await nearbyNetwork.send(fileURL: url, info: objectInformation)
    }

    // TODO: - 사진 데이터를 photo Object와 따로 보내야함! 추후 전송 방식 개선하기
    private func sendJPEG(
        photoObject: PhotoObject,
        type: AirplaINDataType,
        isDeleted: Bool
    ) async {
        let dataInformation = DataInformationDTO(
            id: photoObject.id,
            type: .jpg,
            isDeleted: isDeleted)
        await nearbyNetwork.send(fileURL: photoObject.photoURL, info: dataInformation)
    }
}

extension WhiteboardObjectRepository: NearbyNetworkReceiptDelegate {
    public func nearbyNetwork(_ sender: any NearbyNetworkInterface, didReceive data: Data) {
        // TODO: 사용하지 않을 인터페이스로 예상
    }

    public func nearbyNetwork(
        _ sender: any NearbyNetworkInterface,
        didReceiveURL URL: URL,
        info: DataInformationDTO
    ) {
        if info.type != .jpg {
            handleWhiteboardObject(didReceiveURL: URL, info: info)
        } else {
            handlePhotoData(didReceiveURL: URL, info: info)
        }
    }

    private func handlePhotoData(didReceiveURL URL: URL, info: DataInformationDTO) {
        guard let receiveData = filePersistence.load(path: URL) else { return }
        guard let savedURL = filePersistence.save(dataInfo: info, data: receiveData, fileType: ".jpg") else { return }

        if !info.isDeleted {
            delegate?.whiteboardObjectRepository(
                self,
                didReceive: info.id,
                savedURL: savedURL)
        }
    }

    private func handleWhiteboardObject(didReceiveURL URL: URL, info: DataInformationDTO) {
        guard let receiveData = filePersistence.load(path: URL) else { return }

        filePersistence.save(dataInfo: info, data: receiveData, fileType: nil)
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
        default:
            WhiteboardObject.self
        }
    }
}
