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
    @State private var resultTitle = ""
    @State private var resultDetail = ""
    @State private var resultColor = Color.green
    @State private var resultIcon = "checkmark.circle.fill"
    @State private var resultValue: Int?
    @State private var resultValueLabel = ""
    
    private var hasResult: Bool {
        !resultTitle.isEmpty
    }
    
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
                
                if hasResult {
                    resultCard
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
    
    private var resultCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: resultIcon)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                    .frame(width: 32, height: 32)
                    .background(resultColor)
                    .clipShape(Circle())
                
                Text(resultTitle)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(resultColor)
                
                Spacer()
            }
            
            if let resultValue {
                Text("\(resultValue)")
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .foregroundStyle(resultColor)
                    .contentTransition(.numericText())
                
                if !resultValueLabel.isEmpty {
                    Text(resultValueLabel)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.primary)
                }
            }
            
            if !resultDetail.isEmpty {
                Text(resultDetail)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(resultColor.opacity(0.25), lineWidth: 1)
        }
    }
    
    private func clearResult() {
        resultTitle = ""
        resultDetail = ""
        resultValue = nil
        resultValueLabel = ""
        resultIcon = "checkmark.circle.fill"
        resultColor = .green
    }
    
    private func setResult(
        title: String,
        detail: String,
        color: Color,
        icon: String,
        value: Int? = nil,
        valueLabel: String = ""
    ) {
        resultTitle = title
        resultDetail = detail
        resultColor = color
        resultIcon = icon
        resultValue = value
        resultValueLabel = valueLabel
    }
    
    func calculateGlycemicAction() {
        if taux.isEmpty {
            clearResult()
            return
        }
        
        guard let tauxValue = Double(taux) else {
            setResult(
                title: "Erreur de valeur",
                detail: "Veuillez entrer une valeur correcte.",
                color: .red,
                icon: "xmark.octagon.fill"
            )
            return
        }
        
        let targetMin = userSettings.targetMin
        let targetMax = userSettings.targetMax - 1
        let insulinInfluence = userSettings.insulinInfluence
        let sugarInfluence = userSettings.sugarInfluence
        var nbr = 0
        
        if tauxValue > 700 || (tauxValue <= 30 && tauxValue > 0) {
            setResult(
                title: "Glycémie incohérente",
                detail: "Un taux de \(Int(tauxValue)) mg/dL semble impossible.",
                color: .red,
                icon: "exclamationmark.triangle.fill"
            )
        } else if tauxValue <= 0 {
            setResult(
                title: "Erreur de valeur",
                detail: "Veuillez entrer une valeur correcte.",
                color: .red,
                icon: "xmark.octagon.fill"
            )
        } else if tauxValue > Double(targetMax) {
            var currentTaux = tauxValue
            while currentTaux > Double(targetMax) {
                currentTaux -= insulinInfluence
                nbr += 1
            }
            setResult(
                title: "Hyperglycémie",
                detail: "Pour atteindre environ \(Int(currentTaux)) mg/dL",
                color: oldValColor(oldVal: tauxValue),
                icon: "arrow.up.circle.fill",
                value: nbr,
                valueLabel: nbr > 1 ? "unités d'insuline" : "unité d'insuline"
            )
        } else if tauxValue < Double(targetMin) {
            var currentTaux = tauxValue
            while currentTaux < Double(targetMin) {
                currentTaux += sugarInfluence
                nbr += 1
            }
            setResult(
                title: "Hypoglycémie",
                detail: "Pour atteindre environ \(Int(currentTaux)) mg/dL",
                color: .red,
                icon: "arrow.down.circle.fill",
                value: nbr,
                valueLabel: nbr > 1 ? "carrés de sucre" : "carré de sucre"
            )
        } else {
            setResult(
                title: "Taux optimal",
                detail: "Cible : entre \(targetMin) et \(targetMax + 1) mg/dL",
                color: .green,
                icon: "checkmark.circle.fill"
            )
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
