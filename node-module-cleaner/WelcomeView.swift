//
//  WelcomeView.swift
//  node-module-cleaner
//
//  Created by CodeParth on 06/04/25.
//

import SwiftUI

struct WelcomeView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "folder.badge.gearshape")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100, height: 100)
                .foregroundColor(.blue)
            
            Text("Node Modules Cleaner")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Find and clean up node_modules directories to reclaim disk space")
                .font(.headline)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            Text("Click 'Start Scan' in the sidebar to begin")
                .font(.subheadline)
                .padding(.top)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.windowBackgroundColor))
    }
}
