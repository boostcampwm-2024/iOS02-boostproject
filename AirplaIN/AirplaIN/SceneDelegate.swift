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
        let nearbyNetworkService = NearbyNetworkService(serviceName: "airplain")
        let filePersistenceService = FilePersistence()
        let whiteboardObjectSet = WhiteboardObjectSet()

        let profileRepository = ProfileRepository(persistenceService: PersistenceService())
        let whiteboardRepository = WhiteboardRepository(
            nearbyNetworkInterface: nearbyNetworkService,
            myProfile: profileRepository.loadProfile())
        let whiteboardObjectRepository = WhiteboardObjectRepository(
            nearbyNetwork: nearbyNetworkService,
            filePersistence: filePersistenceService)
        let photoRepository = PhotoRepository(filePersistence: filePersistenceService)
        let chatRepository = ChatRepository(
            nearbyNetwork: nearbyNetworkService,
            filePersistence: filePersistenceService)

        let whiteboardUseCase = WhiteboardListUseCase(
            whiteboardRepository: whiteboardRepository,
            profileRepository: profileRepository)
        let profileUseCase = ProfileUseCase(repository: profileRepository)
        let manageWhiteboardObjectUseCase = WhiteboardUseCase(
            profileRepository: profileRepository,
            whiteboardObjectRepository: whiteboardObjectRepository,
            whiteboardRepository: whiteboardRepository,
            whiteboardObjectSet: whiteboardObjectSet)
        let manageWhiteboardToolUseCase = ManageWhiteboardToolUseCase()
        let textObjectUseCase = TextObjectUseCase(
            whiteboardObjectSet: whiteboardObjectSet,
            textFieldDefaultSize: CGSize(width: 200, height: 50))
        let drawObjectUseCase = DrawObjectUseCase()
        let gameRepository = GameRepository(persistenceService: PersistenceService())
        let gameObjectUseCase = GameObjectUseCase(repository: gameRepository)
        let photoUseCase = PhotoUseCase(photoRepository: photoRepository)
        let chatUseCase = ChatUseCase(chatRepository: chatRepository)

        let whiteboardObjectViewFactory = WhiteboardObjectViewFactory()

        let whiteboardListViewModel = WhiteboardListViewModel(whiteboardUseCase: whiteboardUseCase)
        let profileViewModel = ProfileViewModel(profileUseCase: profileUseCase)

        let whiteboardListViewController = WhiteboardListViewController(
            viewModel: whiteboardListViewModel,
            whiteboardObjectViewFactory: whiteboardObjectViewFactory,
            profileViewModel: profileViewModel,
            profileRepository: profileRepository,
            whiteboardUseCase: whiteboardUseCase,
            photoUseCase: photoUseCase,
            drawObjectUseCase: drawObjectUseCase,
            textObjectUseCase: textObjectUseCase,
            chatUseCase: chatUseCase,
            gameRepository: gameRepository,
            gameObjectUseCase: gameObjectUseCase,
            manageWhiteboardToolUseCase: manageWhiteboardToolUseCase,
            manageWhiteboardObjectUseCase: manageWhiteboardObjectUseCase)

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
