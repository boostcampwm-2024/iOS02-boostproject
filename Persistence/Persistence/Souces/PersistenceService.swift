//
//  PersistenceService.swift
//  Persistence
//
//  Created by 최정인 on 11/12/24.
//

import DataSource
import Foundation

public final class PersistenceService: PersistenceInterface {
    private let userDefaults = UserDefaults.standard

    public init() {}

    public func save<T: Codable>(data: T, forKey key: String) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(data) {
            userDefaults.set(encoded, forKey: key)
        }
    }

    public func load<T: Codable>(forKey key: String) -> T? {
        guard let data = userDefaults.data(forKey: key) else { return nil }
        let decoder = JSONDecoder()
        guard let decoded = try? decoder.decode(T.self, from: data) else { return nil }
        return decoded
    }
}
