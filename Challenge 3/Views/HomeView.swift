import SwiftUI
import SwiftData

struct HomeView: View {
    @State private var showSheet = false
    @State private var selectedPlant: Plant?
    @State private var index: Int = 0
    @State private var selectedDetent: PresentationDetent = .fraction(0.1)
    @State private var boxOpacity: Double = 1
    @State private var islandTopOffset: CGFloat = 30
    @State private var showAddPlantSheet = false
    @EnvironmentObject var plantVM: PlantViewModel
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.modelContext) var modelContext
    @Query var plants: [Plant]
    @Query var journals: [Journal]
    @AppStorage("isShown") var notShown: Bool = true
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(hex: "2F66E9"),
                        Color(hex: "1C3A86"),
                        Color(hex: "122E5F")
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                GeometryReader {geo in
                    let w = geo.size.width
                    let h = geo.size.height
                    VStack {
                        Circle()
                            .fill(.primary)
                            .frame(width: w, height: h)
                            .blur(radius: 60)
                            .opacity(0.22)
                            .offset(y: -h*0.8)
                        Spacer()
                    }
                }
                VStack{
                    if notShown == false{
                        Text("You check your supplies, you only have one seed to populate the island.")
                            .padding()
                            .glassEffect()
                            .foregroundColor(.primary)
                            .opacity(boxOpacity)
                            .animation(.easeOut(duration: 1), value: boxOpacity)
                            .onAppear {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                                    notShown = false
                                    boxOpacity = 0
                                }
                            }
                    }
                    
                    GeometryReader { geo in
                        let width = geo.size.width
                        let height = geo.size.height
                        let islandSize = CGSize(width: width*0.8, height: height*0.7)
                        let baseSize: CGFloat = 90
                        let count = plants.count
                        let scale = max(0.5, min(1.0, 3.0 / CGFloat(max(count, 1))))
                        let itemSize = baseSize * scale
                        let minX = itemSize/2
                        let maxX = islandSize.width - itemSize/2
                        let minY = itemSize/2
                        let maxY = islandSize.height - itemSize/2
                        ZStack (alignment: .center) {
                            RoundedRectangle(cornerRadius: 180)
                                .fill(Color(hex: "F2E0C2"))
                                .frame(width: islandSize.width*1.1, height: islandSize.height*1.1)
                            RoundedRectangle(cornerRadius: 200)
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color(hex: "E8C58C"),
                                            Color(hex: "D7B179")
                                        ]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: islandSize.width, height: islandSize.height)
                                .shadow(color: Color.primary.opacity(0.2), radius: 10)
                            ForEach(plants) { plant in
                                let shouldHaveGerminated: Bool = {
                                    guard let info = plantVM.findPlantData(plantType: plant.plantType) else { return false }
                                    return plantVM.plantAge(plant: plant) >= info.germinationMaxDays
                                }()
                                
                                let tint: Color = plant.plantIsGerminated
                                ? Color.green.opacity(0.35)
                                : (shouldHaveGerminated ? Color.yellow.opacity(0.35) : Color.white.opacity(0.08))
                                
                                let clampedX = max(minX, min(maxX, plant.positionX))
                                let clampedY = max(minY, min(maxY, plant.positionY))
                                let pos = CGPoint(x: clampedX, y: clampedY)
                                
                                VStack(spacing: 6) {
                                    Image(plant.plantIconName)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: itemSize, height: itemSize)
                                        .clipShape(Circle()).glassEffect(.regular.tint(tint))
                                        .shadow(radius: 4)
                                        .onTapGesture {
                                            selectedPlant = plant
                                            index = plants.firstIndex(where: { $0.id == plant.id }) ?? 0
                                            showSheet = true
                                        }
                                    
                                    Text(plant.plantName)
                                        .frame(width: itemSize)
                                        .font(.system(size: min(16, itemSize * 0.18), weight: .regular))
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.6)
                                        .multilineTextAlignment(.center)
                                        .foregroundColor(.primary.opacity(0.8))
                                }
                                .position(x: pos.x, y: pos.y)
                            }
                        }
                        .onChange(of: islandSize){oldSize, newSize in
                            if newSize.height>oldSize.height{
                                plantVM.islandSize = newSize
                            }
                        }
                        .frame(width: islandSize.width, height: islandSize.height)
                        .frame(width: width, height: height)
                    }
                }
            }
            
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            
            
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showAddPlantSheet.toggle()
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            
            
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(Color.clear, for: .navigationBar)
            
            .sheet(isPresented: $showSheet) {
                if plants.indices.contains(index) {
                    NavigationStack {
                        PlantSheet(selectedDetent: $selectedDetent, plant: selectedPlant!)
                            .presentationDetents(
                                [.fraction(0.1), .fraction(0.7), .large],
                                selection: $selectedDetent
                            )
                    }
                }
            }
            .onChange(of: showSheet) { isShowing in
                if isShowing {
                    if !plants.indices.contains(index) || plants.isEmpty {
                        showSheet = false
                    }
                }
            }
            .onChange(of: plants.count) { _ in
                if showSheet {
                    if !plants.indices.contains(index) || plants.isEmpty {
                        showSheet = false
                    }
                }
            }
            .sheet(isPresented: $showAddPlantSheet) {
                addingplantView()
                    .presentationDetents([.large])
            }
            
        }
        
    }
}

#Preview {
    HomeView()
        .environmentObject(PlantViewModel())
        .environmentObject(JournalViewModel())
        .modelContainer(for: Plant.self)
}

