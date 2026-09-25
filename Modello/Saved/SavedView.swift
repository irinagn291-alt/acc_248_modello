import SwiftUI

/// Role: TwinMarks and BreakMarks. Twinned studies rest here.
struct SavedView: View {
    @ObservedObject var studio: BottegaStudio
    var onClose: () -> Void
    var onExplore: () -> Void

    var body: some View {
        NavigationStack {
            Group {
                if studio.document.twinMarks.isEmpty && studio.document.breakMarks.isEmpty {
                    emptyPlate
                } else if let notice = studio.document.loadNotice, studio.document.works.isEmpty {
                    errorPlate(notice)
                } else {
                    populated
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(StudioInk.background.ignoresSafeArea())
            .navigationTitle("Saved")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: onClose) {
                        Image(systemName: "xmark")
                            .frame(width: 44, height: 44)
                    }
                    .buttonStyle(StudioChipStyle())
                    .accessibilityLabel("Close Saved")
                }
            }
        }
        .presentationBackground(StudioInk.background)
    }

    private var populated: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: StudioSpace.md) {
                HStack(alignment: .top, spacing: StudioSpace.sm) {
                    countPlate("Twins", studio.document.twinMarks.count)
                    countPlate("Breaks", studio.document.breakMarks.count)
                }
                Text(DayEdge.label(dayKey: studio.dayKey))
                    .font(StudioType.caption)
                    .foregroundStyle(StudioInk.muted)
                if !studio.document.twinMarks.isEmpty {
                    Text("Twinned studies")
                        .font(StudioType.title)
                        .foregroundStyle(StudioInk.ink)
                    ForEach(studio.document.twinMarks) { mark in
                        markRow(
                            title: title(for: mark.studyObjectId),
                            detail: "Mated to \(title(for: mark.trialObjectId)). \(DayEdge.label(dayKey: mark.dayKey))",
                            badge: "Twin"
                        )
                    }
                }
                if !studio.document.breakMarks.isEmpty {
                    Text("Reviewable misses")
                        .font(StudioType.title)
                        .foregroundStyle(StudioInk.ink)
                    ForEach(studio.document.breakMarks) { mark in
                        markRow(
                            title: title(for: mark.studyObjectId),
                            detail: "Missed \(title(for: mark.trialObjectId)). \(DayEdge.label(dayKey: mark.dayKey))",
                            badge: "Break"
                        )
                    }
                }
                Button("Retract newest") { studio.retract() }
                    .buttonStyle(StudioChipStyle())
                    .disabled(studio.document.twinMarks.isEmpty && studio.document.breakMarks.isEmpty)
            }
            .padding(.horizontal, StudioSpace.md)
            .padding(.top, StudioSpace.sm)
            .padding(.bottom, StudioSpace.lg)
        }
    }

    private var emptyPlate: some View {
        VStack(alignment: .leading, spacing: StudioSpace.sm) {
            Image("mdl_EmptyList")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .accessibilityHidden(true)
            Text("No marks yet")
                .font(StudioType.title)
                .foregroundStyle(StudioInk.ink)
            Text("Mate a sibling on Quiz. Misses land here so you can read them.")
                .font(StudioType.body)
                .foregroundStyle(StudioInk.muted)
            Button("Open Explore", action: onExplore)
                .buttonStyle(StudioPillStyle())
        }
        .padding(StudioSpace.md)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func errorPlate(_ notice: String) -> some View {
        VStack(alignment: .leading, spacing: StudioSpace.sm) {
            Text("Saved could not load")
                .font(StudioType.title)
                .foregroundStyle(StudioInk.ink)
            Text(notice)
                .font(StudioType.body)
                .foregroundStyle(StudioInk.muted)
            Button("Close", action: onClose)
                .buttonStyle(StudioPillStyle())
        }
        .padding(StudioSpace.md)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func countPlate(_ title: String, _ value: Int) -> some View {
        VStack(alignment: .leading, spacing: StudioSpace.xs) {
            Text(title)
                .font(StudioType.caption)
                .foregroundStyle(StudioInk.muted)
            Text(StudioFigures.count(value))
                .font(StudioType.figure)
                .foregroundStyle(StudioInk.ink)
        }
        .padding(StudioSpace.sm)
        .frame(maxWidth: .infinity, minHeight: 72, alignment: .leading)
        .background(StudioInk.surface)
        .clipShape(RoundedRectangle(cornerRadius: StudioRadius.card, style: .continuous))
    }

    private func markRow(title: String, detail: String, badge: String) -> some View {
        HStack(alignment: .top, spacing: StudioSpace.sm) {
            VStack(alignment: .leading, spacing: 0) {
                Text(title)
                    .font(StudioType.title)
                    .foregroundStyle(StudioInk.ink)
                    .lineLimit(2)
                Text(detail)
                    .font(StudioType.callout)
                    .foregroundStyle(StudioInk.muted)
                    .lineLimit(2)
            }
            Spacer(minLength: 0)
            Text(badge)
                .font(StudioType.caption)
                .foregroundStyle(StudioInk.ink)
                .padding(.horizontal, StudioSpace.sm)
                .padding(.vertical, StudioSpace.xs)
                .background(StudioInk.background)
                .clipShape(RoundedRectangle(cornerRadius: StudioRadius.chip, style: .continuous))
        }
        .padding(StudioSpace.sm)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(StudioInk.surface)
        .clipShape(RoundedRectangle(cornerRadius: StudioRadius.card, style: .continuous))
    }

    private func title(for objectId: String) -> String {
        if let work = studio.document.works.first(where: { $0.id == objectId }) {
            return work.title
        }
        if let work = studio.document.catalogCache.first(where: { $0.id == objectId }) {
            return work.title
        }
        return objectId
    }
}

/// Role: 3.6 Saved destination for the live driver. Same sheet as SavedView.
struct SavedHub: View {
    @ObservedObject var studio: BottegaStudio
    var onClose: () -> Void
    var onExplore: () -> Void

    var body: some View {
        SavedView(studio: studio, onClose: onClose, onExplore: onExplore)
    }
}
