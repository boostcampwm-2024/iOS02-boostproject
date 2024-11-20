//
//  MCSession+.swift
//  NearbyNetwork
//
//  Created by 이동현 on 11/20/24.
//

import MultipeerConnectivity

// MARK: - Swift Concurrency로 wrapping
extension MCSession {
    func sendResource(
        at resourceURL: URL,
        withName resourceName: String,
        toPeer peer: MCPeerID
    ) async throws {
        typealias Continuation = CheckedContinuation<Void, Error>

        try await withCheckedThrowingContinuation { (continuation: Continuation) in
            self.sendResource(
                at: resourceURL,
                withName: resourceName,
                toPeer: peer
            ) { error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }
    }
}
