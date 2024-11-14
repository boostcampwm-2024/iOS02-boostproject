//
//  ProfileRepository.swift
//  DataSource
//
//  Created by 최정인 on 11/12/24.
//

import Domain

public final class ProfileRepository: ProfileRepositoryInterface {
    private let persistenceService: PersistenceInterface
    private let profileKey = "AirplainProfile"

    public init(persistenceService: PersistenceInterface) {
        self.persistenceService = persistenceService
    }

    public func loadProfile() -> Profile {
        if let profile: Profile = persistenceService.load(forKey: profileKey) {
            return profile
        } else {
            let randomProfile = Profile(
                nickname: Profile.randomNickname(),
                profileIcon: ProfileIcon.profileIcons.randomElement() ?? ProfileIcon.profileIcons[0])
            saveProfile(profile: randomProfile)
            return randomProfile
        }
    }

    public func saveProfile(profile: Profile) {
        persistenceService.save(data: profile, forKey: profileKey)
    }
}
