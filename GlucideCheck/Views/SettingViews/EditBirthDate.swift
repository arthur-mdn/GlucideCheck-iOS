//
//  EditBirthDate.swift
//  GlucideCheck
//
//  Created by Arthur Mondon on 03/05/2024.
//

import SwiftUI

struct EditBirthDate: View {
    @EnvironmentObject var userSettings: UserSettings
    @Environment(\.presentationMode) var presentationMode
    @State private var birthDate: Date = Date()

    var body: some View {
        Form {
            Section(header: Text("Dates")) {
                            Text("Date enregistrée : \(userSettings.birthDate, formatter: dateFormatter)")
                            Text("Date sélectionnée : \(birthDate, formatter: dateFormatter)")
                        }
            Section(header: Text("Nouvelle date de naissance")) {
                DatePicker("Date de naissance", selection: $birthDate, displayedComponents: .date)
                    .datePickerStyle(GraphicalDatePickerStyle())
            }
            Button("Enregistrer") {
                userSettings.birthDate = birthDate
                presentationMode.wrappedValue.dismiss()
            }
        }
        .navigationTitle("Modifier la date de naissance")
        .onAppear {
            birthDate = userSettings.birthDate
        }
    }
}

let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .none
    return formatter
}()

#Preview {
    EditBirthDate()
        .environmentObject(UserSettings())
}
