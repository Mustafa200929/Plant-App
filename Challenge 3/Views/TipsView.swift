import SwiftUI

struct TipsView: View {
    @EnvironmentObject var plantVM: PlantViewModel

    @State private var loading = false
    @State private var errorMessage: String? = nil

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

                // MARK: Header
                Text("Tips")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .padding()

                Text("To help your seed germinate")
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .padding(.horizontal)
                    .padding(.bottom)

                // MARK: Tips List
                ScrollView {
                    VStack(spacing: 16) {

                        if loading {
                            ProgressView("Generating AI tips…")
                                .padding()
                        }

                        if let error = errorMessage {
                            Text(error)
                                .foregroundColor(.red)
                                .padding()
                        }

                        if let plant = plantVM.plants.first,
                           let info = plantVM.findPlantData(plantType: plant.plantType) {

                            let tips = plantVM.tips(for: info)

                            ForEach(tips, id: \.self) { tip in
                                HStack {
                                    Image(systemName: "sun.max")
                                        .padding()
                                        .glassEffect(.regular)

                                    Text(tip)
                                        .font(.system(size: 16, weight: .regular))
                                }
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(.black.opacity(0.12))
                                .clipShape(RoundedRectangle(cornerRadius: 24))
                                .padding(.horizontal)
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
}

#Preview {
    TipsView()
        .environmentObject(PlantViewModel())
}

