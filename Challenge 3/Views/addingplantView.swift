import SwiftUI
import SwiftData

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
    "plant1", "plant2", "plant3", "plant4", "plant5", "plant6", "plant7"
]

struct addingplantView: View {
    var onReturn: (() -> Void)? = nil
    var onAddComplete: (() -> Void)? = nil
    @State private var selectedIcon: String? = nil
    @State private var nickname: String = ""
    @State private var selectedSpecies: String = "Select Seed"
    @State private var showNameError = false
    @EnvironmentObject var plantVM: PlantViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) var colourScheme
    @Environment(\.modelContext) var modelContext
    @Query var plants: [Plant]
    
    
    let species = [
        "Select Seed",
        "Aloe Vera",
        "Basil",
        "Cactus",
        "Water Spinach",
        "Rubber Plant",
        "Jade Plant",
        "Spider Plant",
        "Snake Plant"
    ]
    
    var body: some View {
        NavigationStack{
            ZStack{
                if colourScheme == .dark {
                    LinearGradient(
                        colors: [
                            Color(hex: "0D1B2A"),
                            Color(hex: "1B263B"),
                            Color(hex: "415A77")
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .ignoresSafeArea()
                }else{
                    LinearGradient(
                        colors: [
                            Color(hex: "D7EEFF"),
                            Color(hex: "B7D8FF"),
                            Color(hex: "97C1FF")
                        ],
                        startPoint: .top, endPoint: .bottom
                    )
                    .ignoresSafeArea()
                }
                GeometryReader { proxy in
                    let width = proxy.size.width
                    let itemWidth: CGFloat = 140
                    let itemHeight: CGFloat = 180
                    let idealInset = (width - itemWidth) / 2
                    let sideInset = idealInset * 0.8
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(alignment: .leading,spacing: 0) {
                            
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 18) {
                                    Spacer().frame(width: sideInset)
                                    
                                    ForEach(PlantIcons, id: \.self) { icon in
                                        let isSelected = (selectedIcon == icon)
                                        
                                        VStack {
                                            Image(icon)
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 80, height: 80)
                                                .padding(18)
                                                .background(.ultraThinMaterial)
                                                .clipShape(RoundedRectangle(cornerRadius: 20))
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 20)
                                                        .stroke(
                                                            isSelected ? Color.accentColor : Color.secondary.opacity(0.2),
                                                            lineWidth: isSelected ? 3 : 1
                                                        )
                                                )
                                        }
                                        .scaleEffect(isSelected ? 1.08 : 1.0)
                                        .shadow(
                                            color: isSelected ? Color.accentColor.opacity(0.25) : .clear,
                                            radius: isSelected ? 14 : 0,
                                            y: isSelected ? 8 : 0
                                        )
                                        .frame(width: itemWidth, height: itemHeight)
                                        .contentShape(Rectangle())
                                        .onTapGesture {
                                            withAnimation(.spring(response: 0.25, dampingFraction: 0.85)) {
                                                selectedIcon = icon
                                            }
                                        }
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
                                .padding(.vertical, 28)
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
                            
                            VStack(alignment: .leading, spacing: 18) {
                                VStack(alignment: .leading, spacing: 8) {
                                    TextField("Nickname", text: $nickname)
                                        .textInputAutocapitalization(.words)
                                        .padding()
                                        .glassEffect(
                                            .regular.interactive().tint(
                                                .green.opacity(nickname == "" ? 0.0 : 0.12)
                                            )
                                        )
                                        .animation(.easeInOut(duration: 0.25), value: nickname)
                                    
                                    if showNameError {
                                        Text("Nickname is required.")
                                            .foregroundStyle(.red)
                                            .font(.caption)
                                            .padding(.leading, 4)
                                    }
                                }
                                
                                VStack(alignment: .leading, spacing: 6) {
                                    Picker("Plant", selection: $selectedSpecies) {
                                        ForEach(species, id: \.self) { item in
                                            Text(item)
                                        }
                                    }
                                    .padding()
                                    .pickerStyle(.menu)
                                    .glassEffect(
                                        .regular.interactive().tint(
                                            .green.opacity(selectedSpecies == "Select Seed" ? 0.0 : 0.12)
                                        )
                                    )
                                    .animation(.easeInOut(duration: 0.25), value: selectedSpecies)
                                }
                            }
                            .padding(.horizontal, 24)
                            .padding(.top, 8)
                            
                            Spacer()
                            
                            
                        }
                    }
                }
            } .navigationTitle("New Plant")
                .toolbar{
                    ToolbarItem(placement: .confirmationAction) {
                        Button("New Plant", systemImage: "checkmark"){
                            addPlant()
                        } .disabled(isButtonDisabled)
                    }
                }
        }
       
    }
    
    
    private var isButtonDisabled: Bool {
        nickname.trimmingCharacters(in: .whitespaces).isEmpty ||
        selectedSpecies == "Select Seed" ||
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
            plantIconName: icon,
            context: modelContext,
            plants: plants
        )
        
        onAddComplete?()
        dismiss()
        
        if let info = plantVM.findPlantData(plantType: selectedSpecies) {
            Task { await plantVM.loadTips(for: info) }
        }
    }
}

#Preview("Add Plant") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Plant.self, configurations: config)
    
    final class PreviewPlantViewModel: PlantViewModel {
        override func addPlant(plantName: String, plantType: String, plantIconName: String, context: ModelContext, plants: [Plant]) {}
        override func findPlantData(plantType: String) -> PlantInfo? { nil }
        override func loadTips(for info: PlantInfo) async {}
    }
    
    let vm = PreviewPlantViewModel()
    
    return NavigationStack {
        addingplantView()
            .environmentObject(vm)
    }
    .modelContainer(container)
}
