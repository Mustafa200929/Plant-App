import SwiftUI

struct HomeView: View {
    @State private var showSheet = false
    @State private var index: Int = 0
    @State private var selectedDetent: PresentationDetent = .fraction(0.1)
    @EnvironmentObject var plantVM: PlantViewModel
    @State private var boxOpacity: Double = 1
    
    
    
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
                        .foregroundColor(.black)
                        .frame(width:250, height:130)
                        .offset(x:-50, y:-310)
                }
                .opacity(boxOpacity)
                .animation(.easeOut(duration: 1), value: boxOpacity)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                        boxOpacity = 0
                    }
                }
                // Add Plant Button
                HStack {
                    NavigationLink(destination: addingplantView()) {
                        Image(systemName: "plus")
                            .padding()
                            .accessibilityLabel("Add Plant")
                            .glassEffect(.clear)
                            .padding()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                
                
                ZStack {
                    Rectangle()
                        .fill(Color.clear)
                        .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 20))
                        .frame(width:300, height:130)
                        .offset(x:-35, y:-310)
                    
                    Text("You check your supplies, you realise you only have one seed inside. To continue, please get a seed from your preferred plant vendor")
                        .foregroundColor(.black)
                        .frame(width:250, height:130)
                        .offset(x:-50, y:-310)
                }
                .opacity(boxOpacity)
                .animation(.easeOut(duration: 1), value: boxOpacity)
                
                // Add Plant Button
                HStack {
                    NavigationLink(destination: addingplantView()) {
                        Image(systemName: "plus")
                            .padding()
                            .accessibilityLabel("Add Plant")
                            .glassEffect()
                            .padding()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                
                // Glow circle
                VStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 350, height: 350)
                        .blur(radius: 60)
                        .opacity(0.22)
                        .offset(y: -260)
                    Spacer()
                }
                .allowsHitTesting(false)
                
                // Main Rounded Container
                ZStack {
                    RoundedRectangle(cornerRadius: 180)
                        .fill(Color(hex: "F2E0C2"))
                        .frame(width: 380, height: 440)
                    
                    RoundedRectangle(cornerRadius: 180)
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
                        .frame(width: 340, height: 400)
                        .shadow(color: Color.black.opacity(0.2), radius: 10)
                    
                    GeometryReader { geo in
                        let width = geo.size.width
                        
                        // Auto-resize plants based on how many there are
                        let itemSize = max(min(width / 3, 90), 50)
                        
                        // Number of columns based on size
                        let columns = Array(
                            repeating: GridItem(.flexible(), spacing: 12),
                            count: max(Int(width / itemSize), 1)
                        )
                        
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(plantVM.plants.indices, id: \.self) { i in
                                let plant = plantVM.plants[i]
                                
                                VStack(spacing: 6) {
                                    Image(plant.plantIconName)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: itemSize, height: itemSize)
                                        .clipShape(Circle())
                                        .glassEffect(.clear.tint(plant.plantIsGerminated ? Color.green.opacity(0.35) : Color.gray.opacity(0.35)).interactive())
                                        .shadow(radius: 4)
                                    
                                        .onTapGesture {
                                            guard plantVM.plants.indices.contains(i) else { return }
                                            index = i
                                            showSheet = true
                                        }
                                    
                                    
                                    Text(plant.plantName)
                                        .font(.caption)
                                        .foregroundColor(.black.opacity(0.8))
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    .frame(width: 340, height: 400)
                    // ------------------------------------------
                }
                
                // Bottom label
                VStack {
                    Spacer()
                    Text("Click on plant")
                        .padding()
                        .foregroundStyle(.white)
                        .glassEffect(.clear)
                        .padding(.bottom, 24)
                }
            }
            .sheet(isPresented: $showSheet) {
                if plantVM.plants.indices.contains(index) {
                    NavigationStack {
                        PlantSheet(selectedDetent: $selectedDetent, index: $index)
                            .presentationDetents(
                                [.fraction(0.1), .fraction(0.7), .large],
                                selection: $selectedDetent
                            )
                    }
                }
            }
            .onChange(of: showSheet) { isShowing in
                if isShowing {
                    // If the selected index is no longer valid or there are no plants, dismiss immediately
                    if !plantVM.plants.indices.contains(index) || plantVM.plants.isEmpty {
                        showSheet = false
                    }
                }
            }
            .onChange(of: plantVM.plants.count) { _ in
                if showSheet {
                    if !plantVM.plants.indices.contains(index) || plantVM.plants.isEmpty {
                        showSheet = false
                    }
                }
            }
        }
    }
}


#Preview {
    HomeView()
        .environmentObject(PlantViewModel())
        .environmentObject(JournalViewModel())
}

