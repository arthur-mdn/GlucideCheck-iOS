//
//  ContentView.swift
//  GlucideCheck
//
//  Created by Arthur Mondon on 03/05/2024.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var userSettings: UserSettings
    
    var body: some View {
        
        TabView {
            DosageView()
                .tabItem() {
                    Image(systemName: "cross.vial.fill")
                    Text("Dosage")
                }

            CalculView()
                .tabItem() {
                    Image(systemName: "plus.forwardslash.minus")
                    Text("Calculs")
                }

            SettingView()
                .tabItem() {
                    Image(systemName: "gearshape.fill")
                    Text("Paramètres")
                }

        }
        .preferredColorScheme(getColorScheme(for: userSettings.darkMode))
    }
    
    func getColorScheme(for mode: Int) -> ColorScheme? {
        switch mode {
        case 0:
            return .light
        case 1:
            return .dark
        case 2:
            return nil
        default:
            return nil
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(UserSettings())
}
