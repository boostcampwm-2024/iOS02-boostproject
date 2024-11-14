//
//  SceneDelegate.swift
//  AirplaIN
//
//  Created by 최다경 on 11/6/24.
//

import DataSource
import Domain
import NearbyNetwork
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
        let nearbyNetworkService = NearbyNetworkService(profileName: "name", serviceName: "whiteboard")
        let repository = WhiteboardRepository(nearbyNetworkInterface: nearbyNetworkService)
        let whiteboardUseCase = WhiteboardUseCase(repository: repository)
        let viewModel = WhiteboardListViewModel(whiteboardUseCase: whiteboardUseCase, nickname: "name")
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

