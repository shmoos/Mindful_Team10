import SwiftUI

struct MoonBackground: View {
    @State private var phase: CGFloat = 0
    let timer = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()

    // MARK: - Dark night + yellow moon palette
    var angularColors: [Color] = [
        Color(red: 10/255, green: 15/255, blue: 40/255),
        Color(red: 30/255, green: 30/255, blue: 60/255).opacity(0.8),
        Color(red: 250/255, green: 235/255, blue: 170/255).opacity(0.1),
        Color(red: 10/255, green: 15/255, blue: 40/255)
    ]

    var glowOverlayStops: [Gradient.Stop] = [
        .init(color: Color.white.opacity(0.05), location: 0),
        .init(color: .clear, location: 0.5),
        .init(color: Color.yellow.opacity(0.03), location: 1)
    ]

    var moonPulseColors: [Color] = [
        Color.yellow.opacity(0.12),
        Color.clear
    ]

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                Rectangle()
                    .fill(
                        AngularGradient(
                            gradient: Gradient(colors: angularColors),
                            center: .center,
                            angle: .degrees(phase * 45)
                        )
                    )
                    .animation(.linear(duration: 4).repeatForever(autoreverses: true), value: phase)
                    .blur(radius: 60)

                Rectangle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(stops: glowOverlayStops),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .blendMode(.overlay)

                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: moonPulseColors),
                            center: .center,
                            startRadius: 0,
                            endRadius: proxy.size.width * 0.45
                        )
                    )
                    .offset(x: cos(phase * 1.2) * 15, y: sin(phase * 1.5) * 15)
                    .animation(.easeInOut(duration: 6).repeatForever(autoreverses: true), value: phase)
            }
            .drawingGroup()
            .onReceive(timer) { _ in
                phase += 0.01
            }
            .ignoresSafeArea()
        }
    }
}

#Preview {
    MoonBackground()
}
