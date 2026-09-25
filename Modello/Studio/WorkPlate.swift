import SwiftUI

/// Role: photo plate for a Work. Layout size comes from the parent; fill cannot spill.
struct WorkPlate: View {
    var work: Work?
    var fallback: String
    var corner: CGFloat

    var body: some View {
        RoundedRectangle(cornerRadius: corner, style: .continuous)
            .fill(StudioInk.surface)
            .overlay {
                ZStack {
                    Image(fallback)
                        .resizable()
                        .scaledToFill()
                    if let work {
                        HandPainting(work: work)
                    }
                    remoteFill
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipped()
            }
            .clipShape(RoundedRectangle(cornerRadius: corner, style: .continuous))
            .clipped()
            .accessibilityHidden(true)
    }

    @ViewBuilder
    private var remoteFill: some View {
        if let work, let url = URL(string: work.imageURL) {
            AsyncImage(url: url) { phase in
                if case .success(let image) = phase {
                    image
                        .resizable()
                        .scaledToFill()
                }
            }
        }
    }
}

/// Role: immediate oil wash so a study and four trials read as paintings without a crate.
private struct HandPainting: View {
    var work: Work

    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size
            wash(in: size)
                .frame(width: size.width, height: size.height)
                .clipped()
        }
        .allowsHitTesting(false)
    }

    @ViewBuilder
    private func wash(in size: CGSize) -> some View {
        switch work.id {
        case "1915.1.03":
            desertWash(size)
        case "1915.1.21":
            robeWash(size, robe: Color(red: 0.45, green: 0.12, blue: 0.10), ground: Color(red: 0.16, green: 0.10, blue: 0.08))
        case "1915.1.31":
            robeWash(size, robe: Color(red: 0.10, green: 0.10, blue: 0.12), ground: Color(red: 0.22, green: 0.18, blue: 0.12), chain: true)
        case "1915.1.32":
            robeWash(size, robe: Color(red: 0.18, green: 0.22, blue: 0.16), ground: Color(red: 0.12, green: 0.12, blue: 0.10), chain: true)
        case "1911.1.127":
            roomWash(size)
        case "1927.1.81":
            silkWash(size)
        case "1915.1.115":
            capWash(size)
        case "1914.1.47":
            forgeWash(size)
        default:
            hashedWash(size)
        }
    }

    private func desertWash(_ size: CGSize) -> some View {
        let w = size.width
        let h = size.height
        return ZStack(alignment: .top) {
            LinearGradient(
                colors: [
                    Color(red: 0.55, green: 0.72, blue: 0.86),
                    Color(red: 0.93, green: 0.78, blue: 0.48)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            Ellipse()
                .fill(Color(red: 0.62, green: 0.42, blue: 0.22))
                .frame(width: w * 1.2, height: h * 0.55)
                .offset(y: h * 0.58)
            RoundedRectangle(cornerRadius: StudioRadius.chip, style: .continuous)
                .fill(Color(red: 0.28, green: 0.18, blue: 0.10))
                .frame(width: w * 0.18, height: h * 0.32)
                .offset(x: -w * 0.12, y: h * 0.28)
            Ellipse()
                .fill(Color(red: 0.22, green: 0.34, blue: 0.18))
                .frame(width: w * 0.28, height: h * 0.40)
                .offset(x: w * 0.28, y: h * 0.22)
        }
    }

    private func robeWash(
        _ size: CGSize,
        robe: Color,
        ground: Color,
        chain: Bool = false
    ) -> some View {
        let w = size.width
        let h = size.height
        return ZStack {
            LinearGradient(colors: [ground.opacity(0.7), ground], startPoint: .top, endPoint: .bottom)
            RoundedRectangle(cornerRadius: StudioRadius.card, style: .continuous)
                .fill(robe)
                .frame(width: w * 0.72, height: h * 0.62)
                .offset(y: h * 0.22)
            Ellipse()
                .fill(Color(red: 0.86, green: 0.74, blue: 0.58))
                .frame(width: w * 0.34, height: h * 0.30)
                .offset(y: -h * 0.12)
            if chain {
                Capsule()
                    .fill(Color(red: 0.78, green: 0.62, blue: 0.22))
                    .frame(width: w * 0.36, height: h * 0.05)
                    .offset(y: h * 0.08)
            }
        }
    }

    private func roomWash(_ size: CGSize) -> some View {
        let w = size.width
        let h = size.height
        return ZStack(alignment: .leading) {
            Color(red: 0.86, green: 0.72, blue: 0.32)
            Rectangle()
                .fill(Color(red: 0.72, green: 0.82, blue: 0.78))
                .frame(width: w * 0.28, height: h)
            Ellipse()
                .fill(Color(red: 0.22, green: 0.16, blue: 0.12))
                .frame(width: w * 0.22, height: h * 0.55)
                .offset(x: w * 0.18, y: h * 0.18)
            Ellipse()
                .fill(Color(red: 0.90, green: 0.78, blue: 0.58))
                .frame(width: w * 0.24, height: h * 0.42)
                .offset(x: w * 0.52, y: h * 0.22)
        }
    }

    private func silkWash(_ size: CGSize) -> some View {
        let w = size.width
        let h = size.height
        return ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.55, green: 0.64, blue: 0.70),
                    Color(red: 0.28, green: 0.38, blue: 0.52)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            Ellipse()
                .fill(Color(red: 0.88, green: 0.76, blue: 0.62))
                .frame(width: w * 0.30, height: h * 0.28)
                .offset(y: -h * 0.16)
            RoundedRectangle(cornerRadius: StudioRadius.card, style: .continuous)
                .fill(Color(red: 0.36, green: 0.52, blue: 0.68))
                .frame(width: w * 0.70, height: h * 0.58)
                .offset(y: h * 0.22)
        }
    }

    private func capWash(_ size: CGSize) -> some View {
        let w = size.width
        let h = size.height
        return ZStack {
            Color(red: 0.14, green: 0.10, blue: 0.08)
            Ellipse()
                .fill(Color(red: 0.78, green: 0.62, blue: 0.42))
                .frame(width: w * 0.40, height: h * 0.36)
            Capsule()
                .fill(Color(red: 0.70, green: 0.16, blue: 0.14))
                .frame(width: w * 0.38, height: h * 0.18)
                .offset(y: -h * 0.22)
        }
    }

    private func forgeWash(_ size: CGSize) -> some View {
        let w = size.width
        let h = size.height
        return ZStack {
            Color(red: 0.10, green: 0.08, blue: 0.07)
            Ellipse()
                .fill(Color(red: 0.90, green: 0.42, blue: 0.12))
                .frame(width: w * 0.42, height: h * 0.28)
                .offset(y: h * 0.18)
            RoundedRectangle(cornerRadius: StudioRadius.chip, style: .continuous)
                .fill(Color(red: 0.28, green: 0.20, blue: 0.14))
                .frame(width: w * 0.22, height: h * 0.50)
                .offset(x: -w * 0.22, y: h * 0.10)
            RoundedRectangle(cornerRadius: StudioRadius.chip, style: .continuous)
                .fill(Color(red: 0.32, green: 0.22, blue: 0.16))
                .frame(width: w * 0.22, height: h * 0.46)
                .offset(x: w * 0.24, y: h * 0.12)
        }
    }

    private func hashedWash(_ size: CGSize) -> some View {
        let seed = work.id.utf8.reduce(into: 0) { $0 = ($0 &* 33) &+ Int($1) }
        let sky = Color(
            red: 0.35 + Double((seed >> 2) & 15) / 50,
            green: 0.28 + Double((seed >> 4) & 15) / 55,
            blue: 0.22 + Double((seed >> 6) & 15) / 60
        )
        let figure = Color(
            red: 0.40 + Double((seed >> 3) & 15) / 40,
            green: 0.18 + Double((seed >> 5) & 15) / 50,
            blue: 0.12 + Double((seed >> 1) & 15) / 55
        )
        let w = size.width
        let h = size.height
        return ZStack {
            LinearGradient(colors: [sky, figure.opacity(0.85)], startPoint: .top, endPoint: .bottom)
            Ellipse()
                .fill(Color(red: 0.84, green: 0.72, blue: 0.56))
                .frame(width: w * 0.32, height: h * 0.28)
                .offset(y: -h * 0.10)
            RoundedRectangle(cornerRadius: StudioRadius.card, style: .continuous)
                .fill(figure)
                .frame(width: w * 0.58, height: h * 0.48)
                .offset(y: h * 0.22)
        }
    }
}
