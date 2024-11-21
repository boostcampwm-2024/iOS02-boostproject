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

    public func send(whiteboardObject: WhiteboardObject) async {
        switch whiteboardObject {
        case let textObject as TextObject:
            await send(whiteboardObject: textObject, type: .text)
        case let drawingObject as DrawingObject:
            await send(whiteboardObject: drawingObject, type: .drawing)
        case let photoObject as PhotoObject:
            await send(whiteboardObject: photoObject, type: .photo)
        default:
            break
        }
    }

    public func delete(whiteboardObject: WhiteboardObject) {
//        <#code#>
    }

    private func send(whiteboardObject: WhiteboardObject, type: AirplaINDataType) async {
        let objectData = try? JSONEncoder().encode(whiteboardObject)
        let objectInformation = DataInformationDTO(id: whiteboardObject.id, type: type)
        guard let url = filePersistence
            .save(dataInfo: objectInformation, data: objectData)
        else {
            logger.log(level: .error, "url저장 실패: 데이터를 보내지 못했습니다.")
            return
        }
        await nearbyNetwork.send(fileURL: url, info: objectInformation)
    }
}

extension WhiteboardObjectRepository: NearbyNetworkReceiptDelegate {
    public func nearbyNetwork(_ sender: any NearbyNetworkInterface, didReceive data: Data) {
//        <#code#>
    }
    
    public func nearbyNetwork(_ sender: any NearbyNetworkInterface, didReceiveURL URL: URL, info: DataInformationDTO) {
//        <#code#>
    }
}
