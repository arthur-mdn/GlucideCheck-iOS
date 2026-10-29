//
//  CalculView.swift
//  GlucideCheck
//
//  Created by Arthur Mondon on 03/05/2024.
//

import SwiftUI

struct CalculView: View {
    enum FocusedField: Int, CaseIterable {
        case carbsPer100, quantity
    }
    
    @EnvironmentObject var userSettings: UserSettings
    @State private var carbsPer100 = ""
    @State private var quantity = ""
    @FocusState private var focusedField: FocusedField?
    @State private var showingInfo = false
    
    private var portionCarbsText: String {
        calculatePortionCarbs(carbsPer100: carbsPer100, quantity: quantity)
    }
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                Text("Calculez facilement le nombre de glucides dans vos portions")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                inputCard(
                    icon: "fork.knife",
                    iconColor: .orange,
                    title: "Glucides pour 100g",
                    text: $carbsPer100,
                    placeholder: "100",
                    field: .carbsPer100
                )
                
                inputCard(
                    icon: "scalemass.fill",
                    iconColor: .blue,
                    title: "Quantité consommée",
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
                            focusedField = .carbsPer100
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
                    focusedField = .carbsPer100
                }
            }
        }
    }
    
    @ViewBuilder
    private func inputCard(
        icon: String,
        iconColor: Color,
        title: String,
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
                
                Text(title)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.primary)
                
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
    
    private func calculatePortionCarbs(carbsPer100: String, quantity: String) -> String {
        let formatter = NumberFormatter()
        formatter.locale = Locale.current
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        
        guard let carbs = formatter.number(from: carbsPer100)?.doubleValue,
              let qty = formatter.number(from: quantity)?.doubleValue,
              qty >= 0 else {
            return ""
        }
        
        let result = (carbs * qty) / 100
        guard let formatted = formatter.string(from: NSNumber(value: result)) else {
            return ""
        }
        return "\(formatted) g"
    }
    
    private func resetFields() {
        carbsPer100 = ""
        quantity = ""
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
                Indiquez les glucides pour 100g (valeur de l'emballage), puis la quantité consommée. \
                Le calcul affiche automatiquement les glucides de votre portion.
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
