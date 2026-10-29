//
//  CalculView.swift
//  GlucideCheck
//
//  Created by Arthur Mondon on 03/05/2024.
//

import SwiftUI

struct CalculView: View {
    enum FocusedField: Int, CaseIterable {
        case carbsForReference, quantity
    }
    
    private static let defaultReference = "100"
    
    @EnvironmentObject var userSettings: UserSettings
    @State private var carbsForReference = ""
    @State private var quantity = ""
    @State private var referenceGrams = Self.defaultReference
    @State private var referenceDraft = Self.defaultReference
    @State private var showingReferencePopover = false
    @FocusState private var focusedField: FocusedField?
    @State private var showingInfo = false
    
    private var portionCarbsText: String {
        calculatePortionCarbs(
            carbs: carbsForReference,
            quantity: quantity,
            reference: referenceGrams
        )
    }
    
    private var referenceDisplay: String {
        formattedNumber(referenceGrams) ?? Self.defaultReference
    }
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                Text("Calculez facilement le nombre de glucides dans vos portions")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                carbsCard
                
                inputCard(
                    icon: "scalemass.fill",
                    iconColor: .blue,
                    title: Text("Quantité consommée")
                        .font(.subheadline.weight(.medium)),
                    text: $quantity,
                    placeholder: "0",
                    field: .quantity
                )
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Glucides dans la portion")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    if portionCarbsText.isEmpty {
                        Text("—")
                            .font(.system(size: 40, weight: .bold, design: .rounded))
                            .foregroundStyle(.green.opacity(0.35))
                    } else {
                        Text(portionCarbsText)
                            .font(.system(size: 40, weight: .bold, design: .rounded))
                            .foregroundStyle(.green)
                            .contentTransition(.numericText())
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                
                Spacer()
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Calculs")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingInfo.toggle()
                    } label: {
                        Image(systemName: "info.circle")
                    }
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Button {
                        resetFields()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            focusedField = .carbsForReference
                        }
                    } label: {
                        Image(systemName: "arrow.circlepath")
                    }
                    Spacer()
                    Button(action: moveToPreviousField) {
                        Image(systemName: "chevron.up")
                    }
                    Button(action: moveToNextField) {
                        Image(systemName: "chevron.down")
                    }
                    Button {
                        focusedField = nil
                    } label: {
                        Image(systemName: "keyboard.chevron.compact.down")
                    }
                }
            }
            .sheet(isPresented: $showingInfo) {
                InfoView(showingInfo: $showingInfo)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if userSettings.autoOpenKeyboardOnCalculs {
                    focusedField = .carbsForReference
                }
            }
        }
    }
    
    private var carbsCard: some View {
        inputCard(
            icon: "fork.knife",
            iconColor: .orange,
            title: carbsTitle,
            text: $carbsForReference,
            placeholder: "0",
            field: .carbsForReference
        )
    }
    
    private var carbsTitle: some View {
        HStack(spacing: 0) {
            Text("Glucides pour ")
                .font(.subheadline.weight(.medium))
            
            Button {
                referenceDraft = referenceGrams
                showingReferencePopover = true
            } label: {
                Text("\(referenceDisplay)g")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.orange)
                    .underline()
            }
            .buttonStyle(.plain)
            .popover(isPresented: $showingReferencePopover, arrowEdge: .bottom) {
                referencePopover
                    .presentationCompactAdaptation(.popover)
            }
            .accessibilityLabel("Modifier la référence \(referenceDisplay) grammes")
        }
    }
    
    private var referencePopover: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Référence")
                .font(.headline)
            
            Text("Valeur de l'emballage (ex. pour 100g)")
                .font(.caption)
                .foregroundStyle(.secondary)
            
            HStack(spacing: 8) {
                TextField("100", text: $referenceDraft)
                    .keyboardType(.decimalPad)
                    .font(.title3)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                
                Text("g")
                    .foregroundStyle(.secondary)
            }
            
            HStack(spacing: 12) {
                Button("Réinitialiser") {
                    referenceDraft = Self.defaultReference
                    referenceGrams = Self.defaultReference
                    showingReferencePopover = false
                }
                .disabled(referenceGrams == Self.defaultReference && referenceDraft == Self.defaultReference)
                
                Spacer()
                
                Button("OK") {
                    applyReferenceDraft()
                }
                .fontWeight(.semibold)
                .disabled(!isValidReference(referenceDraft))
            }
            .buttonStyle(.bordered)
        }
        .padding()
        .frame(minWidth: 260)
    }
    
    @ViewBuilder
    private func inputCard<Title: View>(
        icon: String,
        iconColor: Color,
        title: Title,
        text: Binding<String>,
        placeholder: String,
        field: FocusedField
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                    .frame(width: 32, height: 32)
                    .background(iconColor)
                    .clipShape(Circle())
                
                title
                
                Spacer()
                
                Text("g")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            HStack(spacing: 8) {
                TextField(placeholder, text: text)
                    .focused($focusedField, equals: field)
                    .keyboardType(.decimalPad)
                    .font(.title2)
                
                if !text.wrappedValue.isEmpty {
                    Button {
                        text.wrappedValue = ""
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
        }
        .padding(16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
    
    private func applyReferenceDraft() {
        guard isValidReference(referenceDraft),
              let formatted = formattedNumber(referenceDraft) else { return }
        referenceGrams = formatted
        showingReferencePopover = false
    }
    
    private func isValidReference(_ value: String) -> Bool {
        let formatter = NumberFormatter()
        formatter.locale = Locale.current
        formatter.numberStyle = .decimal
        guard let number = formatter.number(from: value)?.doubleValue else { return false }
        return number > 0
    }
    
    private func formattedNumber(_ value: String) -> String? {
        let formatter = NumberFormatter()
        formatter.locale = Locale.current
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        guard let number = formatter.number(from: value) else { return nil }
        return formatter.string(from: number)
    }
    
    private func calculatePortionCarbs(carbs: String, quantity: String, reference: String) -> String {
        let formatter = NumberFormatter()
        formatter.locale = Locale.current
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        
        guard let carbsValue = formatter.number(from: carbs)?.doubleValue,
              let qty = formatter.number(from: quantity)?.doubleValue,
              let referenceValue = formatter.number(from: reference)?.doubleValue,
              qty >= 0,
              referenceValue > 0 else {
            return ""
        }
        
        let result = (carbsValue * qty) / referenceValue
        guard let formatted = formatter.string(from: NSNumber(value: result)) else {
            return ""
        }
        return "\(formatted) g"
    }
    
    private func resetFields() {
        carbsForReference = ""
        quantity = ""
        referenceGrams = Self.defaultReference
        referenceDraft = Self.defaultReference
        focusedField = nil
    }
    
    private func moveToPreviousField() {
        guard let currentField = focusedField,
              let currentIndex = FocusedField.allCases.firstIndex(of: currentField),
              currentIndex > 0 else { return }
        focusedField = FocusedField.allCases[FocusedField.allCases.index(before: currentIndex)]
    }
    
    private func moveToNextField() {
        guard let currentField = focusedField,
              let currentIndex = FocusedField.allCases.firstIndex(of: currentField),
              currentIndex < FocusedField.allCases.count - 1 else { return }
        focusedField = FocusedField.allCases[FocusedField.allCases.index(after: currentIndex)]
    }
}

struct InfoView: View {
    @Binding var showingInfo: Bool
    
    var body: some View {
        VStack {
            Text("Informations")
                .font(.title)
                .fontWeight(.bold)
                .padding()
            
            Text("""
                Indiquez les glucides pour la référence de l'emballage (100g par défaut, modifiable), \
                puis la quantité consommée. Le calcul affiche automatiquement les glucides de votre portion.
                """)
                .padding()
            
            Spacer()
            Button {
                showingInfo = false
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
    CalculView()
        .environmentObject(UserSettings())
}
