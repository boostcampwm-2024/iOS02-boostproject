//
//  MCSessionState+.swift
//  NearbyNetwork
//
//  Created by 이동현 on 11/20/24.
//

import MultipeerConnectivity

extension MCSessionState {
    var description: String {
        switch self {
        case .notConnected:
            return "연결 끊김"
        case .connecting:
            return "연결 중"
        case .connected:
            return "연결 됨"
        @unknown default:
            return "알 수 없음"
        }
    }
}
