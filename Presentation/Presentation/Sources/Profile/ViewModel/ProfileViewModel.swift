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
        case updateProfileNickname(nickname: String)
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
        case .updateProfileNickname(let nickname): updateProfileNickname(nickname: nickname)
        case .saveProfile: saveProfile()
        }
    }

    private func updateProfileNickname(nickname: String) {
        let updatedProfile = Profile(nickname: nickname, profileIcon: output.profile.value.profileIcon)
        output.profile.send(updatedProfile)
    }

    private func saveProfile() {
        profileUseCase.saveProfile(profile: output.profile.value)
    }
}
