//
//  ProfileUseCase.swift
//  Domain
//
//  Created by 최정인 on 11/12/24.
//

import Foundation

public final class ProfileUseCase: ProfileUseCaseInterface {
    private let repository: ProfileRepositoryInterface

    public init(repository: ProfileRepositoryInterface) {
        self.repository = repository
    }

    public func loadProfile() -> Profile {
        return repository.loadProfile()
    }

    public func saveProfile(profile: Profile) {
        repository.saveProfile(profile: profile)
    }
}
