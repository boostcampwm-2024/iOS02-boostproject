//
//  ProfileViewModel.swift
//  Presentation
//
//  Created by 최정인 on 11/13/24.
//

import Combine
import Domain
import Foundation

public final class ProfileViewModel: ViewModel {
    enum Input {
        case updateProfileNickname(nickname: String)
        case updateProfileIcon(profileIcon: ProfileIcon)
        case saveProfile
        case resetProfile
    }

    struct Output {
        let profilePublisher: AnyPublisher<Profile, Never>
    }

    private let profileUseCase: ProfileUseCase
    private let profileSubject: CurrentValueSubject<Profile, Never>
    let output: Output

    public init(profileUseCase: ProfileUseCase) {
        self.profileUseCase = profileUseCase
        let profile = profileUseCase.loadProfile()
        profileSubject = CurrentValueSubject<Profile, Never>(profile)
        self.output = Output(profilePublisher: profileSubject.eraseToAnyPublisher())
    }

    func action(input: Input) {
        switch input {
        case .updateProfileNickname(let nickname):
            updateProfileNickname(nickname: nickname)
        case .updateProfileIcon(let profileIcon):
            updateProfileIcon(profileIcon: profileIcon)
        case .saveProfile:
            saveProfile()
        case .resetProfile:
            resetProfile()
        }
    }

    private func updateProfileNickname(nickname: String) {
        let profile = Profile(nickname: nickname, profileIcon: profileSubject.value.profileIcon)
        profileSubject.send(profile)
    }

    private func updateProfileIcon(profileIcon: ProfileIcon) {
        let profile = Profile(nickname: profileSubject.value.nickname, profileIcon: profileIcon)
        profileSubject.send(profile)
    }

    private func saveProfile() {
        profileUseCase.saveProfile(profile: profileSubject.value)
    }

    private func resetProfile() {
        profileSubject.value = profileUseCase.loadProfile()
    }
}
