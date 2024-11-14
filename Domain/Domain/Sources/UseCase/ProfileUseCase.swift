//
//  ProfileUseCase.swift
//  Domain
//
//  Created by 최정인 on 11/12/24.
//

import Foundation

public final class ProfileUseCase: ProfileUseCaseInterface {
    var profileRepository: ProfileRepositoryInterface

    public init(profileRepository: ProfileRepositoryInterface) {
        self.profileRepository = profileRepository
    }

    public func loadProfile() -> Profile {
        return profileRepository.loadProfile()
    }

    public func saveProfile(profile: Profile) {
        profileRepository.saveProfile(profile: profile)
    }
}
