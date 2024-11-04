import Sparkle
import SwiftUI

class UpdateManager: NSObject, ObservableObject {
    private var updater: SPUUpdater
    private var automaticCheckEnabled: Bool
    private var controller: SPUStandardUpdaterController
    
    @Published var canCheckForUpdates = false
    
    override init() {
        // Create the updater controller with self as the delegate
        controller = SPUStandardUpdaterController(startingUpdater: true, updaterDelegate: nil, userDriverDelegate: nil)
        updater = controller.updater
        automaticCheckEnabled = true
        
        super.init()
        
        // Configure the updater
        updater.publisher(for: \.canCheckForUpdates)
            .receive(on: DispatchQueue.main)
            .assign(to: &$canCheckForUpdates)
    }
    
    func checkForUpdates() {
        updater.checkForUpdates()
    }
}
