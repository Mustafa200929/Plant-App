//
//  addingplantView.swift
//  Challenge 3
//
//  Created by Adhavan senthil kumar on 15/11/25.
//

import SwiftUI

private struct ItemCenterPreferenceKey: PreferenceKey {
    static var defaultValue: [String: CGFloat] = [:]
    static func reduce(value: inout [String: CGFloat], nextValue: () -> [String : CGFloat]) {
        value.merge(nextValue(), uniquingKeysWith: { $1 })
    }
}

private func scaleForItem(containerWidth: CGFloat, itemMidX: CGFloat) -> CGFloat {
    let centerX = containerWidth / 2
    let maxDistance: CGFloat = 180
    let distance = min(abs(itemMidX - centerX), maxDistance)
    let normalized = 1 - (distance / maxDistance)
    
    return 0.9 + (1.35 - 0.9) * max(normalized, 0)
}

let PlantIcons: [String] = [
    "plant1","plant2","plant3","plant4","plant5","plant6","plant7"
]

struct addingplantView: View {
    
    // RETURN HANDLER
    var onReturn: (() -> Void)? = nil
    var onAddComplete: (() -> Void)? = nil
    
    // FORM FIELDS
    @State private var selectedIcon: String? = nil
    @State private var nickname: String = ""
    @State private var selectedSpecies = "None"
    
    // ERROR HANDLING
    @State private var showNameError = false
    
    @EnvironmentObject var plantVM: PlantViewModel
    @Environment(\.dismiss) private var dismiss
    
    let species = [
        "Aloe Vera","basil","Cactus","Water spinach",
        "Rubber plant","Jade plant","Spider plant","Snake plant"
    ]
    
    var body: some View {
        
        GeometryReader { proxy in
            let width = proxy.size.width
            let itemWidth: CGFloat = 140
            let itemHeight: CGFloat = 180
            let idealInset = (width - itemWidth) / 2
            let sideInset = idealInset * 0.8
            
            VStack {
                
                Text("Select an Icon")
                    .font(.title3.weight(.semibold))
                    .padding(.top, 60)
                    .onDisappear {
                        onReturn?()
                    }
                
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        
                        Spacer().frame(width: sideInset)
                        
                        ForEach(PlantIcons, id: \.self) { icon in
                            let isSelected = (selectedIcon == icon)
                            
                            VStack {
                                Image(icon)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 80, height: 80)
                                    .padding(16)
                                    .background(.thinMaterial)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(isSelected ? Color.accentColor : Color.secondary.opacity(0.2),
                                                    lineWidth: isSelected ? 3 : 1
                                                   )
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                            .scaleEffect(isSelected ? 1.08 : 1.0)
                            .shadow(color: isSelected ? Color.accentColor.opacity(0.25) : .clear,
                                    radius: isSelected ? 12 : 0)
                            .frame(width: itemWidth, height: itemHeight)
                            
                            
                            .background(
                                GeometryReader { itemProxy in
                                    Color.clear.preference(
                                        key: ItemCenterPreferenceKey.self,
                                        value: [icon: itemProxy.frame(in: .global).midX]
                                    )
                                }
                            )
                        }
                        
                        Spacer().frame(width: sideInset)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 32)
                    .onPreferenceChange(ItemCenterPreferenceKey.self) { centers in
                        let centerX = width / 2
                        if let nearest = centers.min(by: { abs($0.value - centerX) < abs($1.value - centerX) })?.key {
                            if selectedIcon != nearest {
                                withAnimation(.spring(response: 0.25, dampingFraction: 0.85)) {
                                    selectedIcon = nearest
                                }
                            }
                        }
                    }
                }
                
                // --- FORM ---
                Form {
                    Section {
                        VStack(alignment: .leading, spacing: 6) {
                            TextField("Enter a nickname for your plant", text: $nickname)
                                .padding()
                                .glassEffect(.clear, in: RoundedRectangle(cornerRadius: 10))
                            
                            if showNameError {
                                Text("Nickname is required.")
                                    .foregroundColor(.red)
                                    .font(.caption)
                            }
                        }
                    }
                    
                    Section {
                        Picker("Species", selection: $selectedSpecies) {
                            ForEach(species, id: \.self) {
                                Text($0)
                            }
                        }
                    }
                    
                }
                Button(action: addPlant) {
                    HStack(spacing: 10) {
                        Image(systemName: "leaf.fill")
                            .font(.system(size: 18, weight: .semibold))
                        Text("Add Plant")
                            .font(.headline)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 14)
                    .background(
                        LinearGradient(
                            colors: [.green.opacity(0.95), .cyan.opacity(0.95)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: .green.opacity(0.35), radius: 14, y: 6)
                    .shadow(color: .cyan.opacity(0.25), radius: 22, y: 12)
                }
                .disabled(isButtonDisabled)
                .opacity(isButtonDisabled ? 0.45 : 1)
                .padding(.bottom, 10)
                
                
                
            }
            .navigationTitle("Add a Plant!")
        }
        
        
    }     // --- LOGIC ---
        private var isButtonDisabled: Bool {
            nickname.trimmingCharacters(in: .whitespaces).isEmpty ||
            selectedSpecies == "None" ||
            selectedIcon == nil
        }
        
        private func addPlant() {
            if nickname.trimmingCharacters(in: .whitespaces).isEmpty {
                withAnimation { showNameError = true }
                return
            }
            guard let icon = selectedIcon else { return }
            
            plantVM.addPlant(
                plantName: nickname,
                plantType: selectedSpecies,
                plantIconName: icon
            )
            
            onAddComplete?()
            dismiss()
            
            
            if let info = plantVM.findPlantData(plantType: selectedSpecies) {
                Task { await plantVM.loadTips(for: info) }
            }
        }
    }


#Preview {
    NavigationStack {
        addingplantView()
            .environmentObject(PlantViewModel())
    }
}
