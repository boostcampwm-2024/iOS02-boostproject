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
        let whiteboardRepository = WhiteboardRepository(nearbyNetworkInterface: nearbyNetworkService)
        let profileRepository = ProfileRepository(persistenceService: PersistenceService())
        let whiteboardUseCase = WhiteboardUseCase(
            whiteboardRepository: whiteboardRepository,
            profileRepository: profileRepository)
        let viewModel = WhiteboardListViewModel(whiteboardUseCase: whiteboardUseCase)
        let viewController = WhiteboardListViewController(viewModel: viewModel)

        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = viewController
        window.makeKeyAndVisible()

        self.window = window
    }

    func sceneDidDisconnect(_ scene: UIScene) {}

    func sceneDidBecomeActive(_ scene: UIScene) {}

    func sceneWillResignActive(_ scene: UIScene) {}

    func sceneWillEnterForeground(_ scene: UIScene) {}

    func sceneDidEnterBackground(_ scene: UIScene) {}
}
