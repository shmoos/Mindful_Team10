import SwiftUI

struct PickerView: View {
    @State var icons: [String] = ["cloud", "sun.max", "moon", "leaf", "snowflake"]
    @State var selectedIcon: String = "moon"
    @EnvironmentObject var backgroundManager: BackgroundManager
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(icons, id: \.self) { icon in
                Button {
                    selectedIcon = icon
                    backgroundManager.currentView = getBackgroundView(for: icon)
                } label: {
                    Image(systemName: icon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 15, height: 15)
                        .padding(10)
                        .background(selectedIcon == icon ? Color.blue.opacity(0.2) : Color.clear)
                        .clipShape(Circle())
                }
                .foregroundColor(selectedIcon == icon ? .blue : .primary)
                .padding(2)
            }
        }
        .background(
            Capsule()
                .fill(Color.secondary.opacity(0.1))
        )
        .padding(.trailing, 20)
    }
    
    func getBackgroundView(for icon: String) -> AnyView {
        switch icon {
        case "moon": return AnyView(MoonBackground())
        case "sun.max": return AnyView(SunBackground())
        case "cloud": return AnyView(CloudsBackground())
        case "leaf": return AnyView(NatureBackground())
        case "snowflake": return AnyView(SnowBackground())
        default: return AnyView(CloudsBackground())
        }
    }
}

#Preview {
    PickerView()
        .environmentObject(BackgroundManager())
}
