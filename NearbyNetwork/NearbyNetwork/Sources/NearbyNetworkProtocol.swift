//
//  NearbyNetworkProtocol.swift
//  NearbyNetwork
//
//  Created by 이동현 on 1/3/25.
//

import Foundation
import Network

enum NearbyNetworkMessageType: UInt32 {
    case invalid = 0
    case peerInfo = 1
    case data = 2
}

class NearbyNetworkProtocol: NWProtocolFramerImplementation {
    static let definition = NWProtocolFramer.Definition(implementation: NearbyNetworkProtocol.self)
    static var label: String { return "NearbyNetworkProtocol" }

    // 가장 기본적인 framing protocol 형식
    required init(framer: NWProtocolFramer.Instance) { }
    func start(framer: NWProtocolFramer.Instance) -> NWProtocolFramer.StartResult { return .ready }
    func wakeup(framer: NWProtocolFramer.Instance) { }
    func stop(framer: NWProtocolFramer.Instance) -> Bool { return true }
    func cleanup(framer: NWProtocolFramer.Instance) { }

    func handleOutput(
        framer: NWProtocolFramer.Instance,
        message: NWProtocolFramer.Message,
        messageLength: Int,
        isComplete: Bool
    ) {
        // 메시지 타입(유효한지, 하지 않은지)와 peerInfo를 추출합니다.
        let type = message.nearbyNetworkMessageType

        // 타입과 length, peerInfo를 가지고 헤더를 생성합니다.
        let header = NearbyNetworkProtocolHeader(type: type.rawValue, length: UInt32(messageLength))

        // framer에 헤더를 넣어줍니다.
        framer.writeOutput(data: header.encodedData)

        // 헤더 뒤 메시지를 넣어줍니다.
        try? framer.writeOutputNoCopy(length: messageLength)
    }

    func handleInput(framer: NWProtocolFramer.Instance) -> Int {
        while true {
            // 헤더 읽기
            var tempHeader: NearbyNetworkProtocolHeader? = nil
            let headerSize = NearbyNetworkProtocolHeader.encodedSize

            let parsed = framer.parseInput(
                minimumIncompleteLength: headerSize,
                maximumLength: headerSize
            ) { (buffer, _) -> Int in
                guard
                    let buffer = buffer,
                    buffer.count >= headerSize
                else { return 0 }

                tempHeader = NearbyNetworkProtocolHeader(buffer)

                return headerSize
            }

            guard
                parsed,
                let header = tempHeader
            else { return headerSize }

            // 수신된 메시지 만들기
            var messageType = NearbyNetworkMessageType.invalid
            if let parsedMessageType = NearbyNetworkMessageType(rawValue: header.type) {
                messageType = parsedMessageType
            }

            let message = NWProtocolFramer.Message(nearbyNetworkMessageType: messageType)

            if !framer.deliverInputNoCopy(length: Int(header.length), message: message, isComplete: true) {
                return 0
            }
        }
    }
}

// Message metadata를 쉽게 관리하기 위해 기능 확장
extension NWProtocolFramer.Message {
    convenience init(nearbyNetworkMessageType: NearbyNetworkMessageType) {
        self.init(definition: NearbyNetworkProtocol.definition)
        self["NearbyNetworkMessageType"] = nearbyNetworkMessageType
    }

    var nearbyNetworkMessageType: NearbyNetworkMessageType {
        guard let type = self["NearbyNetworkMessageType"] as? NearbyNetworkMessageType
        else { return .invalid }

        return type
    }
}

struct NearbyNetworkProtocolHeader: Codable {
    let type: UInt32
    let length: UInt32

    init(_ buffer: UnsafeMutableRawBufferPointer) {
        var tempType: UInt32 = 0
        var tempLength: UInt32 = 0

        withUnsafeMutableBytes(of: &tempType) { typePtr in
            typePtr.copyMemory(from: UnsafeRawBufferPointer(
                start: buffer.baseAddress!.advanced(by: 0),
                count: MemoryLayout<UInt32>.size))
        }
        withUnsafeMutableBytes(of: &tempLength) { lengthPtr in
            lengthPtr.copyMemory(from: UnsafeRawBufferPointer(
                start: buffer.baseAddress!.advanced(by: MemoryLayout<UInt32>.size),
                count: MemoryLayout<UInt32>.size))
        }

        type = tempType
        length = tempLength
    }

    init(type: UInt32, length: UInt32) {
        self.type = type
        self.length = length
    }

    var encodedData: Data {
        var tempType = type
        var tempLength = length
        var data = Data(bytes: &tempType, count: MemoryLayout<UInt32>.size)
        data.append(Data(bytes: &tempLength, count: MemoryLayout<UInt32>.size))
        return data
    }

    static var encodedSize: Int {
        return MemoryLayout<UInt32>.size * 2
    }
}
