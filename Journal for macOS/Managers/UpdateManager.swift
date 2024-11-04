import Sparkle
import SwiftUI

class UpdateManager: NSObject, ObservableObject {
    private var updater: SPUUpdater
    private var automaticCheckEnabled: Bool
    
    @Published var canCheckForUpdates = false
    
    override init() {
        let controller = SPUStandardUpdaterController(startingUpdater: true, updaterDelegate: nil, userDriverDelegate: nil)
        updater = controller.updater
        automaticCheckEnabled = true
        
        super.init()
    }
    
    func checkForUpdates() {
        updater.checkForUpdates()
    }
}

extension UpdateManager: SPUUpdaterDelegate {
    func updater(_ updater: SPUUpdater, didFinishLoading appcast: SUAppcast) {
        DispatchQueue.main.async {
            self.canCheckForUpdates = true
        }
    }
}
