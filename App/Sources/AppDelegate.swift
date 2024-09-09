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
            let navigationController = UINavigationController(rootViewController: feedViewController)
            navigationController.edgesForExtendedLayout = .all
            navigationController.extendedLayoutIncludesOpaqueBars = true
            navigationController.navigationBar.isTranslucent = true
            window.rootViewController = navigationController
        }
        window.makeKeyAndVisible()
        self.window = window
    }
}
