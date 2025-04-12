import SwiftUI



struct EmotionWheelView: View {
    let emotions = ["😊", "😢", "😠", "🤩", "😌", "😴", "😰", "🥰", "😐"]
    let emotionNames = ["Happy", "Sad", "Angry", "Excited", "Calm", "Tired", "Anxious", "Loved", "Normal"]
    
    @State private var rotation: Double = 0
    @State private var currentIndex: Int = 0
    @State private var isDragging = false
    @State private var value: Double = 50

    var sliderColor: Color {
        let normalizedValue = value / 100.0
        return Color(
            hue: normalizedValue * 0.33, // 0 (red) to 0.33 (green)
            saturation: 1.0,
            brightness: 1.0
        )
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Circular Slider
            // Emotion label with smooth transition
            Text(emotionNames[currentIndex])
                .font(.title)
                .fontWeight(.medium)
                .foregroundColor(.primary)
                .transition(.opacity)
                .id("emotionLabel-\(currentIndex)") // Force new view for animation
                .animation(.easeInOut(duration: 0.2), value: currentIndex)
                .padding(25)
            ZStack {
                // Track with gradient
                Circle()
                    .stroke(
                        AngularGradient(
                            gradient: Gradient(colors: [.blue, .purple, .pink, .blue]),
                            center: .center,
                            startAngle: .degrees(0),
                            endAngle: .degrees(360)
                        ),
                        style: StrokeStyle(lineWidth: 4, lineCap: .round)
                    )
                    .frame(width: 250, height: 250)
                    .opacity(0.7)
                
                // Center Emoji with background pulse effect
                Text(emotions[currentIndex])
                    .font(.system(size: 60))
                    .background(
                        Circle()
                            .fill(Color.blue.opacity(0.1))
                            .frame(width: 100, height: 100)
                            .scaleEffect(isDragging ? 1.2 : 1.0)
                            .animation(.easeInOut(duration: 0.3), value: isDragging)
                    )
                
                    .rotationEffect(.degrees(90))
                    
                // Knob with shadow
                Circle()
                    .fill(Color.white)
                    .shadow(color: .blue.opacity(0.5), radius: 5, x: 0, y: 0)
                    .frame(width: 24, height: 24)
                    .overlay(Circle().stroke(Color.blue, lineWidth: 3))
                    .offset(y: -125)
                    .rotationEffect(.degrees(rotation))
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                isDragging = true
                                let vector = CGVector(dx: value.location.x - 125, dy: value.location.y - 125)
                                let angle = atan2(vector.dy, vector.dx) * 180 / .pi
                                let positiveAngle = angle < 0 ? angle + 360 : angle
                                rotation = positiveAngle + 90
                                updateCurrentIndex()
                            }
                            .onEnded { _ in
                                isDragging = false
                            }
                    )
                
                // Subtle tick marks
                ForEach(0..<emotions.count, id: \.self) { index in
                    Capsule()
                        .fill(currentIndex == index ? Color.blue : Color.black)
                        .frame(width: 2, height: 10)
                        .offset(y: -122)
                        .rotationEffect(.degrees(Double(index) * (360 / Double(emotions.count))))
                }
            }
            .rotationEffect(.degrees(-90))
            
            
            
            HStack {
                Text("Mood Rate:")
                    .font(.title3)
                    .fontWeight(.medium)
                    .padding(.horizontal, -20)
                    .padding()
                
                Text("\(Int(value)) %")
                    .font(.title2)
                    .fontWeight(.medium)
                    .hAlign(.trailing)
            }.hAlign(.leading)
                .padding()
                
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(.systemGray6))
                    .frame(width: 360, height: 80)
                HStack {
                    Image("sad")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .padding()
                    
                    Slider(value: $value, in: 0...100, step: 1)
                        .accentColor(sliderColor)
                    
                    Image("happy")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .padding()
                }
            }
        }
        .padding()
        
        
    }
    
    private func updateCurrentIndex() {
        let sectorAngle = 360 / Double(emotions.count)
        let adjustedRotation = rotation.truncatingRemainder(dividingBy: 360)
        let newIndex = Int((adjustedRotation / sectorAngle).rounded()) % emotions.count
        
        if newIndex != currentIndex {
            currentIndex = newIndex
        }
    }
}
struct EmotionWheelView_Previews: PreviewProvider {
    static var previews: some View {
        EmotionWheelView()
    }
}
