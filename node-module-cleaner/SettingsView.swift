//
//  SettingsView.swift
//  node-module-cleaner
//
//  Created by CodeParth on 06/04/25.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var appSettings: AppSettings
    
    var body: some View {
        TabView {
            Form {
                Section(header: Text("Directories to Scan")) {
                    Toggle("Scan Library folder", isOn: $appSettings.scanLibraryFolder)
                    Toggle("Scan Documents folder", isOn: $appSettings.scanDocumentsFolder)
                    Toggle("Scan Downloads folder", isOn: $appSettings.scanDownloadsFolder)
                    Toggle("Scan Applications folder", isOn: $appSettings.scanApplicationsFolder)
                    Toggle("Scan Music folder", isOn: $appSettings.scanMusicFolder)
                    Toggle("Scan Movies folder", isOn: $appSettings.scanMoviesFolder)
                    Toggle("Scan Pictures folder", isOn: $appSettings.scanPicturesFolder)
                    Divider()
                    Toggle("Scan hidden folders (starting with .)", isOn: $appSettings.scanHiddenFolders)
                }
                
                Section(header: Text("About")) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Node Modules Cleaner")
                            .font(.headline)
                        Text("Version 1.0")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text("A utility for finding and removing node_modules directories to free up disk space.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.top, 4)
                    }
                    .padding(.vertical, 8)
                }
            }
            .padding()
            .tabItem {
                Label("Scanning", systemImage: "gearshape")
            }
        }
    }
}
