import SwiftUI
import Sparkle

final class UpdateManager: ObservableObject {
    private let updaterController: SPUStandardUpdaterController
    @Published private(set) var canCheckForUpdates = false
    
    init() {
        // If you want to start the updater manually, pass false to startingUpdater and call .startUpdater() later
        updaterController = SPUStandardUpdaterController(
            startingUpdater: true,
            updaterDelegate: nil,
            userDriverDelegate: nil
        )
        
        // Automatically check for updates
        updaterController.updater.automaticallyChecksForUpdates = true
        
        // Bind the published property to the updater controller
        updaterController.updater.publisher(for: \.canCheckForUpdates)
            .assign(to: &$canCheckForUpdates)
    }
    
    func checkForUpdates() {
        updaterController.checkForUpdates(nil)
    }
}
