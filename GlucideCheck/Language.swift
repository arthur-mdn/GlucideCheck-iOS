//
//  Langage.swift
//  GlucideCheck
//
//  Created by Arthur Mondon on 03/05/2024.
//

import Foundation

struct Language : Identifiable {
    let id = UUID()
    
    let name: String
    let description: String
    let image: String
}

extension Language {
    static let list : [Language] = [
        Language(name : "Kotlin", description : "Kotlin language", image : "stylo"),
        Language(name : "Dart", description : "Dart language", image : "stylo")
    ]
}
