import SwiftUI

struct AnalysisAI: View {
    // MARK: – Questions for mental health assessment
    let questions = [
        "How have you been feeling lately—emotionally and physically?",
        "Have you been feeling more sad, anxious, or angry than usual?",
        "Have you lost interest in things you usually enjoy?",
        "How have you been sleeping?",
        "Do you feel rested when you wake up?",
        "Have you had trouble falling or staying asleep?",
        "Has your appetite changed recently?",
        "Have you noticed any weight gain or loss?",
        "Have you been experiencing headaches, stomachaches, or other physical symptoms?",
        "Do you feel overwhelmed or stressed frequently?"
    ]
    
    // MARK: – State
    @State private var currentQuestionIndex = 0
    @State private var responses: [String] = Array(repeating: "", count: 10)
    @State private var showingResults = false
    @State private var diagnosis = ""
    @State private var isLoading = false
    
    var body: some View {
        ZStack {
            VStack(spacing: 30) {
                if !showingResults {
                    // QUESTION UI
                    Text("Question \(currentQuestionIndex + 1) of \(questions.count)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text(questions[currentQuestionIndex])
                        .font(.title2)
                        .fontWeight(.medium)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    ZStack {
                        TextEditor(text: $responses[currentQuestionIndex])
                            .padding()
                            .frame(width: 400, height: 250)
                            .shadow(radius: 8)
                            .font(.system(size: 20, weight: .medium, design: .rounded))
                            .padding()
                            .cornerRadius(12)
                            .padding()
                    }
                    .frame(width: 345, height: 200)
                    
                    Spacer()
                    
                    HStack(spacing: 20) {
                        if currentQuestionIndex > 0 {
                            Button {
                                withAnimation {
                                    currentQuestionIndex -= 1
                                }
                            } label: {
                                HStack(spacing: 8) {
                                    Image(systemName: "chevron.left")
                                    Text("Previous")
                                }
                                .frame(minWidth: 120)
                            }
                            .buttonStyle(.bordered)
                            .controlSize(.large)
                            .tint(.gray)
                        }
                        
                        if currentQuestionIndex < questions.count - 1 {
                            Button {
                                withAnimation {
                                    currentQuestionIndex += 1
                                }
                            } label: {
                                HStack(spacing: 8) {
                                    Text("Next")
                                    Image(systemName: "chevron.right")
                                }
                                .frame(minWidth: 120)
                            }
                            .buttonStyle(.borderedProminent)
                            .controlSize(.large)
                            .tint(.blue)
                            .disabled(responses[currentQuestionIndex].isEmpty)
                        } else {
                            Button {
                                submitResponses()
                            } label: {
                                HStack(spacing: 8) {
                                    Image(systemName: "brain.head.profile")
                                    Text("Analyze")
                                }
                                .frame(minWidth: 150)
                            }
                            .buttonStyle(.borderedProminent)
                            .controlSize(.large)
                            .tint(.green)
                            .disabled(responses[currentQuestionIndex].isEmpty)
                        }
                    }
                    .padding(.bottom, 40)
                    
                } else {
                    // RESULTS UI
                    VStack(spacing: 25) {
                        Image(systemName: "brain.head.profile")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                        
                        Text("Your Mental Health Analysis")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        ScrollView {
                            Text(diagnosis)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.gray.opacity(0.1))
                                )
                        }
                        
                        Button("Start Over") {
                            resetAssessment()
                        }
                        .buttonStyle(.bordered)
                        .padding(.top)
                    }
                    .padding()
                }
            }
            .padding()
            
            // LOADING OVERLAY
            if isLoading {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                VStack(spacing: 20) {
                    ProgressView()
                        .scaleEffect(1.5)
                    Text("Analyzing your responses...")
                        .font(.headline)
                        .foregroundColor(.white)
                }
                .padding(30)
                .background(RoundedRectangle(cornerRadius: 10).fill(Color(.systemBackground)))
                .shadow(radius: 10)
            }
        }
    }
    
    // MARK: – Submit & call AI
    func submitResponses() {
        isLoading = true
        // build prompt
        var promptText = """
        Analyze these responses to mental health questions and provide a brief assessment with recommendations and provide easy to fix solutions while showing care to the user:

        """
        for (i, resp) in responses.enumerated() {
            promptText += "Question: \(questions[i])\nResponse: \(resp)\n\n"
        }
        callAIAnalysis(with: promptText)
    }

    func callAIAnalysis(with prompt: String) {
        guard !prompt.isEmpty else { return }
        
        let url = URL(string: "https://openrouter.ai/api/v1/chat/completions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("your-api-key",
                       forHTTPHeaderField: "Authorization")
        request.addValue("application/json",
                       forHTTPHeaderField: "Content-Type")
        
        let requestBody: [String: Any] = [
            "model": "openai/gpt-3.5-turbo",
            "messages": [
                ["role": "system",
                 "content": "You are a helpful assistant trained to analyze mental health responses. Please format your response with clear headings but without using Markdown formatting like asterisks (**) for bold text."],
                ["role": "user",
                 "content": prompt]
            ],
            "max_tokens": 500,
            "temperature": 0.7
        ]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: requestBody, options: [])
            request.httpBody = jsonData
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                DispatchQueue.main.async {
                    self.isLoading = false
                    defer { self.showingResults = true }

                    if let error = error {
                        self.diagnosis = "Network error: \(error.localizedDescription)"
                        return
                    }

                    guard let httpResponse = response as? HTTPURLResponse,
                          let data = data else {
                        self.diagnosis = "Invalid server response"
                        return
                    }

                    if httpResponse.statusCode != 200 {
                        self.diagnosis = "HTTP error \(httpResponse.statusCode)"
                        return
                    }

                    do {
                        let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
                        
                        if let json = jsonObject as? [String: Any],
                           let choices = json["choices"] as? [[String: Any]],
                           let message = choices.first?["message"] as? [String: Any],
                           let text = message["content"] as? String {
                            let cleanedText = self.cleanMarkdownFormatting(text.trimmingCharacters(in: .whitespacesAndNewlines))
                            self.diagnosis = cleanedText
                        } else if let json = jsonObject as? [String: Any],
                                  let error = json["error"] as? [String: Any],
                                  let message = error["message"] as? String {
                            self.diagnosis = "API Error: \(message)"
                        } else {
                            self.diagnosis = "Unexpected response format."
                        }
                    } catch {
                        self.diagnosis = "JSON decoding error: \(error.localizedDescription)"
                    }
                }
            }.resume()
        } catch {
            DispatchQueue.main.async {
                self.diagnosis = "Failed to create request: \(error.localizedDescription)"
                self.isLoading = false
                self.showingResults = true
            }
        }
    }

    private func cleanMarkdownFormatting(_ text: String) -> String {
        return text.replacingOccurrences(of: "\\*\\*", with: "", options: .regularExpression)
    }
            
        
    
    // MARK: – Reset
    func resetAssessment() {
        withAnimation {
            currentQuestionIndex = 0
            responses = Array(repeating: "", count: questions.count)
            diagnosis = ""
            showingResults = false
        }
    }
}

struct AnalysisAI_Previews: PreviewProvider {
    static var previews: some View {
        AnalysisAI()
    }
}
