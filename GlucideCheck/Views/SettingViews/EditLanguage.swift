//
//  EditLanguage.swift
//  GlucideCheck
//
//  Created by Arthur Mondon on 04/05/2024.
//

import SwiftUI

struct EditLanguage: View {
    @EnvironmentObject var userSettings: UserSettings
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        Form {
            Section(header: Text("Langue")) {
                Picker("Langue", selection: $userSettings.language) {
                    Text("Français").tag("fr")
                    Text("Anglais").tag("en")
                }
            }
            Button("Enregistrer") {
                presentationMode.wrappedValue.dismiss()
            }
        }
        .navigationTitle("Modifier la langue")
    }
}


#Preview {
    EditLanguage()
}
