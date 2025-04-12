import SwiftUI

// Shared data model
class MoodData: ObservableObject {
    @Published var savedEntries: [MoodEntry] = [
        MoodEntry(date: Date().addingTimeInterval(-86400 * 6), moodRating: 80, moodEmoji: "😊", moodName: "Happy", textEntry: "Had a great day at work!"),
        MoodEntry(date: Date().addingTimeInterval(-86400 * 5), moodRating: 50, moodEmoji: "😐", moodName: "Neutral", textEntry: "Just an average day"),
        MoodEntry(date: Date().addingTimeInterval(-86400 * 4), moodRating: 40, moodEmoji: "😟", moodName: "Anxious", textEntry: "Feeling a bit stressed"),
        MoodEntry(date: Date().addingTimeInterval(-86400 * 3), moodRating: 60, moodEmoji: "😌", moodName: "Content", textEntry: "Enjoyed my morning walk"),
        MoodEntry(date: Date().addingTimeInterval(-86400 * 2), moodRating: 30, moodEmoji: "😢", moodName: "Sad", textEntry: "Missing my family"),
        MoodEntry(date: Date().addingTimeInterval(-86400 * 1), moodRating: 90, moodEmoji: "😄", moodName: "Excited", textEntry: "Got good news!"),
        MoodEntry(date: Date(), moodRating: 50, moodEmoji: "😐", moodName: "Neutral", textEntry: "Just started my day")
    ]
    
    func getEmotionData() -> [EmotionEntry] {
        return savedEntries.map { entry in
            EmotionEntry(
                date: entry.date,
                emotionLevel: entry.moodRating / 10,
                emotion: entry.moodName
            )
        }
    }
}

struct MoodEntry: Identifiable {
    let id = UUID()
    let date: Date
    let moodRating: Int
    let moodEmoji: String
    let moodName: String
    let textEntry: String?
    
    func toEmotionEntry() -> EmotionEntry {
        return EmotionEntry(
            date: date,
            emotionLevel: moodRating / 10,
            emotion: moodName
        )
    }
}

struct homeView: View {
    @StateObject private var moodData = MoodData()
    var sliderColor: Color {
        let normalizedValue = value / 100.0
        return Color(
            hue: normalizedValue * 0.33,
            saturation: 1.0,
            brightness: 1.0
        )
    }
    let calendar = Calendar.current
    let startDate = Date()
    
    var weekDates: [Date] {
        guard let weekStart = calendar.dateInterval(of: .weekOfMonth, for: startDate)?.start else { return [] }
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: weekStart) }
    }

    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "E\nd"
        return formatter
    }()
    
    @State private var value: Double = 50.0
    @State private var selectedDate: Date = Date()
    @State var showSheet: Bool = false
    @EnvironmentObject var backgroundManager: BackgroundManager
    @State var entry: Bool = true
    
    var filteredEntries: [MoodEntry] {
        return moodData.savedEntries.filter { entry in
            calendar.isDate(entry.date, inSameDayAs: selectedDate)
        }
    }
    
    var hasEntryForSelectedDate: Bool {
        return moodData.savedEntries.contains { entry in
            calendar.isDate(entry.date, inSameDayAs: selectedDate)
        }
    }

    var body: some View {
        ZStack {
            backgroundManager.currentView
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    Text("Mindful")
                        .font(.largeTitle)
                        .foregroundColor(.primary)
                        .fontWeight(.bold)
                        .padding(.leading, 25)
                    
                    Spacer()
                    
                    PickerView()
                        .frame(height: 44)
                        .hAlign(.trailing)
                }
                .padding(.top, 25)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(weekDates, id: \.self) { date in
                            VStack {
                                Text(dateFormatter.string(from: date))
                                    .multilineTextAlignment(.center)
                                    .font(.caption)
                                    .foregroundColor(calendar.isDate(date, inSameDayAs: selectedDate) ? .white : .primary)
                                    .padding(10)
                                    .background(calendar.isDate(date, inSameDayAs: selectedDate) ? Color.secondary.opacity(0.8) : Color.clear)
                                    .cornerRadius(10)
                                    .shadow(radius: 5)
                            }
                            .onTapGesture {
                                selectedDate = date
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
                
                if !hasEntryForSelectedDate {
                    Text("No Entry for Selected Date")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                        .vAlign(.center)
                        .hAlign(.center)
                } else {
                    ScrollView {
                        VStack(spacing: 20) {
                            ForEach(filteredEntries) { entry in
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color.secondary.opacity(0.8))
                                    .frame(width: 380, height: entry.textEntry != nil ? 120 : 80)
                                    .hAlign(.center)
                                    .overlay(
                                        VStack(alignment: .leading, spacing: 8) {
                                            HStack(spacing: 20) {
                                                ZStack{
                                                    Circle()
                                                        .stroke(getMoodColor(rating: entry.moodRating), lineWidth: 4)
                                                        .frame(width: 60, height: 60)
                                                        .padding(.horizontal, 25)
                                                    Text("\(entry.moodRating)")
                                                        .font(.system(size: 20))
                                                        .fontWeight(.semibold)
                                                        .foregroundStyle(.white)
                                                }
                                                VStack(alignment: .leading) {
                                                    Text(getMoodMessage(rating: entry.moodRating))
                                                        .font(.callout)
                                                        .fontWeight(.semibold)
                                                        .foregroundStyle(.white)
                                                }
                                            }
                                            .hAlign(.leading)
                                            
                                            if let text = entry.textEntry {
                                                Text(text)
                                                    .font(.callout)
                                                    .foregroundStyle(.white)
                                                    .padding(.horizontal, 25)
                                                    .lineLimit(2)
                                            }
                                        }
                                        .padding(.vertical, 10)
                                    )
                            }
                        }
                    }
                }
                
                Spacer()
                Button {
                    showSheet.toggle()
                } label: {
                    RoundedRectangle(cornerRadius: 50)
                        .fill(Color.white)
                        .frame(width: 75, height: 75)
                        .opacity(0.3)
                        .shadow(radius: 10)
                        .overlay(
                            Image(systemName: "pencil")
                                .font(.system(size: 32, weight: .bold))
                                .frame(width: 50, height: 50)
                                .opacity(0.8)
                                .foregroundColor(.primary)
                        )
                }
                .hAlign(.trailing)
                .padding()
                .sheet(isPresented: $showSheet) {
                    AddView(savedEntries: $moodData.savedEntries, selectedDate: selectedDate)
                }
            }
            .vAlign(.top)
        }
        .onAppear {
            selectedDate = Date()
        }
    }
    
    private func getMoodColor(rating: Int) -> Color {
        if rating < 40 {
            return Color.red.opacity(0.7)
        } else if rating < 70 {
            return Color.orange.opacity(0.7)
        } else {
            return Color.green.opacity(0.7)
        }
    }
    
    private func getMoodMessage(rating: Int) -> String {
        if rating < 40 {
            return "You felt bad. Try breathing exercises"
        } else if rating < 70 {
            return "You're doing okay.\nHave a warm cup of tea!"
        } else {
            return "You felt happy! Keep it up!"
        }
    }
    
    func currentTime() -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: Date())
    }
}

struct AddView: View {
    enum InputMode {
        case choice, text, analysis
    }
    
    var sliderColor: Color {
        let normalizedValue = value / 100.0
        return Color(
            hue: normalizedValue * 0.33,
            saturation: 1.0,
            brightness: 1.0
        )
    }
    
    @State private var inputMode: InputMode?
    @State private var textEntry: String = ""
    @State private var selectedMood: String = ""
    @State private var value: Double = 50.0
    @Environment(\.dismiss) private var dismiss
    @Binding var savedEntries: [MoodEntry]
    @State private var selectedEmoji: String = "😊"
    @State private var selectedEmotionName: String = "Happy"
    let selectedDate: Date
    
    let moods = ["😊 Happy", "😢 Sad", "😌 Calm", "😠 Angry", "😨 Anxious"]
    
    var body: some View {
        VStack {
            if inputMode == nil {
                VStack(spacing: 30) {
                    Text("How would you like to log?")
                        .font(.title2)
                        .bold()
                    
                    // Choice-based card
                    Button {
                        inputMode = .choice
                    } label: {
                        VStack {
                            Image(systemName: "face.smiling")
                                .font(.largeTitle)
                                .padding()
                            Text("Select emotions")
                                .font(.headline)
                        }
                        .frame(width: 200, height: 150)
                        .background(Color.white.opacity(0.2))
                        .shadow(radius: 5)
                        .cornerRadius(20)
                    }
                    
                    // Text entry card
                    Button {
                        inputMode = .text
                    } label: {
                        VStack {
                            Image(systemName: "pencil")
                                .font(.largeTitle)
                                .padding()
                            Text("Write your thoughts")
                                .font(.headline)
                        }
                        .frame(width: 200, height: 150)
                        .background(Color.white.opacity(0.2))
                        .shadow(radius: 5)
                        .cornerRadius(20)
                    }
                    
                    // Analysis card
                    Button {
                        inputMode = .analysis
                    } label: {
                        VStack {
                            Image(systemName: "brain.head.profile")
                                .font(.largeTitle)
                                .padding()
                            Text("Mental Health Analysis")
                                .font(.headline)
                        }
                        .frame(width: 200, height: 150)
                        .background(Color.white.opacity(0.2))
                        .shadow(radius: 5)
                        .cornerRadius(20)
                    }
                }
            } else if inputMode == .choice {
                VStack {
                    EmotionWheelView(value: $value, selectedEmoji: $selectedEmoji, selectedEmotionName: $selectedEmotionName)
                        .padding()
                        .vAlign(.center)
                    
                    Button(action: {
                        let newEntry = MoodEntry(
                            date: selectedDate,
                            moodRating: Int(value),
                            moodEmoji: selectedEmoji,
                            moodName: selectedEmotionName,
                            textEntry: nil
                        )
                        savedEntries.append(newEntry)
                        dismiss()
                    }) {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.blue)
                            .frame(width: 200, height: 50)
                            .overlay(
                                Text("Submit")
                                    .font(.headline)
                                    .foregroundColor(.white)
                            )
                    }
                    .padding()
                    
                    Button("Back") {
                        inputMode = nil
                    }
                    .padding()
                }
            } else if inputMode == .text {
                VStack {
                    Text("Journal your thoughts")
                        .font(.title2)
                        .bold()
                        .padding(20)
                    
                    Text("What's on your mind today?")
                        .font(.subheadline)
                        .padding()
                        .foregroundColor(.gray)
                    
                    TextEditor(text: $textEntry)
                        .font(.system(size: 20, weight: .medium, design: .rounded))
                        .frame(height: 200)
                        .padding()
                        .padding(.horizontal, 10)
                        .shadow(radius: 8)
                        .cornerRadius(12)
                        .padding()
                    
                    HStack {
                        Button(action: {
                            inputMode = nil
                        }) {
                            Text("Back")
                                .foregroundStyle(.black)
                                .bold()
                        }
                        
                        Spacer().frame(width: 30)
                        
                        Button("Save") {
                            let newEntry = MoodEntry(
                                date: Date(),
                                moodRating: Int(value),
                                moodEmoji: "📝",
                                moodName: "Journal Entry",
                                textEntry: textEntry
                            )
                            savedEntries.append(newEntry)
                            dismiss()
                        }
                        .disabled(textEntry.isEmpty)
                    }
                    .padding()
                    
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
                .vAlign(.top)
            } else {
                AnalysisAI()
                    .navigationTitle("Mental Health Analysis")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button("Back") {
                                inputMode = nil
                            }
                        }
                    }
            }
        }
        .animation(.default, value: inputMode)
    }
    
}

#Preview {
    homeView()
        .environmentObject(BackgroundManager())
}
