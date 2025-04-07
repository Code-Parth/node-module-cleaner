//
//  node_module_cleanerApp.swift
//  node-module-cleaner
//
//  Created by CodeParth on 06/04/25.
//

import SwiftUI

@main
struct node_module_cleanerApp: App {
    @StateObject private var appSettings = AppSettings()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appSettings)
                .frame(minWidth: 800, minHeight: 600)
        }
        .commands {
            CommandGroup(replacing: .newItem) { }
            
            CommandMenu("Scan") {
                Button("Start Scan") {
                    NotificationCenter.default.post(name: NSNotification.Name("StartScan"), object: nil)
                }
                .keyboardShortcut("s", modifiers: .command)
            }
            
            SidebarCommands()
        }
        
        Settings {
            SettingsView()
                .environmentObject(appSettings)
                .frame(width: 500, height: 300)
        }
    }
}
