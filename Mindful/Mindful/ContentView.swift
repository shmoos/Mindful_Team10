import SwiftUI

class BackgroundManager: ObservableObject {
    @Published var currentView: AnyView = AnyView(MoonBackground())
}

struct ContentView: View {
    @StateObject var backgroundManager = BackgroundManager()
    
    var body: some View {
        ZStack {
            backgroundManager.currentView // 👈 shows the current background

            TabView {
                homeView()
                    .tabItem {
                        Image(systemName: "bubble.and.pencil")
                    }
                breathing()
                    .tabItem {
                        Image(systemName: "figure.mind.and.body")
                    }
                profile()
                    .tabItem {
                        Image(systemName: "person.circle")
                    }
            }
            .accentColor(.primary)
            .environmentObject(backgroundManager) // 👈 makes it available app-wide
        }
        .ignoresSafeArea()
    }
}




#Preview {
    ContentView()
        .environmentObject(BackgroundManager())
}

// MARK: - View Extensions
extension View {
    func hAlign(_ alignment: Alignment) -> some View {
        self
            .frame(maxWidth: .infinity, alignment: alignment)
    }

    func vAlign(_ alignment: Alignment) -> some View {
        self
            .frame(maxHeight: .infinity, alignment: alignment)
    }

    func border(_ width: CGFloat, _ color: Color) -> some View {
        self
            .padding(.horizontal, 15)
            .padding(.vertical, 10)
            .background {
                RoundedRectangle(cornerRadius: 5, style: .continuous)
                    .stroke(color, lineWidth: width)
            }
    }

    func fillView(_ color: Color) -> some View {
        self
            .padding(.horizontal, 15)
            .padding(.vertical, 10)
            .background {
                RoundedRectangle(cornerRadius: 5, style: .continuous)
                    .fill(color)
            }
    }
}
