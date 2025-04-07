//
//  ScanProgressView.swift
//  node-module-cleaner
//
//  Created by CodeParth on 06/04/25.
//

import SwiftUI

struct ScanProgressView: View {
    let progress: Double
    let currentPath: String
    
    var body: some View {
        VStack(spacing: 30) {
            ProgressView(value: progress) {
                Text("Scanning for node_modules directories")
                    .font(.headline)
            }
            .progressViewStyle(LinearProgressViewStyle())
            .padding()
            
            VStack {
                Text("Currently scanning:")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text("~/\(currentPath)")
                    .font(.system(.body, design: .monospaced))
                    .foregroundColor(.primary)
            }
            
            if progress < 1.0 {
                ProgressView()
                    .scaleEffect(0.7)
            }
        }
        .frame(maxWidth: 400)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.windowBackgroundColor))
                .shadow(radius: 5)
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
