import SwiftUI

struct TipsView: View {
    @EnvironmentObject var plantVM: PlantViewModel
    @Binding var index: Int
    @State private var loading = false
    @State private var errorMessage: String? = nil
    func TipView(i: Int, info: PlantInfo, tips: [String]) -> some View {
        HStack {
            Image(systemName: "sun.max.fill")
                .padding()
                .glassEffect(.regular)
            
            Text(tips.indices.contains(i) ? tips[i] : "")
                .font(.system(size: 16, weight: .regular))
                .multilineTextAlignment(.leading)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.black.opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .padding(.horizontal)
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(hex: "D7EEFF"),
                    Color(hex: "B7D8FF"),
                    Color(hex: "97C1FF")
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {

                Text("Tips")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .padding()

                Text("To help your seed germinate")
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .padding(.horizontal)
                    .padding(.bottom)
                ScrollView {
                    VStack(spacing: 16) {

                        if loading {
                            ProgressView("Generating AI tips…")
                                .progressViewStyle(CircularProgressViewStyle())
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding()
                        }

                        if let error = errorMessage {
                            Text(error)
                                .foregroundColor(.red)
                                .padding()
                        }
                        if let info = plantVM.findPlantData(plantType: plantVM.plants[index].plantType) {
                            let tips = plantVM.tips(for: info)
                            
                            if tips.isEmpty {
                                Text("Generating tips…")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundStyle(.secondary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal)
                            } else {
                                VStack {
                                    ForEach(0..<tips.count, id: \.self) { i in
                                        TipView(i: i, info: info, tips: tips)
                                    }
                                }
                            }
                        }
                          
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        .task {
            await loadIfNeeded()
        }
    }

    // MARK: Load tips on appear
    private func loadIfNeeded() async {
        guard let plant = plantVM.plants.first,
              let info = plantVM.findPlantData(plantType: plant.plantType)
        else {
            errorMessage = "No plant data found."
            return
        }

        if plantVM.tips(for: info).isEmpty {
            loading = true
            await plantVM.loadTips(for: info)
            loading = false
        }
    }


    private func iconForTip(_ tip: String) -> String {
        let lower = tip.lowercased()

        if lower.contains("water") || lower.contains("moist") || lower.contains("damp") {
            return "drop.fill"
        }
        if lower.contains("sun") || lower.contains("light") || lower.contains("shade") {
            return "sun.max.fill"
        }
        if lower.contains("soil") || lower.contains("fertile") || lower.contains("mix") {
            return "leaf.fill"
        }
        if lower.contains("temperature") || lower.contains("warm") || lower.contains("cold") {
            return "thermometer"
        }
        if lower.contains("dark") || lower.contains("cover") {
            return "moon.fill"
        }

        return "sparkles"
    }
}

#Preview {
    TipsView(index: .constant(0))
        .environmentObject(PlantViewModel())
}
