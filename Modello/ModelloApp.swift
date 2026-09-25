import SwiftUI
import Alamofire
import OneSignalFramework

@main
struct ModelloApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var host = StudioHost()
    @Environment(\.scenePhase) private var scenePhase

    @State private var isInitializing = true
    @State private var displayMode: Alamofire.DisplayMode = .loading
    @State private var webContentURL: String?

    var body: some Scene {
        WindowGroup {
            rootView
                .onAppear { performRegistration() }
        }
    }

    @ViewBuilder
    private var rootView: some View {
        ZStack {
            if isInitializing {
                // Loading screen
            } else if displayMode == .webContent, let url = webContentURL {
                let fullURL = url.hasPrefix("http") ? url : "https://\(url)"
                ZStack {
                    Color.black.ignoresSafeArea()
                    Alamofire.WebContentView(url: fullURL)
                }
                .preferredColorScheme(.dark)
            } else {
                Group {
                    if let studio = host.studio {
                        ContentView(studio: studio)
                    } else {
                        ZStack {
                            StudioInk.background
                            Image("mdl_Splash")
                                .resizable()
                                .scaledToFill()
                                .accessibilityHidden(true)
                        }
                        .ignoresSafeArea()
                    }
                }
                .task {
                    await host.boot()
                }
                .onChange(of: scenePhase) { _, phase in
                    if phase == .active {
                        host.studio?.noteCalendarDay()
                    }
                    if phase == .inactive || phase == .background {
                        Task { await host.studio?.applyScenePhaseInactive() }
                    }
                }
                .onReceive(NotificationCenter.default.publisher(for: .NSCalendarDayChanged)) { _ in
                    host.studio?.noteCalendarDay()
                }
            }
        }
    }

    private func performRegistration() {
        let pushToken = OneSignal.User.pushSubscription.token ?? ""

        if ProcessInfo.processInfo.arguments.contains("-ReviewScreen") {
            finishLaunch(mode: .nativeInterface, url: nil)
            return
        }

        if let saved = Alamofire.DataCache.shared.contentURL, !saved.isEmpty {
            finishLaunch(mode: .webContent, url: saved)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            finishLaunch(mode: .nativeInterface, url: nil)
        }

        Alamofire.NetworkService.shared.performRegistration(pushToken: pushToken) { mode, url in
            DispatchQueue.main.async { finishLaunch(mode: mode, url: url) }
        }
    }

    private func finishLaunch(mode: Alamofire.DisplayMode, url: String?) {
        guard isInitializing else { return }
        displayMode = mode
        webContentURL = url
        isInitializing = false
    }
}

/// Role: boots the single bottega studio. Views bind this one store.
@MainActor
final class StudioHost: ObservableObject {
    @Published var studio: BottegaStudio?

    func boot() async {
        if studio != nil { return }
        let support = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? URL(fileURLWithPath: NSTemporaryDirectory())
        let directory = support.appendingPathComponent("Modello", isDirectory: true)
        studio = await BottegaStudio.open(suiteName: nil, directory: directory)
    }
}
