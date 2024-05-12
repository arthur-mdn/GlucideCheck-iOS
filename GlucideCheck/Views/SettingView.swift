//
//  SettingView.swift
//  GlucideCheck
//
//  Created by Arthur Mondon on 03/05/2024.
//

import SwiftUI

struct SettingView: View {
    @EnvironmentObject var userSettings: UserSettings

    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("Informations personnelles")) {
                    NavigationLink(destination: EditName()) {
                        Label(userSettings.firstName.isEmpty ? "Prénom" : userSettings.firstName, systemImage: "person")
                    }
                    NavigationLink(destination: EditBirthDate()) {
                        Label("Date de naissance", systemImage: "calendar")
                    }
                    NavigationLink(destination: EditWeight()) {
                        Label("Poids", systemImage: "scalemass")
                    }
                    NavigationLink(destination: EditGender()) {
                        Label("Sexe", systemImage: "figure.stand")
                    }
                }
                Section(header: Text("Informations médicales")) {
                    NavigationLink(destination: EditTarget()) {
                        Label("Cible", systemImage: "target")
                    }
                    NavigationLink(destination: EditInsulinInfluence()) {
                        Label("Influence insuline", systemImage: "cross.vial")
                    }
                    NavigationLink(destination: EditSugarInfluence()) {
                        Label("Influence sucre", systemImage: "cube")
                    }
                }
                Section(header: Text("Autres")) {
                    NavigationLink(destination: EditDarkMode()) {
                        Label("Mode sombre", systemImage: "lightbulb")
                    }
                    NavigationLink(destination: EditLanguage()) {
                        Label("Langue", systemImage: "flag")
                    }
                    NavigationLink(destination: EditAdvancedSettings()) {
                        Label("Configuration Avancée", systemImage: "gear")
                    }
                }
            }
            .navigationTitle("Paramètres")
        }
    }
}


#Preview {
    SettingView()
        .environmentObject(UserSettings())
}
