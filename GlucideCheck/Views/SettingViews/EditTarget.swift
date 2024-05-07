//
//  EditTarget.swift
//  GlucideCheck
//
//  Created by Arthur Mondon on 04/05/2024.
//

import SwiftUI

struct EditTarget: View {
    @EnvironmentObject var userSettings: UserSettings
    @Environment(\.presentationMode) var presentationMode
    @State private var targetMin: Int = 90
    @State private var targetMax: Int = 180
    @State private var errorMessage: String?
    @State private var showingInfoTarget = false
    
    var body: some View {
        NavigationStack{
            
            Form {
                Section(header: Text("Nouvelle cible")) {
                    TextField("Taux le plus bas", value: $targetMin, format: .number)
                        .keyboardType(.numberPad)
                    TextField("Taux le plus haut", value: $targetMax, format: .number)
                        .keyboardType(.numberPad)
                }
                if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                    }
                Button("Enregistrer") {
                    if targetMin < 70 || targetMin > 130 {
                        errorMessage = "Le taux minimal doit être entre 70 et 130."
                    } else if targetMax < 120 || targetMax > 200 {
                        errorMessage = "Le taux maximal doit être entre 120 et 200."
                    } else if targetMax <= targetMin {
                        errorMessage = "Le taux maximal doit être supérieur au taux minimal."
                    } else if targetMax - targetMin < Int(userSettings.insulinInfluence) {
                        errorMessage = "La différence entre le taux minimal et le taux maximal doit être au moins \(Int(userSettings.insulinInfluence))."
                    } else {
                        userSettings.targetMin = targetMin
                        userSettings.targetMax = targetMax
                        presentationMode.wrappedValue.dismiss()
                    }
                }

            }
            .navigationTitle("Modifier la cible")
            .onAppear {
                targetMin = userSettings.targetMin
                targetMax = userSettings.targetMax
            }
            .toolbar{
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingInfoTarget.toggle()
                    } label: {
                        Image(systemName: "info.circle")
                    }
                }
            }
            .sheet(isPresented: $showingInfoTarget) {
                InfoTargetView(showingInfoTarget: $showingInfoTarget)
            }
        }
        
    }
}

struct InfoTargetView: View {
    @Binding var showingInfoTarget: Bool
    
    var body: some View {
        
        VStack {
            Text("Informations")
                .font(.title)
                .fontWeight(.bold)
                .padding()
            
            Text("""
                **Cibles de glycémie recommandées**

                Le taux de glycémie optimal varie en fonction du type de diabète. Voici les recommandations générales :

                **Diabète de type 1**:
                - Avant les repas : 70 à 130 mg/dL
                - Après les repas : < 180 mg/dL
                - Au coucher : 90 à 150 mg/dL

                **Diabète de type 2**:
                - Avant les repas : 70 à 130 mg/dL
                - Après les repas : < 180 mg/dL
                - Au coucher : 100 à 140 mg/dL

                **Diabète gestationnel**:
                - Avant les repas : ≤ 95 mg/dL
                - Une heure après le repas : ≤ 140 mg/dL
                - Deux heures après le repas : ≤ 120 mg/dL

                Les cibles exactes peuvent varier en fonction de l'individu et des conseils de leur professionnel de la santé.
                La surveillance régulière de la glycémie est essentielle pour gérer le diabète efficacement.
                """)
                .padding()

            
            Spacer()
            Button {
                showingInfoTarget = false
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
    EditTarget()
        .environmentObject(UserSettings())
}
