import SwiftUI

struct NatureBackground: View {
    @State private var phase: CGFloat = 0
    let timer = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                // 🌲 Main dark-green animated gradient
                Rectangle()
                    .fill(
                        AngularGradient(
                            gradient: Gradient(colors: [
                                Color(hue: 0.33, saturation: 0.7, brightness: 0.4, opacity: 0.6), // dark forest green
                                Color(hue: 0.28, saturation: 0.5, brightness: 0.35, opacity: 0.5), // olive
                                Color(hue: 0.25, saturation: 0.4, brightness: 0.3, opacity: 0.4), // mossy brown-green
                                Color(hue: 0.33, saturation: 0.7, brightness: 0.4, opacity: 0.6)
                            ]),
                            center: .center,
                            angle: .degrees(phase * 45)
                        )
                    )
                    .animation(.linear(duration: 4).repeatForever(autoreverses: true), value: phase)
                    .blur(radius: 55)

                // 🌫 Dark misty overlay
                Rectangle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(stops: [
                                .init(color: Color.black.opacity(0.06), location: 0),
                                .init(color: .clear, location: 0.5),
                                .init(color: Color.black.opacity(0.05), location: 1)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .blendMode(.overlay)

                // 🌞 Gentle golden glow
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [
                                Color(hue: 0.13, saturation: 0.8, brightness: 1.0, opacity: 0.08), // warm sunlight
                                Color.clear
                            ]),
                            center: .center,
                            startRadius: 0,
                            endRadius: proxy.size.width * 0.45
                        )
                    )
                    .offset(x: cos(phase * 1.2) * 25, y: sin(phase * 1.5) * 25)
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
    NatureBackground()
}
