//
//  ProfileUseCase.swift
//  Domain
//
//  Created by 최정인 on 11/12/24.
//

import Foundation

public final class ProfileUseCase {
    private let profileRepository: ProfileRepository

    public init(profileRepository: ProfileRepository) {
        self.profileRepository = profileRepository
    }

    public func loadProfile() -> Profile {
        return profileRepository.loadProfile()
    }

    public func saveProfile(profile: Profile) {
        profileRepository.saveProfile(profile: profile)
    }
}
