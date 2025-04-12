//
//  profile.swift
//  hackityo
//
//  Created by Islom Shamsiev on 2025/4/12.
//

import SwiftUI

struct profile: View {
    @EnvironmentObject var backgroundManager: BackgroundManager
    var body: some View {
        ZStack{
            backgroundManager.currentView
            VStack{
                Text("Profile")
                    .font(.system(size: 32, weight: .bold, design: .default))
                    .foregroundColor(.white)
            }
        }
    }
}

#Preview {
    profile()
        .environmentObject(BackgroundManager())
}
