//
//  ProfileViewModel.swift
//  Presentation
//
//  Created by 최정인 on 11/13/24.
//

import Combine
import Domain
import Foundation

final class ProfileViewModel {
    enum Input {
        case updateProfile(profile: Profile)
        case saveProfile
    }

    struct Output {
        let profile: CurrentValueSubject<Profile, Never>
    }

    private let profileUseCase: ProfileUseCase
    private(set) var output: Output

    init(profileUseCase: ProfileUseCase) {
        self.profileUseCase = profileUseCase
        let profile = profileUseCase.loadProfile()
        self.output = Output(profile: CurrentValueSubject<Profile, Never>(profile))
    }

    func action(input: Input) {
        switch input {
        case .updateProfile(let profile): updateProfile(profile: profile)
        case .saveProfile: saveProfile()
        }
    }

    private func updateProfile(profile: Profile) {
        output.profile.send(profile)
    }

    private func saveProfile() {
        profileUseCase.saveProfile(profile: output.profile.value)
    }
}
