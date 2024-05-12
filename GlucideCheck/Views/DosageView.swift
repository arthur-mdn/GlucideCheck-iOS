//
//  DosageView.swift
//  GlucideCheck
//
//  Created by Arthur Mondon on 03/05/2024.
//

import SwiftUI

struct DosageView: View {
    enum FocusedField {
        case taux
    }
    @EnvironmentObject var userSettings: UserSettings
    @State private var taux = ""
    @FocusState private var focusedField: FocusedField?
    @State private var showingInfoGlycemie = false
    @State private var resultText = ""
    @State private var resultTitle = ""
    @State private var resultColor = Color.black
    
    var body: some View {
        NavigationStack{
            VStack{
                
                Section(header: Text("Glycémie actuelle")) {
                    TextField("123 mg / dL", text: $taux)
                        .focused($focusedField, equals: .taux)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .onChange(of: taux, initial: false) {
                            calculateGlycemicAction()
                        }
                }
            }
            .padding()
            
            if !resultTitle.isEmpty && !resultText.isEmpty {
                VStack {
                    Text(resultTitle)
                        .font(.headline)
                        .foregroundColor(resultColor)
                    Text(resultText)
                        .multilineTextAlignment(.center)
                        .padding()
                }
                .padding()
            }
            Spacer()
            
            .padding()
            .navigationTitle("Glycémie")
            .toolbar{
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingInfoGlycemie.toggle()
                    } label: {
                        Image(systemName: "info.circle")
                    }
                }
                ToolbarItem(placement: .keyboard) {
                    Spacer()
                }
                ToolbarItem(placement: .keyboard) {
                    Button {
                        focusedField = nil
                    } label: {
                        Image(systemName: "keyboard.chevron.compact.down")
                    }
                }
            }
            .sheet(isPresented: $showingInfoGlycemie) {
                InfoGlycemieView(showingInfoGlycemie: $showingInfoGlycemie)
            }
        }
        .onAppear {
            if userSettings.autoOpenKeyboardOnDosage {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    focusedField = .taux
                }
            }
        }
    }
    
    func calculateGlycemicAction() {
        if taux.isEmpty {
            resultTitle = ""
            resultText = ""
            resultColor = .black
            return
        }
        
        guard let tauxValue = Double(taux) else {
            resultTitle = "Erreur de valeur"
            resultText = "Veuillez entrer une valeur correcte !"
            resultColor = .red
            return
        }
        let targetMin = userSettings.targetMin
        let targetMax = userSettings.targetMax - 1
        let insulinInfluence = userSettings.insulinInfluence
        let sugarInfluence = userSettings.sugarInfluence
        var nbr = 0
        
        if tauxValue > 700 || (tauxValue <= 30 && tauxValue > 0) {
            resultTitle = "Alerte de glycémie incohérente"
            resultText = "Un taux de \(Int(tauxValue)) semble être impossible !"
            resultColor = .red
        } else if tauxValue <= 0 {
            resultTitle = "Erreur de valeur"
            resultText = "Veuillez entrer une valeur correcte !"
            resultColor = .red
        } else if tauxValue > Double(targetMax) {
            var currentTaux = tauxValue
            while currentTaux > Double(targetMax) {
                currentTaux -= insulinInfluence
                nbr += 1
            }
            resultTitle = "Hyperglycémie"
            resultText = "Nombre d'unités à faire : \(nbr) pour atteindre un taux de \(Int(currentTaux))."
            resultColor = oldValColor(oldVal: tauxValue)
        } else if tauxValue < Double(targetMin) {
            var currentTaux = tauxValue
            while currentTaux < Double(targetMin) {
                currentTaux += sugarInfluence
                nbr += 1
            }
            resultTitle = "Hypoglycémie"
            resultText = "Nombre de sucres à prendre : \(nbr) pour atteindre un taux de \(Int(currentTaux))."
            resultColor = .red
        } else {
            resultTitle = "Taux optimal"
            resultText = "Cible : Entre \(targetMin) et \(targetMax + 1)"
            resultColor = .green
        }
    }
    
    func oldValColor(oldVal: Double) -> Color {
        if oldVal < 200 {
            return .orange
        } else if oldVal < 280 {
            return .brown
        } else {
            return .red
        }
    }
}


struct InfoGlycemieView: View {
    @EnvironmentObject var userSettings: UserSettings
    @Binding var showingInfoGlycemie: Bool
    
    var body: some View {
        VStack {
            Text("Informations")
                .font(.title)
                .fontWeight(.bold)
                .padding()
            
            Text("""
                Exemple de valeur attendue :
                Pour 1,23 mg/dL, entrez 123.

                Vos informations médicales peuvent être modifiées dans les paramètres de l'application :

                Cible : Entre \(userSettings.targetMin) et \(userSettings.targetMax)

                Influence d'une unité d'insuline sur la glycémie : \(Int(userSettings.insulinInfluence))

                Influence d'un carré de sucre sur la glycémie : \(Int(userSettings.sugarInfluence))
                """)
                .padding()
            
            Spacer()
            Button {
                showingInfoGlycemie = false
            } label: {
                Text("Fermer")
            }
            .buttonStyle(BorderedButtonStyle())
            .padding()
        }
        .padding()
    }
}

#Preview {
    DosageView()
        .environmentObject(UserSettings())
}
