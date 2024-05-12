//
//  EditDarkMode.swift
//  GlucideCheck
//
//  Created by Arthur Mondon on 04/05/2024.
//

import SwiftUI

struct EditDarkMode: View {
    @EnvironmentObject var userSettings: UserSettings
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        Form {
            Section(header: Text("Mode d'apparence")) {
                Picker("Mode d'apparence", selection: $userSettings.darkMode) {
                    Text("Clair").tag(0)
                    Text("Sombre").tag(1)
                    Text("Automatique").tag(2)
                }
                .pickerStyle(SegmentedPickerStyle())
            }
        }
        .navigationTitle("Modifier le mode d'apparence")
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
    EditDarkMode()
        .environmentObject(UserSettings())
}
