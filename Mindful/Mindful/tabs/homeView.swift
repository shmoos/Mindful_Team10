import SwiftUI

struct homeView: View {
    var sliderColor: Color {
        let normalizedValue = value / 100.0
        return Color(
            hue: normalizedValue * 0.33, // 0 (red) to 0.33 (green)
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
        formatter.dateFormat = "E\nd" // E = Mon, Tue… | d = 12, 13…
        return formatter
    }()
    
    @State private var value: Double = 50.0
    @State private var selectedDate: Date?
    @State var showSheet: Bool = false
    @EnvironmentObject var backgroundManager: BackgroundManager
    @State var entry: Bool = false


    var body: some View {
        ZStack {
            backgroundManager.currentView
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                                    Text("Mindful")
                                        .font(.largeTitle)
                                        .foregroundColor(.primary)
                                        .fontWeight(.semibold)
                                        .padding(.leading, 25)
                                    
                                    Spacer()
                                    
                                    PickerView() // Now appears as a compact row of icons
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
                                    .foregroundColor(selectedDate == date ? .white : .primary)
                                    .padding(10)
                                    .background(selectedDate == date ? Color.secondary.opacity(0.8) : Color.clear)
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
                if !entry {
                    Text("No Entry Today")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                        .vAlign(.center)
                        .hAlign(.center)
                } else {
                    Group{
                        VStack(alignment: .leading, spacing: 20) {
                            HStack {
                                Text(currentTime())
                                    .foregroundStyle(.secondary)
                                            
                                Text("•")
                                    .font(.headline)
                                    .padding(.horizontal, 6)
                                    .foregroundStyle(.secondary)
                                            
                                            Rectangle()
                                                .frame(height: 1)
                                                .foregroundStyle(.secondary)
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.secondary.opacity(0.3))
                                .frame(width: 380, height: 80)
                                .hAlign(.center)
                                .overlay(
                                Text("You felt happy today!")
                                )
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
                }.hAlign(.trailing).padding()
                    .sheet(isPresented: $showSheet){
                        AddView()
                    }

            }
            .vAlign(.top)
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
        case choice, text
    }
    
    @State private var inputMode: InputMode?
    @State private var textEntry: String = ""
    @State private var selectedMood: String = ""
    
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
                }
            } else if inputMode == .choice {
                VStack {
                    EmotionWheelView()
                    .padding()
                    .vAlign(.center)
                    
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.blue)
                        .frame(width: 200, height: 50)
                        .overlay(
                            Text("Submit")
                                .font(.headline)
                                .foregroundColor(.white)
                        )
                        .padding()
                    
                    Button("Back") {
                        inputMode = nil
                    }
                    .padding()
                }
            } else {
                VStack {
                    Text("Journal your thoughts")
                        .font(.title2)
                        .bold()
                        .padding(20)
                    
                    TextEditor(text: $textEntry)
                        .font(.system(size: 20, weight: .medium, design: .rounded))
                        .frame(height: 200)
                        .padding()
                        //.background(Color.gray.opacity(0.1))
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
                            // Save action
                        }
                        .disabled(textEntry.isEmpty)
                    }
                    .padding()
                }
                .vAlign(.top)
            }
        }
        .animation(.default, value: inputMode)
    }
    
}

#Preview {
    homeView()
        .environmentObject(BackgroundManager())
}
