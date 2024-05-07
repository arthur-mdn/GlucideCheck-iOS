//
//  CalculView.swift
//  GlucideCheck
//
//  Created by Arthur Mondon on 03/05/2024.
//

import SwiftUI

struct CalculView: View {
    enum FocusedField {
        case num1, num2, num3, num4
    }
    @State private var number1 = "100"
    @State private var number2 = ""
    @State private var number3 = ""
    @State private var number4 = ""
    @FocusState private var focusedField: FocusedField?
    @State private var showingInfo = false
    
    var body: some View {
        NavigationStack{

            VStack{
                HStack{
                    TextField("100g", text: $number1)
                        .focused($focusedField, equals: .num1)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .onChange(of: number1, initial: false) {
                                                    updateNumber4()
                                                }
                    
                    TextField("Glucides / " + number1 + "g", text: $number2)
                        .focused($focusedField, equals: .num2)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .onChange(of: number2, initial: false) {
                                                    updateNumber4()
                                                }
                    
                }
                HStack{
                    TextField("? g", text: $number3)
                        .focused($focusedField, equals: .num3)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .onChange(of: number3, initial: false) {
                                                    updateNumber4()
                                                }
                    
                    TextField("Auto", text: $number4)
                        .focused($focusedField, equals: .num4)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                }
                
                Button {
                    resetFields()
                } label: {
                    Image(systemName: "arrow.circlepath")
                }
                .buttonStyle(BorderedButtonStyle())
                .padding()
                
                Spacer()
            }
            .padding()
            .navigationTitle("Calculs")
            .toolbar{
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingInfo.toggle()
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
            .sheet(isPresented: $showingInfo) {
                InfoView(showingInfo: $showingInfo)
            }
        }
    
    }
    func updateNumber4() {
        number4 = calculateCrossProduct(num1: number1, num2: number2, num3: number3)
    }
    
    func calculateCrossProduct(num1: String, num2: String, num3: String) -> String {
        if let num1 = Double(num1), let num2 = Double(num2), let num3 = Double(num3) {
            let result = (num2 * num3) / num1
            return String(format: "%.1f", result) + "g"
        } else {
            return ""
        }
    }

    func resetFields() {
        number1 = "100"
        number2 = ""
        number3 = ""
        number4 = ""
        focusedField = nil
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
                Le système de calcul en croix vous aide à déterminer la quantité de glucides dans un aliment donné, \
                en utilisant le ratio de glucides pour 100g. Par défaut, le calcul est effectué pour 100g.
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
}
