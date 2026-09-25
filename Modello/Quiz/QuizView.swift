import SwiftUI

/// Role: studio root. The installed Study never leaves this canvas.
struct QuizView: View {
    @ObservedObject var studio: BottegaStudio
    var openExplore: () -> Void
    var openSaved: () -> Void
    var openSettings: () -> Void
    var openTwist: () -> Void

    @Environment(\.horizontalSizeClass) private var sizeClass

    var body: some View {
        VStack(alignment: .leading, spacing: StudioSpace.sm) {
            chrome
            if let notice = studio.document.loadNotice {
                errorPlate(notice)
            }
            switch studio.document.pendant {
            case .idle:
                idleCanvas
            case .installed(let study, let trials):
                installedCanvas(study: study, trials: trials)
            case .twinned(let study):
                twinnedCanvas(study: study)
            }
        }
        .padding(.horizontal, StudioSpace.md)
        .padding(.top, StudioSpace.sm)
        .padding(.bottom, StudioSpace.sm)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(StudioInk.background.ignoresSafeArea())
    }

    private var chrome: some View {
        VStack(alignment: .leading, spacing: StudioSpace.xs) {
            Text(jobTitle)
                .font(StudioType.display)
                .foregroundStyle(StudioInk.ink)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
            Text(nextTapLine)
                .font(StudioType.callout)
                .foregroundStyle(StudioInk.muted)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
            HStack(spacing: StudioSpace.xs) {
                Button(action: openExplore) {
                    Image(systemName: "magnifyingglass")
                        .frame(width: 44, height: 44)
                }
                .buttonStyle(StudioChipStyle())
                .accessibilityLabel("Open Explore")
                Button(action: openSaved) {
                    Image(systemName: "rectangle.stack")
                        .frame(width: 44, height: 44)
                }
                .buttonStyle(StudioChipStyle())
                .accessibilityLabel("Open Saved")
                Button(action: openSettings) {
                    Image(systemName: "gearshape")
                        .frame(width: 44, height: 44)
                }
                .buttonStyle(StudioChipStyle())
                .accessibilityLabel("Open Settings")
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var jobTitle: String {
        switch studio.document.pendant {
        case .idle:
            return "Hang a study"
        case .installed:
            return "Mate this study"
        case .twinned:
            return "This pair is filed"
        }
    }

    private var nextTapLine: String {
        switch studio.document.pendant {
        case .idle:
            return Bottega.installPool(in: studio.document).isEmpty
                ? "Save a pair, then install a hanging painting."
                : "Install a hanging painting, then tap its sibling."
        case .installed:
            return "Tap the trial painted by the same hand."
        case .twinned:
            return "Install another study when you like."
        }
    }

    private var idleCanvas: some View {
        VStack(alignment: .leading, spacing: StudioSpace.sm) {
            Image("mdl_EmptyHome")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: StudioRadius.card, style: .continuous))
                .clipped()
                .accessibilityHidden(true)
            Text("The studio is waiting")
                .font(StudioType.title)
                .foregroundStyle(StudioInk.ink)
                .fixedSize(horizontal: false, vertical: true)
            Text(Bottega.installPool(in: studio.document).isEmpty
                 ? "Save two paintings by one maker, then sit the quiz."
                 : "Install pins a free painting and lays four unlabeled tiles.")
                .font(StudioType.body)
                .foregroundStyle(StudioInk.muted)
                .fixedSize(horizontal: false, vertical: true)
            Button("Install") { studio.install() }
                .buttonStyle(StudioPillStyle())
                .disabled(Bottega.installPool(in: studio.document).isEmpty)
            if Bottega.installPool(in: studio.document).isEmpty {
                Button("Open Explore", action: openExplore)
                    .buttonStyle(StudioChipStyle())
                    .frame(maxWidth: .infinity)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
    }

    @ViewBuilder
    private func installedCanvas(study: Study, trials: [Trial]) -> some View {
        if sizeClass == .regular {
            HStack(alignment: .top, spacing: StudioSpace.md) {
                studyColumn(study, heroHeight: StudioSpace.xl * 7)
                    .frame(maxWidth: .infinity, alignment: .top)
                VStack(alignment: .leading, spacing: StudioSpace.sm) {
                    Text("Four paintings. One shares this hand.")
                        .font(StudioType.body)
                        .foregroundStyle(StudioInk.ink)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    trialRail(trials)
                        .frame(height: StudioSpace.xl * 4)
                    studioFooter
                }
                .frame(maxWidth: .infinity, alignment: .top)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        } else {
            GeometryReader { geo in
                let railH = phoneRailHeight(in: geo.size)
                let studyH = phoneStudyHeight(in: geo.size, rail: railH)
                VStack(alignment: .leading, spacing: StudioSpace.sm) {
                    studyColumn(study, heroHeight: studyH)
                    trialRail(trials)
                        .frame(height: railH)
                    studioFooter
                }
                .frame(width: geo.size.width, height: geo.size.height, alignment: .top)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    private func phoneRailHeight(in size: CGSize) -> CGFloat {
        let tile = max(StudioSpace.xl * 2, min(StudioSpace.xl * 3, size.height * 0.22))
        return tile
    }

    private func phoneStudyHeight(in size: CGSize, rail: CGFloat) -> CGFloat {
        let caption = StudioSpace.xl * 2
        let footer = StudioSpace.xl * 2
        let gaps = StudioSpace.sm * 3
        let leftover = size.height - rail - caption - footer - gaps
        let capped = min(leftover, size.width * 0.72)
        return max(StudioSpace.xl * 3, capped)
    }

    private func studyColumn(_ study: Study, heroHeight: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: StudioSpace.xs) {
            studyHero(study, height: heroHeight)
            Text(study.work.title)
                .font(StudioType.title)
                .foregroundStyle(StudioInk.ink)
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)
            Text(study.work.maker)
                .font(StudioType.body)
                .foregroundStyle(StudioInk.muted)
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func twinnedCanvas(study: Study) -> some View {
        VStack(alignment: .leading, spacing: StudioSpace.sm) {
            studyHero(study, height: StudioSpace.xl * 5)
            HStack(alignment: .center, spacing: StudioSpace.sm) {
                Image("mdl_SuccessMark")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 56, height: 56)
                    .clipped()
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: 0) {
                    Text("Twinned")
                        .font(StudioType.title)
                        .foregroundStyle(StudioInk.ink)
                    Text(study.work.title)
                        .font(StudioType.body)
                        .foregroundStyle(StudioInk.muted)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            statPlate(
                title: "Twins today",
                value: StudioFigures.count(
                    studio.document.twinMarks.filter { $0.dayKey == studio.dayKey }.count
                )
            )
            Button("Install next") { studio.install() }
                .buttonStyle(StudioPillStyle())
                .disabled(Bottega.installPool(in: studio.document).isEmpty)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    private func studyHero(_ study: Study, height: CGFloat) -> some View {
        WorkPlate(work: study.work, fallback: "mdl_CardBackdrop", corner: StudioRadius.card)
            .frame(maxWidth: .infinity)
            .frame(height: height)
            .clipped()
            .shadow(
                color: StudioRadius.lift.color,
                radius: StudioRadius.lift.radius,
                x: 0,
                y: StudioRadius.lift.y
            )
    }

    private func trialRail(_ trials: [Trial]) -> some View {
        HStack(alignment: .center, spacing: StudioSpace.sm) {
            ForEach(trials) { trial in
                Button {
                    commitMate(trial)
                } label: {
                    ZStack(alignment: .bottom) {
                        WorkPlate(
                            work: trial.work,
                            fallback: "mdl_ControlFace",
                            corner: StudioRadius.chip
                        )
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .clipped()
                        if trial.cooled {
                            Text("Cooled")
                                .font(StudioType.caption)
                                .foregroundStyle(StudioInk.ink)
                                .padding(.horizontal, StudioSpace.xs)
                                .padding(.vertical, StudioSpace.xs)
                                .background(StudioInk.surface)
                                .clipShape(RoundedRectangle(cornerRadius: StudioRadius.chip, style: .continuous))
                                .padding(StudioSpace.xs)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .contentShape(RoundedRectangle(cornerRadius: StudioRadius.chip, style: .continuous))
                }
                .buttonStyle(StudioTrialStyle(cooled: trial.cooled))
                .disabled(trial.cooled)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .frame(minWidth: 44, minHeight: 44)
                .accessibilityLabel(trial.cooled ? "Cooled tile" : "Mate this tile")
            }
        }
        .frame(maxWidth: .infinity)
        .frame(minHeight: 44)
    }

    private var studioFooter: some View {
        HStack(alignment: .top, spacing: StudioSpace.sm) {
            statPlate(
                title: "Twins",
                value: StudioFigures.count(studio.document.twinMarks.count)
            )
            Button(action: openTwist) {
                VStack(alignment: .leading, spacing: StudioSpace.xs) {
                    Text("How mate works")
                        .font(StudioType.caption)
                        .foregroundStyle(StudioInk.muted)
                    Text("Install then mate")
                        .font(StudioType.title)
                        .foregroundStyle(StudioInk.ink)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, minHeight: 72, alignment: .leading)
                .padding(StudioSpace.sm)
            }
            .buttonStyle(StudioChipStyle())
        }
        .frame(maxWidth: .infinity)
    }

    private func statPlate(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(StudioType.caption)
                .foregroundStyle(StudioInk.muted)
            Text(value)
                .font(StudioType.figure)
                .foregroundStyle(StudioInk.ink)
                .lineLimit(1)
        }
        .padding(StudioSpace.sm)
        .frame(maxWidth: .infinity, minHeight: 72, alignment: .leading)
        .background(StudioInk.surface)
        .clipShape(RoundedRectangle(cornerRadius: StudioRadius.card, style: .continuous))
    }

    private func errorPlate(_ notice: String) -> some View {
        VStack(alignment: .leading, spacing: StudioSpace.xs) {
            Text("Crate needed a restore")
                .font(StudioType.title)
                .foregroundStyle(StudioInk.ink)
            Text(notice)
                .font(StudioType.callout)
                .foregroundStyle(StudioInk.muted)
                .fixedSize(horizontal: false, vertical: true)
            Button("Keep going") { studio.dismissNotice() }
                .buttonStyle(StudioChipStyle())
        }
        .padding(StudioSpace.sm)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(StudioInk.surface)
        .clipShape(RoundedRectangle(cornerRadius: StudioRadius.card, style: .continuous))
    }

    private func commitMate(_ trial: Trial) {
        let before = studio.document.twinMarks.count
        studio.mate(trialId: trial.id)
        if studio.document.twinMarks.count > before {
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        }
    }
}
