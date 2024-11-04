import Sparkle
import SwiftUI

class UpdateManager: NSObject, ObservableObject, SPUUpdaterDelegate {
    private var updater: SPUUpdater
    private var automaticCheckEnabled: Bool
    private var controller: SPUStandardUpdaterController
    
    @Published var canCheckForUpdates = false
    @Published var updateError: String?
    
    override init() {
        controller = SPUStandardUpdaterController(startingUpdater: true, updaterDelegate: nil, userDriverDelegate: nil)
        updater = controller.updater
        automaticCheckEnabled = true
        
        super.init()
        
        updater.delegate = self
        
        updater.publisher(for: \.canCheckForUpdates)
            .receive(on: DispatchQueue.main)
            .assign(to: &$canCheckForUpdates)
    }
    
    func checkForUpdates() {
        updater.checkForUpdates()
    }
    
    func updater(_ updater: SPUUpdater, didAbortWithError error: Error) {
        print("Update error: \(error.localizedDescription)")
        self.updateError = error.localizedDescription
    }
    
    func updater(_ updater: SPUUpdater, didFinishLoading appcast: SUAppcast) {
        DispatchQueue.main.async {
            self.canCheckForUpdates = true
        }
    }
}
