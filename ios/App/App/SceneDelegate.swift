import UIKit
import WebKit
import Capacitor

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }

        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = CAPBridgeViewController()
        window?.makeKeyAndVisible()

        SceneDelegateProxy.shared.scene(scene, willConnectTo: session, options: connectionOptions)

        // Cold start from a Universal Link (verification email, password reset, invitation): the
        // bridge has just started loading server.url, so the link replaces that first load.
        for userActivity in connectionOptions.userActivities {
            openUniversalLink(userActivity)
        }
    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        SceneDelegateProxy.shared.scene(scene, openURLContexts: URLContexts)
    }

    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        SceneDelegateProxy.shared.scene(scene, continue: userActivity)
        openUniversalLink(userActivity)
    }

    // The web application lives at server.url, so a Universal Link is opened by loading that same
    // page in the WebView. Nothing in the page has to listen for `appUrlOpen`, and the session
    // cookies already stored in the WebView apply to the request.
    private func openUniversalLink(_ userActivity: NSUserActivity) {
        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
              let url = userActivity.webpageURL,
              AppLinks.isAppUrl(url) else { return }

        DispatchQueue.main.async { [weak self] in
            guard let bridgeController = self?.window?.rootViewController as? CAPBridgeViewController,
                  let webView = bridgeController.webView else { return }
            webView.load(URLRequest(url: url))
        }
    }
}

enum AppLinks {
    // Must match server.url in capacitor.config.json and the Associated Domains entitlement.
    static let host = "agrogestion.app"

    static func isAppUrl(_ url: URL) -> Bool {
        return url.scheme == "https" && url.host?.lowercased() == host
    }
}
