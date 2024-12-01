//
//  AddPhotoUseCaseTests.swift
//  DomainTests
//
//  Created by 이동현 on 11/18/24.
//

import Domain
import XCTest

final class MockPhotoRepository: PhotoRepositoryInterface {
    func fetchPhoto(id: UUID) -> Data? {
        return Data()
    }

    func savePhoto(id: UUID, imageData: Data) -> URL? {
        return URL(filePath: "photo.jpg")
    }
}

final class AddPhotoUseCaseTests: XCTestCase {
    private var useCase: PhotoUseCase!

    override func setUp() {
        super.setUp()
        let mockPhotoRepository = MockPhotoRepository()
        useCase =  PhotoUseCase(photoRepository: mockPhotoRepository)
    }

    override func tearDown() {
        useCase = nil
        super.tearDown()
    }

    // 사진 객체 생성 성공 테스트
    func testAddPhotoSuccess() throws {
        // 준비
        let dummyImageData = Data()
        let position = CGPoint(x: 100, y: 100)
        let size = CGSize(width: 200, height: 200)
        let photoObject: PhotoObject?

        // 실행
        photoObject = useCase.addPhoto(
            imageData: dummyImageData,
            centerPosition: position,
            size: size)

        // 검증
        XCTAssertNotNil(photoObject)
        guard let photoObject else { return }
        XCTAssertEqual(photoObject.centerPosition, position)
        XCTAssertEqual(photoObject.size, size)
    }
}
