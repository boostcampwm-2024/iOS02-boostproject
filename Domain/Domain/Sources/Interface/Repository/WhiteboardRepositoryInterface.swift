//
//  WhiteboardRepository.swift
//  Domain
//
//  Created by 최다경 on 11/12/24.
//

public protocol WhiteboardRepositoryInterface {
    /// 주변에 내 기기를 참여자의 아이콘 정보와 함께 화이트보드를 알립니다.
    func startPublishing(with info: [Profile])
}
