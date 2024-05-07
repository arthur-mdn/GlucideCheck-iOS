//
//  GlucideCheckApp.swift
//  GlucideCheck
//
//  Created by Arthur Mondon on 03/05/2024.
//

import SwiftUI

@main
struct GlucideCheckApp: App {
    @StateObject private var userSettings = UserSettings()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(userSettings)
        }
    }
}

class UserSettings: ObservableObject {
    @AppStorage("firstName") var firstName: String = ""
    @AppStorage("storedBirthDate") var storedBirthDate = Date.now.timeIntervalSinceReferenceDate
    var birthDate: Date {
        set {storedBirthDate = newValue.timeIntervalSinceReferenceDate}
        get {return Date(timeIntervalSinceReferenceDate: storedBirthDate)}
    }
    @AppStorage("weight") var weight: Double = 0.0
    @AppStorage("gender") var gender: String = "male"
    @AppStorage("targetMin") var targetMin: Int = 90
    @AppStorage("targetMax") var targetMax: Int = 180
    @AppStorage("insulinInfluence") var insulinInfluence: Double = 40.0
    @AppStorage("sugarInfluence") var sugarInfluence: Double = 15.0
    @AppStorage("darkMode") var darkMode: Int = 0
    @AppStorage("language") var language: String = "fr"
}
