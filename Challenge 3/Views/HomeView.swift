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
                
                .navigationBarBackButtonHidden(true)
                
                
                ZStack {
                    Rectangle()
                        .fill(Color.clear)
                        .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 20))
                        .frame(width:300, height:130)
                        .offset(x:-35, y:-310)
                    
                    Text("You check your supplies, you realise you only have one seed inside. To continue, please get a seed from your preferred plant vendor")
                        .foregroundColor(.primary)
                        .foregroundColor(.primary)
                        .frame(width:250, height:130)
                        .offset(x:-50, y:-310)
                    
                }
                .opacity(boxOpacity)
                .animation(.easeOut(duration: 1), value: boxOpacity)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                        boxOpacity = 0
                    }
                    let size = CGSize(width: 340, height: 520)
                    let baseSize: CGFloat = 90
                    let count = plants.count
                    let scale = max(0.5, min(1.0, 3.0 / CGFloat(max(count, 1))))
                    let itemSize = baseSize * scale
                    let minX = itemSize/2
                    let maxX = size.width - itemSize/2
                    let minY = itemSize/2
                    let maxY = size.height - itemSize/2
                    for plant in plants {
                        plant.positionX = max(minX, min(maxX, plant.positionX))
                        plant.positionY = max(minY, min(maxY, plant.positionY))
                    }
                }
    
                HStack {
                    Button(action: {
                        showAddPlantSheet.toggle()
                    }) {
                        Image(systemName: "plus")
                            .padding()
                            .accessibilityLabel("Add Plant")
                            .glassEffect()
                            .padding()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                .sheet(isPresented: $showAddPlantSheet) {
                    addingplantView()
                        .presentationDetents([.large])
                        .onDisappear {
                            if showAddPlantSheet == false {
                                let baseSize: CGFloat = 90
                                let count = plants.count
                                let scale = max(0.5, min(1.0, 3.0 / CGFloat(max(count, 1))))
                                let itemSize = baseSize * scale
                                let size = CGSize(width: 340, height: 520)
                                for plant in plants where (plant.positionX <= 0 || plant.positionY <= 0) {
                                    let p = randomPosition(in: size, itemSize: itemSize)
                                    plant.positionX = p.x
                                    plant.positionY = p.y
                                }
                            }
                        }
                }

                VStack {
                    Circle()
                        .fill(.primary)
                        .frame(width: 350, height: 350)
                        .blur(radius: 60)
                        .opacity(0.22)
                        .offset(y: -260)
                    Spacer()
                }
                .allowsHitTesting(false)
                
                ZStack {
                    RoundedRectangle(cornerRadius: 180)
                        .fill(Color(hex: "F2E0C2"))
                        .frame(width: 380, height: 560)
                        .offset(y: 20)
                    
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
                        .frame(width: 340, height: 520)
                        .offset(y: 20)
                        .shadow(color: Color.primary.opacity(0.2), radius: 10)
                    
                    GeometryReader { geo in
                        let islandSize = CGSize(width: 340, height: 520)
                        let islandOrigin = CGPoint(x: 0, y: islandTopOffset)
                        let baseSize: CGFloat = 90
                        let count = plants.count
                        let scale = max(0.5, min(1.0, 3.0 / CGFloat(max(count, 1))))
                        let itemSize = baseSize * scale
                        
                        let minX = itemSize/2
                        let maxX = islandSize.width - itemSize/2
                        let minY = itemSize/2
                        let maxY = islandSize.height - itemSize/2

                        ZStack {
                            ForEach(plants) { plant in
                                let clampedX = max(minX, min(maxX, plant.positionX))
                                let clampedY = max(minY, min(maxY, plant.positionY))
                                let pos = CGPoint(x: clampedX, y: clampedY)
                                VStack(spacing: 6) {
                                    Image(plant.plantIconName)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: itemSize, height: itemSize)
                                        .clipShape(Circle()).glassEffect(.regular.tint(plant.plantIsGerminated ? Color.green.opacity(0.35) : Color.white.opacity(0.08)))
                                        .shadow(radius: 4)
                                        .onTapGesture {
                                            selectedPlant = plant
                                            index = plants.firstIndex(where: { $0.id == plant.id }) ?? 0
                                            showSheet = true
                                        }
                                    Text(plant.plantName)
                                        .font(.caption)
                                        .foregroundColor(.primary.opacity(0.8))
                                }
                                .position(x: pos.x, y: pos.y)


                            }
                        }
                        .frame(width: islandSize.width, height: islandSize.height)
                        .offset(y: 0)
                    }
                    .frame(width: 340, height: 520)
                    .offset(y: 20)
                    
                }
                .offset(y: islandTopOffset)
                
                
            }
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
            
        }
    }
    
    private func randomPosition(in size: CGSize, itemSize: CGFloat) -> CGPoint {
        let minX = itemSize/2
        let maxX = size.width - itemSize/2
        let minY = itemSize/2
        let maxY = size.height - itemSize/2
        return CGPoint(x: CGFloat.random(in: minX...maxX), y: CGFloat.random(in: minY...maxY))
    }
}


#Preview {
    HomeView()
        .environmentObject(PlantViewModel())
        .environmentObject(JournalViewModel())
        .modelContainer(for: Plant.self)
}

