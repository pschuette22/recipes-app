import Foundation
import UIKit


@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let isTesting = ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
        prepareApplicationWindow(isTesting: isTesting)
        return true
    }
    
    private func prepareApplicationWindow(isTesting: Bool) {
        let window = UIWindow(frame: UIScreen.main.bounds)
        if isTesting {
            window.rootViewController = UIViewController()
        } else {
            let viewModel = RecipeFeedViewModel()
            let feedViewController = RecipeFeedViewController(viewModel: viewModel)
            window.rootViewController = UINavigationController(rootViewController: feedViewController)
        }
        window.makeKeyAndVisible()
        self.window = window
    }
}
