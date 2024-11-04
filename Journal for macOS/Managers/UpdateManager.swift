import Sparkle
import SwiftUI

class UpdateManager: NSObject, ObservableObject, SPUUpdaterDelegate {
    private var updater: SPUUpdater
    private var controller: SPUStandardUpdaterController
    
    @Published var canCheckForUpdates = false
    @Published var updateError: String?
    @Published var lastUpdateCheckDate: Date?
    @Published var currentVersion: String
    @Published var updateStatus: UpdateStatus = .noUpdates
    
    enum UpdateStatus {
        case noUpdates
        case checking
        case available(version: String)
        case error(String)
    }
    
    override init() {
        currentVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "Unknown"
        
        // Initialize controller with self as delegate
        controller = SPUStandardUpdaterController(
            startingUpdater: true,
            updaterDelegate: nil,
            userDriverDelegate: nil
        )
        updater = controller.updater
        
        super.init()
        
        // Configure publishers
        updater.publisher(for: \.canCheckForUpdates)
            .receive(on: DispatchQueue.main)
            .assign(to: &$canCheckForUpdates)
            
        updater.publisher(for: \.lastUpdateCheckDate)
            .receive(on: DispatchQueue.main)
            .assign(to: &$lastUpdateCheckDate)
    }
    
    func checkForUpdates() {
        updateStatus = .checking
        updater.checkForUpdates()
    }
    
    // MARK: - SPUUpdaterDelegate
    func updater(_ updater: SPUUpdater, didFindValidUpdate item: SUAppcastItem) {
        DispatchQueue.main.async {
            self.updateStatus = .available(version: item.displayVersionString)
        }
    }
    
    func updater(_ updater: SPUUpdater, didFinishLoading appcast: SUAppcast) {
        DispatchQueue.main.async {
            self.updateStatus = .noUpdates
            self.canCheckForUpdates = true
        }
    }
    
    func updater(_ updater: SPUUpdater, failedToDownloadUpdate item: SUAppcastItem, error: Error) {
        DispatchQueue.main.async {
            self.updateError = error.localizedDescription
            self.updateStatus = .error(error.localizedDescription)
        }
    }
}
