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
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {
                Text("Calculez rapidement votre dosage")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 10) {
                        Image(systemName: "drop.fill")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.white)
                            .frame(width: 32, height: 32)
                            .background(.red)
                            .clipShape(Circle())
                        
                        Text("Glycémie actuelle")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(.primary)
                        
                        Spacer()
                        
                        Text("mg/dL")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    
                    HStack(spacing: 8) {
                        TextField("123", text: $taux)
                            .focused($focusedField, equals: .taux)
                            .keyboardType(.decimalPad)
                            .font(.title2)
                        
                        if !taux.isEmpty {
                            Button {
                                taux = ""
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.title3)
                                    .foregroundStyle(.tertiary)
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel("Effacer")
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 14)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    .onChange(of: taux, initial: false) {
                        calculateGlycemicAction()
                    }
                }
                .padding(16)
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                
                if !resultTitle.isEmpty && !resultText.isEmpty {
                    VStack(spacing: 8) {
                        Text(resultTitle)
                            .font(.headline)
                            .foregroundStyle(resultColor)
                        Text(resultText)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                }
                
                Spacer()
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Glycémie")
            .toolbar {
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
