//
//  Copyright (c) 2021 gematik GmbH
//  
//  Licensed under the EUPL, Version 1.2 or – as soon they will be approved by
//  the European Commission - subsequent versions of the EUPL (the Licence);
//  You may not use this work except in compliance with the Licence.
//  You may obtain a copy of the Licence at:
//  
//      https://joinup.ec.europa.eu/software/page/eupl
//  
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the Licence is distributed on an "AS IS" basis,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the Licence for the specific language governing permissions and
//  limitations under the Licence.
//  
//

import SwiftUI
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var mainWindow,
        authenticationWindow: UIWindow?

    let viewModel = ViewModel()

    func scene(_ scene: UIScene,
               willConnectTo _: UISceneSession,
               options: UIScene.ConnectionOptions) {
        if let windowScene = scene as? UIWindowScene {
            authenticationWindow = UIWindow(windowScene: windowScene)
            mainWindow = UIWindow(windowScene: windowScene)
            mainWindow?.rootViewController = UIHostingController(
                rootView: ApproveView(viewModel: viewModel)
            )
            mainWindow?.makeKeyAndVisible()
        }

        if let userActivity = options.userActivities.first {
            switch userActivity.activityType {
            case NSUserActivityTypeBrowsingWeb:
                guard let url = userActivity.webpageURL else { return }

                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.viewModel.processERezeptLogin(with: url)
                }
            default:
                break
            }
        }
    }

    func scene(_: UIScene, openURLContexts _: Set<UIOpenURLContext>) {}

    func sceneDidDisconnect(_: UIScene) {}

    func sceneDidBecomeActive(_: UIScene) {}

    func scene(_: UIScene, continue userActivity: NSUserActivity) {
        switch userActivity.activityType {
        case NSUserActivityTypeBrowsingWeb:
            guard let url = userActivity.webpageURL else { return }

            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.viewModel.processERezeptLogin(with: url)
            }
        default:
            break
        }
    }

    func sceneWillResignActive(_: UIScene) {}

    func sceneWillEnterForeground(_: UIScene) {}

    func sceneDidEnterBackground(_: UIScene) {}
}
