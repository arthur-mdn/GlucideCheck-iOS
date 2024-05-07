//
//  EditInsulinInfluence.swift
//  GlucideCheck
//
//  Created by Arthur Mondon on 04/05/2024.
//

import SwiftUI

struct EditInsulinInfluence: View {
    @EnvironmentObject var userSettings: UserSettings
    @Environment(\.presentationMode) var presentationMode
    @State private var insulinInfluence: Double = 30.0
    @State private var errorMessage: String?

    var body: some View {
        Form {
            Section(header: Text("Influence insuline")) {
                TextField("Influence insuline", value: $insulinInfluence, format: .number)
                    .keyboardType(.decimalPad)
            }
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
            }
            Button("Enregistrer") {
                if insulinInfluence >= 20 && insulinInfluence <= 60 {
                    userSettings.insulinInfluence = insulinInfluence
                    presentationMode.wrappedValue.dismiss()
                } else {
                    errorMessage = "La valeur doit être comprise entre 20 et 60. La valeur par défaut est 30."
                }
            }
        }
        .navigationTitle("Modifier l'influence insuline")
        .onAppear {
            insulinInfluence = userSettings.insulinInfluence
        }
    }
}


#Preview {
    EditInsulinInfluence()
}
