//
//  EditName.swift
//  GlucideCheck
//
//  Created by Arthur Mondon on 03/05/2024.
//

import SwiftUI

struct EditName: View {
    @EnvironmentObject var userSettings: UserSettings
    @Environment(\.presentationMode) var presentationMode
    @State private var firstName: String = ""

    var body: some View {
        Form {
            Section(header: Text("Nouveau prénom")) {
                TextField("Prénom", text: $firstName)
            }
            Button("Enregistrer") {
                userSettings.firstName = firstName
                presentationMode.wrappedValue.dismiss()
            }
        }
        .navigationTitle("Modifier le prénom")
        .onAppear {
            firstName = userSettings.firstName
        }
    }
}




struct EditName_Previews: PreviewProvider {
    static var previews: some View {
        EditName()
            .environmentObject(UserSettings())
    }
}
