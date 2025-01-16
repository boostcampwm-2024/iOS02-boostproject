//
//  SceneDelegate.swift
//  AirplaIN
//
//  Created by 최다경 on 11/6/24.
//

import DataSource
import Domain
import NearbyNetwork
import Persistence
import Presentation
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        // TODO: - 임시 의존성 주입

        let profileRepository = ProfileRepository(persistenceService: PersistenceService())
        let myProfile = profileRepository.loadProfile()
        let nearbyNetworkService = NearbyNetworkService(
            myPeerID: myProfile.id,
            serviceName: "airplain",
            serviceType: "_airplain._tcp")
        let filePersistenceService = FilePersistence()
        let whiteboardObjectSet = WhiteboardObjectSet()

        let whiteboardListRepository = WhiteboardListRepository(nearbyNetworkService: nearbyNetworkService)
        let whiteboardRepository = WhiteboardRepository(
            nearbyNetworkService: nearbyNetworkService,
            filePersistence: filePersistenceService)
        let photoRepository = PhotoRepository(filePersistence: filePersistenceService)
        let chatRepository = ChatRepository(
            nearbyNetworkService: nearbyNetworkService,
            filePersistence: filePersistenceService)

        let whiteboardListUseCase = WhiteboardListUseCase(
            whiteboardListRepository: whiteboardListRepository,
            profileRepository: profileRepository)
        let profileUseCase = ProfileUseCase(repository: profileRepository)
        let whiteboardUseCase = WhiteboardUseCase(
            profileRepository: profileRepository,
            whiteboardRepository: whiteboardRepository,
            whiteboardObjectSet: whiteboardObjectSet)
        let whiteboardToolUseCase = WhiteboardToolUseCase()
        let textObjectUseCase = TextObjectUseCase(
            whiteboardObjectSet: whiteboardObjectSet,
            textFieldDefaultSize: CGSize(width: 200, height: 50))
        let drawObjectUseCase = DrawObjectUseCase()
        let gameRepository = GameRepository(persistenceService: PersistenceService())
        let gameObjectUseCase = GameObjectUseCase(repository: gameRepository)
        let photoUseCase = PhotoUseCase(photoRepository: photoRepository)
        let chatUseCase = ChatUseCase(chatRepository: chatRepository)

        let whiteboardObjectViewFactory = WhiteboardObjectViewFactory()

        let whiteboardListViewModel = WhiteboardListViewModel(whiteboardListUseCase: whiteboardListUseCase)
        let profileViewModel = ProfileViewModel(profileUseCase: profileUseCase)

        let whiteboardListViewController = WhiteboardListViewController(
            viewModel: whiteboardListViewModel,
            whiteboardObjectViewFactory: whiteboardObjectViewFactory,
            profileViewModel: profileViewModel,
            profileRepository: profileRepository,
            whiteboardListUseCase: whiteboardListUseCase,
            photoUseCase: photoUseCase,
            drawObjectUseCase: drawObjectUseCase,
            textObjectUseCase: textObjectUseCase,
            chatUseCase: chatUseCase,
            gameRepository: gameRepository,
            gameObjectUseCase: gameObjectUseCase,
            whiteboardToolUseCase: whiteboardToolUseCase,
            whiteboardUseCase: whiteboardUseCase)

        let window = UIWindow(windowScene: windowScene)
        let navigationController = UINavigationController(rootViewController: whiteboardListViewController)
        navigationController.isNavigationBarHidden = true
        window.rootViewController = navigationController
        window.makeKeyAndVisible()

        self.window = window
    }

    func sceneDidDisconnect(_ scene: UIScene) {}

    func sceneDidBecomeActive(_ scene: UIScene) {}

    func sceneWillResignActive(_ scene: UIScene) {}

    func sceneWillEnterForeground(_ scene: UIScene) {}

    func sceneDidEnterBackground(_ scene: UIScene) {}
}
