import SwiftUI
import Charts

struct profile: View {
    @EnvironmentObject var backgroundManager: BackgroundManager
    @StateObject private var moodData = MoodData()
    
    var body: some View {
        ZStack {
            backgroundManager.currentView
            ScrollView {
                VStack(spacing: 20) {
                    // Profile header
                    HStack(spacing: 20) {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .foregroundColor(.secondary.opacity(0.4))
                            .padding()
                        
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("@John Lark  ")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .fontDesign(.rounded)
                                    .foregroundColor(.white)
                                HStack {
                                    Image(systemName: "flame.fill")
                                        .foregroundColor(.orange)
                                        .fixedSize()
                                    
                                    Text("7 day streak")
                                       // .font(.caption)
                                        .font(.system(size: 15, weight: .light))
                                        .foregroundColor(.white)
                                }
                            }
                            
                            Text("Member since June 2023")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.8))
                            
     
                        }
                        
                        Spacer()
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white.opacity(0.3))
                            .padding()
                        
                    )
                    .shadow(radius: 3)
                    
                    // Emotion graph section
                    VStack(alignment: .leading) {
                        HStack {
                            Text("Emotional Wellbeing Chart")
                                .font(.headline)
                                .foregroundColor(.white)
                                .hAlign(.center)
                                .padding()
                                                        
                        }
                        .padding(.horizontal)
                        
                        // Line chart
                        Chart {
                            ForEach(moodData.getEmotionData()) { entry in
                                LineMark(
                                    x: .value("Date", entry.date, unit: .day),
                                    y: .value("Mood", entry.emotionLevel)
                                )
                                .interpolationMethod(.catmullRom)
                                .symbol {
                                    Circle()
                                        .fill(emotionColor(for: entry.emotionLevel))
                                        .frame(width: 12)
                                }
                                
                                PointMark(
                                    x: .value("Date", entry.date, unit: .day),
                                    y: .value("Mood", entry.emotionLevel)
                                )
                                .annotation(position: .top) {
                                    Text(entry.emotion.prefix(1))
                                        .font(.caption)
                                        .padding(4)
                                        .background(emotionColor(for: entry.emotionLevel).opacity(0.3))
                                        .clipShape(Circle())
                                }
                            }
                        }
                        .chartYScale(domain: 1...10)
                        .chartXAxis {
                            AxisMarks(values: .stride(by: .day)) { value in
                                AxisGridLine()
                                AxisValueLabel(format: .dateTime.weekday(.abbreviated),
                                               centered: true)
                                    .foregroundStyle(.white)
                            }
                        }
                        .chartYAxis {
                            AxisMarks(position: .leading) { value in
                                AxisGridLine()
                                AxisValueLabel()
                                    .foregroundStyle(.white)
                            }
                        }
                        .frame(height: 250)
                        .padding()
                        
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white.opacity(0.3))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.white.opacity(0.5), lineWidth: 1)
                            )
                            .padding()
                    )
                    .shadow(radius: 3)
                    
                    // Stats overview
                    HStack(spacing: 15) {
                        StatCard(value: "\(calculateAverageMood())", label: "Avg. Mood", icon: "face.smiling", color: .green)
                        StatCard(value: "\(moodData.savedEntries.count)", label: "Entries", icon: "square.and.pencil", color: .blue)
                        StatCard(value: "↑ \(calculateImprovement())%", label: "Improvement", icon: "chart.line.uptrend.xyaxis", color: .orange)
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
        }
    }
    
    private func calculateAverageMood() -> String {
        guard !moodData.savedEntries.isEmpty else { return "0.0" }
        let total = moodData.savedEntries.reduce(0) { $0 + $1.moodRating }
        let average = Double(total) / Double(moodData.savedEntries.count)
        return String(format: "%.1f", average)
    }
    
    private func calculateImprovement() -> Int {
        guard moodData.savedEntries.count >= 2 else { return 0 }
        let firstMood = moodData.savedEntries.first?.moodRating ?? 0
        let lastMood = moodData.savedEntries.last?.moodRating ?? 0
        let improvement = ((Double(lastMood) - Double(firstMood)) / Double(firstMood)) * 100
        return Int(improvement)
    }
    
    private func emotionColor(for level: Int) -> Color {
        switch level {
        case 1..<3: return .red
        case 3..<5: return .orange
        case 5..<7: return .yellow
        case 7..<9: return .mint
        case 9...10: return .green
        default: return .gray
        }
    }
}

struct StatCard: View {
    let value: String
    let label: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.white)
            Text(label)
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white.opacity(0.3))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.white.opacity(0.5), lineWidth: 1)
                )
        )
        .shadow(radius: 2)
    }
}

struct EmotionEntry: Identifiable {
    let id = UUID()
    let date: Date
    let emotionLevel: Int
    let emotion: String
}

#Preview {
    profile()
        .environmentObject(BackgroundManager())
}
