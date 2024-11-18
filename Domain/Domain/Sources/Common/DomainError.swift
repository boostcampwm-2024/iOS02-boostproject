//
//  DomainError.swift
//  Domain
//
//  Created by 이동현 on 11/18/24.
//

import Foundation

public enum DomainError {
    case cannotWriteFile
    case cannotCreateDirectory
    case cannotFindDirectory
}

extension DomainError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .cannotWriteFile:
            return "파일을 쓸 수 없습니다."
        case .cannotCreateDirectory:
            return "디렉터리를 생성할 수 없습니다."
        case .cannotFindDirectory:
            return "디렉터리를 찾을 수 없습니다."
        }
    }
}
