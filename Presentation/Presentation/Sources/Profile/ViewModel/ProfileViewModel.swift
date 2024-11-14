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
        let profilePublisher: AnyPublisher<Profile, Never>
    }

    private let profileUseCase: ProfileUseCase
    private(set) var output: Output
    let profileSubject: CurrentValueSubject<Profile, Never>

    init(profileUseCase: ProfileUseCase) {
        self.profileUseCase = profileUseCase
        let profile = profileUseCase.loadProfile()
        profileSubject = CurrentValueSubject<Profile, Never>(profile)
        self.output = Output(profilePublisher: profileSubject.eraseToAnyPublisher())
    }

    func action(input: Input) {
        switch input {
        case .updateProfile(let profile): updateProfile(profile: profile)
        case .saveProfile: saveProfile()
        }
    }

    private func updateProfile(profile: Profile) {
        profileSubject.send(profile)
    }

    private func saveProfile() {
        profileUseCase.saveProfile(profile: profileSubject.value)
    }
}
