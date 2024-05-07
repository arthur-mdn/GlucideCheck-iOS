//
//  EditWeight.swift
//  GlucideCheck
//
//  Created by Arthur Mondon on 04/05/2024.
//

import SwiftUI

struct EditWeight: View {
    @EnvironmentObject var userSettings: UserSettings
    @Environment(\.presentationMode) var presentationMode
    @State private var weight: Double = 0.0

    var body: some View {
        Form {
            Section(header: Text("Nouveau poids")) {
                TextField("Poids (kg)", value: $weight, format: .number)
                    .keyboardType(.decimalPad)
            }
            Button("Enregistrer") {
                userSettings.weight = weight
                presentationMode.wrappedValue.dismiss()
            }
        }
        .navigationTitle("Modifier le poids")
        .onAppear {
            weight = userSettings.weight
        }
    }
}


#Preview {
    EditWeight()
}
