//
//  EditAdvancedSettings.swift
//  GlucideCheck
//
//  Created by Arthur Mondon on 12/05/2024.
//

import SwiftUI

struct EditAdvancedSettings: View {
    @EnvironmentObject var userSettings: UserSettings
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        Form {
            Section(header: Text("Préférences de clavier")) {
                Toggle("Clavier auto pour Dosage", isOn: $userSettings.autoOpenKeyboardOnDosage)
                Toggle("Clavier auto pour Calculs", isOn: $userSettings.autoOpenKeyboardOnCalculs)
            }
        }
        .navigationTitle("Configuration Avancée")
    }
}

#Preview {
    EditAdvancedSettings()
        .environmentObject(UserSettings())
}
