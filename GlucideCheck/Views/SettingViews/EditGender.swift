//
//  EditGender.swift
//  GlucideCheck
//
//  Created by Arthur Mondon on 04/05/2024.
//

import SwiftUI

struct EditGender: View {
    @EnvironmentObject var userSettings: UserSettings
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        Form {
            Section(header: Text("Nouveau sexe")) {
                Picker("Sexe", selection: $userSettings.gender) {
                    Text("Homme").tag("male")
                    Text("Femme").tag("female")
                }
                .pickerStyle(SegmentedPickerStyle())
            }
        }
        .navigationTitle("Modifier le sexe")
    }
}


#Preview {
    EditGender()
}
