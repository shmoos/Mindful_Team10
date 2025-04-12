import SwiftUI

struct BreathingTechnique {
    let name: String
    let inhale: Double
    let hold: Double
    let exhale: Double
}

struct breathing: View {
    @State private var circleWidth: CGFloat = 225
    @State private var circleHeight: CGFloat = 225
    @State private var isRunning = false
    @State private var phaseText = "Inhale"
    @State private var techniqueIndex = 0
    @State private var animate = false
    
    @State private var isRotating = true
    @State private var rotationAngle: Double = 0
    private let continuousRotation = Animation.linear(duration: 2).repeatForever(autoreverses: false)
    
    @EnvironmentObject var backgroundManager: BackgroundManager
    
    let techniques: [BreathingTechnique] = [
        BreathingTechnique(name: "Box Breathing", inhale: 4, hold: 4, exhale: 4),
        BreathingTechnique(name: "4-7-8 Breathing", inhale: 4, hold: 7, exhale: 8),
        BreathingTechnique(name: "Resonant Breathing", inhale: 5, hold: 0, exhale: 5)
    ]
    
    var selectedTechnique: BreathingTechnique {
        techniques[techniqueIndex]
    }
    
    var body: some View {
        ZStack {
            backgroundManager.currentView
            VStack(spacing: 20) {
                // Music note button with improved rotation toggle
                Button {
                    isRotating.toggle()
                    if isRotating {
                        withAnimation(continuousRotation) {
                            rotationAngle += 360
                        }
                    }
                } label: {
                    Image(systemName: "music.note")
                        .font(.title)
                        .foregroundStyle(.white)
                        .rotationEffect(.degrees(rotationAngle))
                        .background(
                            Circle()
                                .fill(Color.secondary)
                                .opacity(0.5)
                                .frame(width: 75, height: 75)
                        )
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .padding(.trailing, 35)
                }
                .padding()
                .onAppear {
                    // Start rotating automatically when view appears
                    withAnimation(continuousRotation) {
                        rotationAngle += 360
                    }
                }

                // Breathing circle animation
                ZStack {
                    Circle()
                        .frame(width: circleWidth, height: circleHeight)
                        .foregroundColor(.white.opacity(0.4))
                        .scaleEffect(animate ? 1.0 : 0.5)
                        .animation(.easeInOut(duration: currentPhaseDuration), value: animate)
                    
                    Text(phaseText)
                        .font(.title)
                        .fontWeight(.semibold)
                        .fontDesign(.rounded)
                        .foregroundColor(.primary)
                        .animation(.easeInOut(duration: 0.3), value: phaseText)
                }
                .frame(height: 350)
                
                // Technique picker
                Picker("Breathing Technique", selection: $techniqueIndex) {
                    ForEach(techniques.indices, id: \.self) { index in
                        Text(techniques[index].name).tag(index)
                            .font(.title2)
                            .fontDesign(.rounded)
                            .foregroundStyle(Color.white)
                    }
                }
                .pickerStyle(.inline)
                .frame(width: 350)
                
                // Start/Stop button
                Button(isRunning ? "Stop" : "Start") {
                    isRunning.toggle()
                    if isRunning {
                        startBreathingCycle()
                    }
                }
                .font(.title3)
                .bold()
                .padding()
                .background(RoundedRectangle(cornerRadius: 16).fill(Color.blue))
                .foregroundColor(.white)
                .padding()
            }
        }
    }

    private var currentPhaseDuration: Double {
        switch phaseText {
        case "Inhale": return selectedTechnique.inhale
        case "Hold": return selectedTechnique.hold
        case "Exhale": return selectedTechnique.exhale
        default: return 1
        }
    }

    private func startBreathingCycle() {
        Task {
            while isRunning {
                phaseText = "Inhale"
                animate = true
                withAnimation(.easeInOut(duration: selectedTechnique.inhale)) {
                    circleWidth = 300
                    circleHeight = 300
                }
                try? await Task.sleep(nanoseconds: UInt64(selectedTechnique.inhale * 1_000_000_000))

                if selectedTechnique.hold > 0 {
                    phaseText = "Hold"
                    try? await Task.sleep(nanoseconds: UInt64(selectedTechnique.hold * 1_000_000_000))
                }

                phaseText = "Exhale"
                animate = false
                withAnimation(.easeInOut(duration: selectedTechnique.exhale)) {
                    circleWidth = 225
                    circleHeight = 225
                }
                try? await Task.sleep(nanoseconds: UInt64(selectedTechnique.exhale * 1_000_000_000))
            }
        }
    }
}

#Preview {
    breathing()
        .environmentObject(BackgroundManager())
}
