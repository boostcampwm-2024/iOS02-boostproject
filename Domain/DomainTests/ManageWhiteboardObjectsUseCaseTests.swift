//
//  ManageWhiteboardObjectsUseCaseTests.swift
//  DomainTests
//
//  Created by 이동현 on 11/16/24.
//

import Combine
import Domain
import XCTest

final class ManageWhiteboardObjectsUseCaseTests: XCTestCase {
    private var useCase: ManageWhiteboardObjectUseCaseInterface!
    private var cancellables: Set<AnyCancellable>!
    private var myProfile: Profile!

    override func setUpWithError() throws {
        let profileRepository = MockProfileRepository()
        myProfile = profileRepository.loadProfile()

        useCase = ManageWhiteboardObjectUseCase(
            profileRepository: profileRepository,
            whiteboardObjectRepository: MockWhiteObjectRepository(),
            whiteboardRepository: MockWhiteboardRepository(),
            whiteboardObjectSet: WhiteboardObjectSet())
        cancellables = []
    }

    override func tearDownWithError() throws {
        useCase = nil
    }

    // 화이트보드 오브젝트 추가가 성공하는지 테스트
    func testAddWhiteboardObjectSuccess() async {
        // 준비
        let targetObject = WhiteboardObject(
            id: UUID(),
            centerPosition: .zero,
            size: CGSize(width: 100, height: 100))
        var receivedObject: WhiteboardObject?

        useCase.addedObjectPublisher
            .sink { receivedObject = $0 }
            .store(in: &cancellables)

        // 실행
        let isSuccess = await useCase.addObject(
            whiteboardObject: targetObject,
            isReceivedObject: false)

        // 검증
        XCTAssertTrue(isSuccess)
        XCTAssertEqual(receivedObject, targetObject)
    }

    // 화이트보드 오브젝트 중복 추가가 실패하는지 테스트
    func testAddDuplicateObjectFails() async {
        // 준비
        let targetObject = WhiteboardObject(
            id: UUID(),
            centerPosition: .zero,
            size: CGSize(width: 100, height: 100))

        // 실행
        let isSuccess = await useCase.addObject(
            whiteboardObject: targetObject,
            isReceivedObject: false)
        let isFailure = await !useCase.addObject(
            whiteboardObject: targetObject,
            isReceivedObject: false)

        // 검증
        XCTAssertTrue(isSuccess)
        XCTAssertTrue(isFailure)
    }

    // 화이트보드 오브젝트 업데이트 성공하는지 테스트
    func testUpdateObjectSuccess() async {
        // 준비
        let uuid = UUID()
        let object = WhiteboardObject(
            id: uuid,
            centerPosition: .zero,
            size: CGSize(width: 100, height: 100))
        let updatedObject = WhiteboardObject(
            id: uuid,
            centerPosition: CGPoint(x: 50, y: 50),
            size: CGSize(width: 200, height: 200))
        var receivedObject: WhiteboardObject?

        useCase.updatedObjectPublisher
            .sink { receivedObject = $0 }
            .store(in: &cancellables)

        // 실행
        await useCase.addObject(whiteboardObject: object, isReceivedObject: false)
        let isSuccess = await useCase.updateObject(
            whiteboardObject: updatedObject,
            isReceivedObject: false)

        // 검증
        XCTAssertTrue(isSuccess)
        XCTAssertEqual(updatedObject, receivedObject)
    }

    // 존재하지 않는 화이트보드 오브젝트 업데이트 실패하는지 테스트
    func testUpdateNonExistentObjectFails() async {
        // 준비
        let targetObject = WhiteboardObject(
            id: UUID(),
            centerPosition: CGPoint(x: 50, y: 50),
            size: CGSize(width: 200, height: 200))
        var receivedObject: WhiteboardObject?

        useCase.updatedObjectPublisher
            .sink { receivedObject = $0 }
            .store(in: &cancellables)

        // 실행
        let isFailure = await !useCase.updateObject(
            whiteboardObject: targetObject,
            isReceivedObject: false)

        // 검증
        XCTAssertTrue(isFailure)
        XCTAssertNil(receivedObject)
    }

    // 화이트보드 오브젝트 삭제 성공하는지 테스트
    func testRemoveObjectSuccess() async {
        // 준비
        let object1 = WhiteboardObject(
            id: UUID(),
            centerPosition: .zero,
            size: CGSize(width: 100, height: 100))
        let object2 = WhiteboardObject(
            id: UUID(),
            centerPosition: .zero,
            size: CGSize(width: 100, height: 100))
        let targetObject = WhiteboardObject(
            id: UUID(),
            centerPosition: .zero,
            size: CGSize(width: 100, height: 100),
            selectedBy: myProfile)
        var receivedObject: WhiteboardObject?

        useCase.removedObjectPublisher
            .sink { receivedObject = $0 }
            .store(in: &cancellables)

        // 실행
        await useCase.addObject(whiteboardObject: object1, isReceivedObject: false)
        await useCase.addObject(whiteboardObject: targetObject, isReceivedObject: false)
        await useCase.addObject(whiteboardObject: object2, isReceivedObject: false)
        let isSuceess = await useCase.removeObject(
            whiteboardObjectID: targetObject.id,
            isReceivedObject: false)

        // 검증
        XCTAssertTrue(isSuceess)
        XCTAssertEqual(targetObject, receivedObject)
    }

    // 존재하지 않는 화이트보드 오브젝트 삭제 실패하는지 테스트
    func testRemoveNonExistentObjectFails() async {
        // 준비
        let object = WhiteboardObject(
            id: UUID(),
            centerPosition: .zero,
            size: CGSize(width: 100, height: 100))
        var receivedObject: WhiteboardObject?

        useCase.removedObjectPublisher
            .sink { receivedObject = $0 }
            .store(in: &cancellables)

        // 실행
        let isFailure = await !useCase.removeObject(
            whiteboardObjectID: object.id,
            isReceivedObject: false)

        // 검증
        XCTAssertTrue(isFailure)
        XCTAssertNil(receivedObject)
    }

    // 다른 사람이 선택한 화이트보드 오브젝트 삭제 실패하는지 테스트
    func testRemoveObjectFailsWhenSelectedByOther() async {
        // 준비
        let object1 = WhiteboardObject(
            id: UUID(),
            centerPosition: .zero,
            size: CGSize(width: 100, height: 100))
        let object2 = WhiteboardObject(
            id: UUID(),
            centerPosition: .zero,
            size: CGSize(width: 100, height: 100))
        let targetObject = WhiteboardObject(
            id: UUID(),
            centerPosition: .zero,
            size: CGSize(width: 100, height: 100),
            selectedBy: Profile(nickname: "other", profileIcon: .angel))

        // 실행
        await useCase.addObject(whiteboardObject: object1, isReceivedObject: false)
        await useCase.addObject(whiteboardObject: targetObject, isReceivedObject: false)
        await useCase.addObject(whiteboardObject: object2, isReceivedObject: false)
        let isFailure = await !useCase.removeObject(
            whiteboardObjectID: targetObject.id,
            isReceivedObject: false)

        // 검증
        XCTAssertTrue(isFailure)
    }

    // 화이트보드 오브젝트 선택 성공하는지 테스트
    func testSelectWhiteboardObjectSuccess() async {
        // 준비
        let targetObject = WhiteboardObject(
            id: UUID(),
            centerPosition: .zero,
            size: CGSize(width: 100, height: 100),
            selectedBy: nil)

        // 실행
        await useCase.addObject(whiteboardObject: targetObject, isReceivedObject: false)
        let isSuccess = await useCase.select(whiteboardObjectID: targetObject.id)

        // 검증
        XCTAssertTrue(isSuccess)
        XCTAssertEqual(targetObject.selectedBy, myProfile)
    }

    // 이미 선택된 객체를 선택할 때 실패하는지 테스트
    func testSelectAlreadySelectedObjectFails() async {
        // 준비
        let myProfile = Profile(nickname: "test", profileIcon: .angel)
        let strangerProfile = Profile(nickname: "strangerProfile", profileIcon: .cold)
        let targetObject = WhiteboardObject(
            id: UUID(),
            centerPosition: .zero,
            size: CGSize(width: 100, height: 100),
            selectedBy: strangerProfile)

        // 실행
        await useCase.addObject(whiteboardObject: targetObject, isReceivedObject: false)
        let isFailure = await !useCase.select(whiteboardObjectID: targetObject.id)

        // 검증
        XCTAssertTrue(isFailure)
        XCTAssertNotEqual(targetObject.selectedBy, myProfile)
        XCTAssertEqual(targetObject.selectedBy, strangerProfile)
    }

    // 존재하지 않는 객체를 선택할 때 실패하는지 테스트
    func testSelectNonExistentObjectFails() async {
        // 준비
        let nonExistentObjectID = UUID()
        var selectedObjectID: UUID?
        useCase.selectedObjectIDPublisher
            .sink { selectedObjectID = $0 }
            .store(in: &cancellables)

        // 검증
        let isFailure = await !useCase.select(whiteboardObjectID: nonExistentObjectID)

        // 실행
        XCTAssertTrue(isFailure)
        XCTAssertNil(selectedObjectID)
    }

    // 객체 선택 해제 성공하는지 테스트
    func testDeselectWhiteboardObjectSuccess() async {
        // 준비
        let targetObject = WhiteboardObject(
            id: UUID(),
            centerPosition: .zero,
            size: CGSize(width: 100, height: 100),
            selectedBy: nil)

        // 실행
        await useCase.addObject(whiteboardObject: targetObject, isReceivedObject: false)
        await useCase.select(whiteboardObjectID: targetObject.id)
        let isSuccess = await useCase.deselect()

        // 검증
        XCTAssertTrue(isSuccess)
    }

    // 오브젝트 scale 변경 성공하는지 테스트
    func testChangeScaleSuccess() async {
        // 준비
        let targetObject = WhiteboardObject(
            id: UUID(),
            centerPosition: .zero,
            size: CGSize(width: 100, height: 100),
            scale: 1,
            selectedBy: myProfile)

        // 실행
        await useCase.addObject(whiteboardObject: targetObject, isReceivedObject: false)
        let isSuccess = await useCase.changeSizeAndAngle(
            whiteboardObjectID: targetObject.id,
            scale: 2,
            angle: targetObject.angle)

        // 검증
        XCTAssertTrue(isSuccess)
        XCTAssertEqual(targetObject.scale, 2)
    }

    // 다른 사람이 선택 중일 때 scale 변경 실패하는지 테스트
    func testChangeScaleFailsWhenSelectedByOther() async {
        // 준비
        let strangerProfile = Profile(nickname: "Other", profileIcon: .cold)
        let targetObject = WhiteboardObject(
            id: UUID(),
            centerPosition: .zero,
            size: CGSize(width: 100, height: 100),
            scale: 1,
            selectedBy: strangerProfile)

        // 실행
        await useCase.addObject(whiteboardObject: targetObject, isReceivedObject: false)
        let isFailure = await !useCase.changeSizeAndAngle(
            whiteboardObjectID: targetObject.id,
            scale: 2,
            angle: targetObject.angle)

        // 검증
        XCTAssertTrue(isFailure)
        XCTAssertEqual(targetObject.scale, 1)
    }

    // 선택하지 않은 상태라 scale 변경 실패하는지 테스트
    func testChangeScaleFailsWhenNotSelected() async {
        // 준비
        let targetObject = WhiteboardObject(
            id: UUID(),
            centerPosition: .zero,
            size: CGSize(width: 100, height: 100),
            scale: 1,
            selectedBy: nil)

        // 실행
        await useCase.addObject(whiteboardObject: targetObject, isReceivedObject: false)
        let isFailure = await !useCase.changeSizeAndAngle(
            whiteboardObjectID: targetObject.id,
            scale: 2,
            angle: targetObject.angle)

        // 검증
        XCTAssertTrue(isFailure)
        XCTAssertEqual(targetObject.scale, 1)
    }

    // 오브젝트 angle 변경 성공하는지 테스트
    func testChangeAngleSuccess() async {
        // 준비
        let targetObject = WhiteboardObject(
            id: UUID(),
            centerPosition: .zero,
            size: CGSize(width: 100, height: 100),
            angle: 0,
            selectedBy: myProfile)

        // 실행
        await useCase.addObject(whiteboardObject: targetObject, isReceivedObject: false)
        let isSuccess = await useCase.changeSizeAndAngle(
            whiteboardObjectID: targetObject.id,
            scale: targetObject.scale,
            angle: 1)

        // 검증
        XCTAssertTrue(isSuccess)
        XCTAssertEqual(targetObject.angle, 1)
    }

    // 다른 사람이 선택 중일 때 angle 변경 실패하는지 테스트
    func testChangeAngleFailsWhenSelectedByOther() async {
        // 준비
        let strangerProfile = Profile(nickname: "Other", profileIcon: .cold)
        let targetObject = WhiteboardObject(
            id: UUID(),
            centerPosition: .zero,
            size: CGSize(width: 100, height: 100),
            angle: 0,
            selectedBy: strangerProfile)

        // 실행
        await useCase.addObject(whiteboardObject: targetObject, isReceivedObject: false)
        let isFailure = await !useCase.changeSizeAndAngle(
            whiteboardObjectID: targetObject.id,
            scale: targetObject.scale,
            angle: 1)

        // 검증
        XCTAssertTrue(isFailure)
        XCTAssertEqual(targetObject.angle, 0)
    }

    // 선택하지 않은 상태라 angle 변경 실패하는지 테스트
    func testChangeAngleFailsWhenNotSelected() async {
        // 준비
        let targetObject = WhiteboardObject(
            id: UUID(),
            centerPosition: .zero,
            size: CGSize(width: 100, height: 100),
            angle: 0,
            selectedBy: nil)

        // 실행
        await useCase.addObject(whiteboardObject: targetObject, isReceivedObject: false)
        let isFailure = await !useCase.changeSizeAndAngle(
            whiteboardObjectID: targetObject.id,
            scale: targetObject.scale,
            angle: 1)

        // 검증
        XCTAssertTrue(isFailure)
        XCTAssertEqual(targetObject.angle, 0)
    }
}

final class MockProfileRepository: ProfileRepositoryInterface {
    private let mockProfile = Profile(nickname: "test", profileIcon: .angel)

    func loadProfile() -> Profile {
        return mockProfile
    }

    func saveProfile(profile: Profile) {
        return
    }
}

final class MockWhiteObjectRepository: WhiteboardObjectRepositoryInterface {
    var delegate: (any WhiteboardObjectRepositoryDelegate)?

    func send(
        whiteboardObject: WhiteboardObject,
        isDeleted: Bool,
        to profile: Profile
    ) async {}

    func send(
        whiteboardObjects: [WhiteboardObject],
        isDeleted: Bool,
        to profile: Profile
    ) async {}

    func send(whiteboardObject: WhiteboardObject, isDeleted: Bool) async {}
}

final class MockWhiteboardRepository: WhiteboardRepositoryInterface {
    var delegate: (any WhiteboardRepositoryDelegate)?
    var recentPeerPublisher: AnyPublisher<Domain.Profile, Never>
    private var recentPeerSubject = PassthroughSubject<Domain.Profile, Never>()

    init() {
        recentPeerPublisher = recentPeerSubject.eraseToAnyPublisher()
    }

    func startPublishing(myProfile: Profile) {}

    func stopSearching() {}

    func startSearching() {}

    func disconnectWhiteboard() {}

    func joinWhiteboard(whiteboard: Domain.Whiteboard, myProfile: Domain.Profile) throws {}
}
