import SwiftUI

/// Role: pendant-locked chrome. Quiz stays. Sheets arrive around it.
struct ContentView: View {
    @ObservedObject var studio: BottegaStudio

    @State private var sheet: StudioSheet?
    @State private var replayOnboarding = false
    @State private var didApplyReview = false

    var body: some View {
        Group {
            if studio.document.onboardingComplete && !replayOnboarding {
                QuizView(
                    studio: studio,
                    openExplore: { sheet = .explore },
                    openSaved: { sheet = .saved },
                    openSettings: { sheet = .settings },
                    openTwist: { sheet = .twist }
                )
            } else {
                OnboardingView(studio: studio) {
                    replayOnboarding = false
                }
            }
        }
        .sheet(item: $sheet) { item in
            StudioSheetGate {
                switch item {
                case .explore:
                    ExploreView(studio: studio, onClose: { sheet = nil })
                case .saved:
                    SavedView(
                        studio: studio,
                        onClose: { sheet = nil },
                        onExplore: { sheet = .explore }
                    )
                case .settings:
                    SettingsView(
                        studio: studio,
                        onClose: { sheet = nil },
                        onReplayOnboarding: {
                            sheet = nil
                            replayOnboarding = true
                        }
                    )
                case .twist:
                    InstallMateView(onClose: { sheet = nil })
                }
            }
        }
        .onAppear { applyReviewIfNeeded() }
        .onChange(of: studio.document.onboardingComplete) { _, complete in
            if complete { applyReviewIfNeeded() }
        }
        .onReceive(NotificationCenter.default.publisher(for: .NSCalendarDayChanged)) { _ in
            studio.noteCalendarDay()
        }
    }

    private func applyReviewIfNeeded() {
        guard studio.document.onboardingComplete else { return }
        guard !didApplyReview else { return }
        didApplyReview = true
        switch ReviewDestination.parseLaunch() {
        case .today, .none:
            break
        case .log, .saved, .savedsheet:
            sheet = .saved
        case .goals, .settingssheet:
            sheet = .settings
        case .explore, .exploresheet:
            sheet = .explore
        case .twist:
            sheet = .twist
        }
    }
}

enum StudioSheet: String, Identifiable {
    case explore
    case saved
    case settings
    case twist

    var id: String { rawValue }
}
