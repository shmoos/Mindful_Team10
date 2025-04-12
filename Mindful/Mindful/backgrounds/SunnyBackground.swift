import SwiftUI

struct SunBackground: View {
    @State private var phase: CGFloat = 0
    let timer = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                Rectangle()
                    .fill(
                        AngularGradient(
                            gradient: Gradient(colors: [
                                Color.yellow.opacity(0.6),
                                Color.orange.opacity(0.5),
                                Color.pink.opacity(0.4),
                                Color.yellow.opacity(0.6)
                            ]),
                            center: .center,
                            angle: .degrees(phase * 45)
                        )
                    )
                    .animation(.linear(duration: 4).repeatForever(autoreverses: true), value: phase)
                    .blur(radius: 60)

                // Gentle golden overlay glow
                Rectangle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(stops: [
                                .init(color: Color.white.opacity(0.1), location: 0),
                                .init(color: .clear, location: 0.5),
                                .init(color: Color.orange.opacity(0.05), location: 1)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .blendMode(.overlay)

                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [
                                Color.yellow.opacity(0.25),
                                Color.clear
                            ]),
                            center: .center,
                            startRadius: 0,
                            endRadius: proxy.size.width * 0.45
                        )
                    )
                    .offset(x: cos(phase * 1.2) * 20, y: sin(phase * 1.5) * 20)
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
    SunBackground()
}
