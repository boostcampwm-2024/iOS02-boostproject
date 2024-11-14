//
//  ProfileRepositoryInterface.swift
//  Domain
//
//  Created by 최정인 on 11/12/24.
//

public protocol ProfileRepositoryInterface {
    /// 프로필 정보를 가져옵니다.
    /// - Returns: 가져온 프로필 정보
    func loadProfile() -> Profile

    /// 프로필 정보를 저장합니다.
    /// - Parameter profile: 저장할 프로필 정보
    func saveProfile(profile: Profile)
}
