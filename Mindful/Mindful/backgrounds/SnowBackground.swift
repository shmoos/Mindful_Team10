import SwiftUI

struct SnowBackground: View {
    @State private var phase: CGFloat = 0
    let timer = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()

    // ⛄️ Lighter, wintry night palette
    var angularColors: [Color] = [
        Color(red: 200/255, green: 220/255, blue: 255/255), // pale ice blue
        Color(red: 180/255, green: 200/255, blue: 240/255), // soft light blue
        Color.white.opacity(0.05),
        Color(red: 220/255, green: 230/255, blue: 255/255)  // snowy bluish white
    ]

    var glowOverlayStops: [Gradient.Stop] = [
        .init(color: Color.white.opacity(0.12), location: 0),
        .init(color: .clear, location: 0.5),
        .init(color: Color.white.opacity(0.06), location: 1)
    ]

    var moonPulseColors: [Color] = [
        Color.white.opacity(0.2),
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
                    .offset(x: cos(phase * 1.2) * 10, y: sin(phase * 1.5) * 10)
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
    SnowBackground()
}
