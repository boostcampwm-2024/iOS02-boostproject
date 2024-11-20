//
//  AddPhotoUseCaseTests.swift
//  DomainTests
//
//  Created by 이동현 on 11/18/24.
//

import Domain
import XCTest

final class AddPhotoUseCaseTests: XCTestCase {
    private var useCase: AddPhotoUseCase!

    override func setUp() {
        super.setUp()

        do {
            useCase = try AddPhotoUseCase()
        } catch {
            XCTFail("init photoUseCase should success.")
        }
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
        let photoObject: PhotoObject

        // 실행
        do {
            photoObject = try useCase.addPhoto(
                imageData: dummyImageData,
                position: position,
                size: size)
        } catch {
            XCTFail("photoObject should not fail.")
            return
        }

        // 검증
        XCTAssertEqual(photoObject.photoURL.lastPathComponent.suffix(4), ".jpg")
        XCTAssertEqual(photoObject.position, position)
        XCTAssertEqual(photoObject.size, size)
    }
}
