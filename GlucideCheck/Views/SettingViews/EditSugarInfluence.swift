//
//  EditSugarInfluence.swift
//  GlucideCheck
//
//  Created by Arthur Mondon on 04/05/2024.
//

import SwiftUI

struct EditSugarInfluence: View {
    @EnvironmentObject var userSettings: UserSettings
    @Environment(\.presentationMode) var presentationMode
    @State private var sugarInfluence: Double = 15.0
    @State private var errorMessage: String?

    var body: some View {
        Form {
            Section(header: Text("Influence sucre")) {
                TextField("Influence sucre", value: $sugarInfluence, format: .number)
                    .keyboardType(.decimalPad)
            }
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
            }
            Button("Enregistrer") {
                if sugarInfluence >= 5 && sugarInfluence <= 40 {
                    userSettings.sugarInfluence = sugarInfluence
                    presentationMode.wrappedValue.dismiss()
                } else {
                    errorMessage = "La valeur doit être comprise entre 5 et 40. La valeur par défaut est 15."
                }
            }
        }
        .navigationTitle("Modifier l'influence sucre")
        .onAppear {
            sugarInfluence = userSettings.sugarInfluence
        }
    }
}


#Preview {
    EditSugarInfluence()
}
