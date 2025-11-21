//
//  PlantSheet.swift
//  Challenge 3
//

import SwiftUI
import PhotosUI

struct PlantSheet: View {
    @Binding var selectedDetent: PresentationDetent
    @Binding var index: Int
    @EnvironmentObject var plantVM: PlantViewModel
    @EnvironmentObject var journalVM: JournalViewModel
    @State private var isExpanded = false
    @State private var note = ""
    @State private var showDialog = false
    @State private var selectedImage: UIImage?
    @State private var selectedItem: PhotosPickerItem?
    @State private var cameraViewShown: Bool = false
    @State private var showPhotoPicker = false
    @State private var refreshID = UUID()
    @State private var showDeleteDialog = false
    
    @Namespace private var plantNamespace
    private let smooth = Animation.spring(response: 0.35, dampingFraction: 0.85, blendDuration: 0.2)
    
    var canSave: Bool {
        !note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || selectedImage != nil
    }
    
    func TipPreview(i: Int, info: PlantInfo, tips: [String]) -> some View {
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
    
    func JournalPreview(i: Int) -> some View {
        HStack{
            VStack(spacing: 4){
                Circle()
                    .fill(Color(hex: "7ED957"))
                    .frame(width: 18, height: 18)
                    .overlay(
                        Circle()
                            .stroke(Color(hex: "4CAF50"), lineWidth: 2)
                            .frame(width: 24, height:24)
                    )
                
                RoundedRectangle(cornerRadius: 2)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hex: "4CAF50"),
                                Color(hex: "7ED957")
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 3)
            }
            VStack(alignment: .leading){
                let journal = journalVM.returnJournal(for: plantVM.plants[index].id)
                let entry = journal.entries[i]
                
                Text(entry.date, style: .date)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.secondary)
                
                if let note = entry.notes {
                    Text(note)
                        .font(.system(size: 16, weight: .regular))
                }
                if let photo = entry.photo{
                    photo
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 300)
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                        .padding()
                }
            }
        }
        .frame(maxWidth:.infinity, alignment: .leading)
        .padding(.horizontal)
        .transition(.opacity)
        .animation(smooth, value: i)
    }
    var body: some View {
        let plant = plantVM.plants[index]
        ZStack{
            LinearGradient(
                colors: [
                    Color(hex: "D7EEFF"),
                    Color(hex: "B7D8FF"),
                    Color(hex: "97C1FF")
                ],
                startPoint: .top, endPoint: .bottom
            )
            .opacity(selectedDetent == .large ? 1 : 0)
            .animation(smooth, value: selectedDetent)
            .ignoresSafeArea()
            
            ScrollView {
                VStack {
                    HStack {
                        Image(plant.plantIconName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 54, height: 54)
                            .glassEffect(.clear.tint(plant.plantIsGerminated ? Color.green.opacity(0.35) : Color.gray.opacity(0.35)))
                        
                        VStack(alignment: .leading) {
                            Text(plant.plantName)
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                            Text(plant.plantType)
                        }
                        .padding()
                        
                        Spacer()
                        
                        let age = plantVM.plantAge(index: index)
                        Text(age == 0 ? "Just born!" :
                                age == 1 ? "1 day old" :
                                "\(age) days old")
                        .fontWeight(.semibold)
                    }
                    .padding()
                    .animation(smooth, value: plantVM.plants[index].plantIsGerminated)
                    
                    if selectedDetent == .fraction(0.7) || selectedDetent == .large {
                        
                        if plantVM.plants[index].plantIsGerminated {
                            HStack(spacing: 12) {
                                Image(systemName: "leaf.fill")
                                    .font(.system(size: 22, weight: .bold))
                                    .foregroundStyle(.green)
                                    .padding(10)
                                    .background(
                                        Circle()
                                            .fill(LinearGradient(colors: [Color(hex: "DFFFE9"), Color(hex: "B7F5C8")], startPoint: .topLeading, endPoint: .bottomTrailing))
                                    )
                                    .overlay(
                                        Circle().stroke(.green.opacity(0.25), lineWidth: 1)
                                    )
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Germinated!")
                                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                                    let created = plantVM.plants[index].plantDateGerminated
                                    Text("\(created, style: .date)")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundStyle(.secondary)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "checkmark.seal.fill")
                                    .symbolRenderingMode(.palette)
                                    .foregroundStyle(.white, .green)
                                    .padding(8)
                                    .background(RoundedRectangle(cornerRadius: 12).fill(Color.green.opacity(0.2)))
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 24)
                                    .fill(Color.green.opacity(0.12))
                                    .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
                            )
                            .padding(.horizontal)
                            .transition(.asymmetric(insertion: .opacity.combined(with: .scale(scale: 0.98)), removal: .opacity))
                        }else{
                            Group {
                                VStack{
                                    if let info = plantVM.findPlantData(plantType: plant.plantType) {
                                        let remaining = info.germinationMaxDays - plantVM.plantAge(index: index)
                                        Text("Should germinate in \(max(remaining, 0)) days")
                                            .padding(.horizontal)
                                            .padding(.top)
                                            .fontWeight(.medium)
                                        
                                        Text("Look out for sprouts")
                                            .padding(.bottom)
                                    } else {
                                        Text("Germination info unavailable")
                                            .padding()
                                    }
                                }
                                .frame(maxWidth:.infinity)
                                .background(.black.opacity(0.12))
                                .clipShape(RoundedRectangle(cornerRadius: 24))
                                .padding(.horizontal)
                                .transition(.opacity)
                                
                                SwipeToConfirm(
                                    title: "Germinated",
                                    backgroundTint: Color(hex: "DFFFE9"),
                                    onConfirm: {
                                        withAnimation(smooth) {
                                            plantVM.plantIsGerminated(plantID: plantVM.plants[index].id)
                                        }
                                    }
                                )
                                .padding(.horizontal)
                            }
                            Text("Tips")
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                                .padding(.top)
                                .padding(.leading)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            NavigationLink {
                                TipsView(index: $index)
                            } label: {
                                HStack(spacing:0){
                                    Text("See more")
                                        .font(.system(size: 16, weight: .regular, design: .rounded))
                                        .padding(.bottom)
                                        .padding(.leading)
                                    Image(systemName: "chevron.right")
                                        .padding(.bottom)
                                }
                                .foregroundStyle(Color(.secondaryLabel))
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            
                            if let info = plantVM.findPlantData(plantType: plant.plantType) {
                                let tips = plantVM.tips(for: info)
                                if tips.isEmpty {
                                    Text("Generating tips…")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundStyle(.secondary)
                                        .padding(.horizontal)
                                        .transition(.opacity)
                                } else {
                                    VStack {
                                        ForEach(0..<min(tips.count, 2), id: \.self) { i in
                                            TipPreview(i: i, info: info, tips: tips)
                                        }
                                    }
                                    .transition(.opacity)
                                }
                            }
                        }
                    }
                    
                    // LARGE CONTENT (JOURNAL)
                    if selectedDetent == .large || (selectedDetent == .fraction(0.7) && plantVM.plants[index].plantIsGerminated){
                        VStack {
                            Text("Journal")
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                                .padding(.leading)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.top)
                            HStack {
                                NavigationLink {
                                    TipsView(index: $index)
                                } label: {
                                    HStack(spacing:0){
                                        Text("See more")
                                            .font(.system(size: 16, weight: .regular, design: .rounded))
                                            .padding(.bottom)
                                            .padding(.leading)
                                        Image(systemName: "chevron.right")
                                            .padding(.bottom)
                                    }
                                    .foregroundStyle(Color(.secondaryLabel))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                }
                            }
                            
                            // ADD JOURNAL ENTRY
                            HStack {
                                Image(systemName: isExpanded ? "checkmark" : "plus")
                                    .padding()
                                    .foregroundStyle(canSave ? .green : .secondary)
                                    .opacity(canSave ? 1 : 0.5)
                                    .glassEffect(.regular.interactive())
                                    .contentTransition(.symbolEffect(.replace))
                                    .onTapGesture {
                                        withAnimation(smooth) {
                                            if canSave {
                                                journalVM.addJournalEntry(
                                                    plantID: plant.id,
                                                    notes: note,
                                                    photo: selectedImage
                                                )
                                                isExpanded.toggle()
                                                selectedImage = nil
                                                note = ""
                                                refreshID = UUID()
                                            } else {
                                                isExpanded.toggle()
                                            }
                                        }
                                    }
                                
                                if isExpanded {
                                    Group {
                                        Image(systemName: selectedImage == nil ? "photo.badge.plus" : "photo.badge.checkmark")
                                            .foregroundStyle((selectedImage != nil) ? .green : .secondary)
                                            .onTapGesture {
                                                showDialog.toggle()
                                            }
                                            .confirmationDialog("Add Photo", isPresented: $showDialog) {
                                                Button("Take Photo"){ cameraViewShown.toggle() }
                                                Button("Choose Photo"){ showPhotoPicker.toggle() }
                                                Button("Discard photo", role: .destructive){
                                                    selectedImage = nil
                                                }
                                            }
                                        
                                        TextField("Add a note...", text: $note)
                                    }
                                    .padding()
                                    .glassEffect(.regular.interactive())
                                    .transition(.opacity.combined(with: .move(edge: .trailing)))
                                }
                            }
                            .padding()
                            .animation(smooth, value: isExpanded)
                            
                            let journal = journalVM.returnJournal(for: plant.id)
                            if journal.entries.count > 0 {
                                let values = journal.entries.prefix(2)
                                ForEach(0..<values.count, id: \.self) { i in
                                    JournalPreview(i: i)
                                }
                                .animation(smooth, value: journal.entries.count)
                            } else {
                                Text("No journal entries yet.")
                                    .font(.system(size: 18, weight: .semibold))
                                    .padding()
                            }
                            Button(role: .destructive) {
                                showDeleteDialog = true
                            } label: {
                                HStack {
                                    Image(systemName: "trash.fill")
                                        .font(.system(size: 20, weight: .bold))
                                    
                                    Text("Delete Plant")
                                        .font(.system(size: 20, weight: .semibold))
                                }
                                .foregroundStyle(.red)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(
                                    RoundedRectangle(cornerRadius: 24)
                                        .fill(Color.red.opacity(0.15))
                                        .shadow(color: .black.opacity(0.1), radius: 8, y: 4)
                                )
                                .padding(.horizontal)
                                .padding(.bottom, 30)
                            }
                            .confirmationDialog("Delete Plant", isPresented: $showDeleteDialog, titleVisibility: .visible) {
                                Button("Delete Plant", role: .destructive) {
                                    withAnimation(smooth) {
                                        plantVM.removePlant(at: index)
                                        selectedDetent = .fraction(0.1)
                                    }
                                }
                                Button("Cancel", role: .cancel) {}
                            } message: {
                                Text("Are you sure?")
                            }
                        }
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .animation(smooth, value: selectedDetent)
                    }
                }
                        .frame(maxWidth: .infinity, alignment: .bottom)
                }
                .animation(smooth, value: selectedDetent)
                .padding(.top, -20)
            }
            .photosPicker(isPresented: $showPhotoPicker, selection: $selectedItem, matching: .images)
            .onChange(of: selectedItem) { item in
                if let item = item {
                    Task {
                        if let data = try? await item.loadTransferable(type: Data.self) {
                            selectedImage = UIImage(data: data)
                        }
                    }
                }
            }
            .sheet(isPresented: $cameraViewShown) {
                CameraView(image: $selectedImage)
                    .presentationDetents([.large])
            }
            .id(refreshID)
            .task {
                if let info = plantVM.findPlantData(plantType: plant.plantType) {
                    await plantVM.loadTips(for: info)
                }
            }
        }
    }
    
    
    // MARK: - Preview with sample plant to prevent crashes
    struct PlantSheet_Previews: PreviewProvider {
        static var previews: some View {
            // Create a PlantViewModel and inject a sample plant
            let pv = PlantViewModel()
            let samplePlant = Plant(
                plantName: "Bob",
                plantType: "basil",
                plantIconName: "plant1",
                plantDateCreated: Date(),
                plantDateGerminated: Date(),
                plantIsGerminated: false
            )
            pv.plants = [samplePlant]
            
            let jv = JournalViewModel()
            return PlantSheet(selectedDetent: .constant(.large), index: .constant(0))
                .environmentObject(pv)
                .environmentObject(jv)
        }
    }


#Preview{
    PlantSheet(selectedDetent: .constant(.large), index: .constant(0))
        .environmentObject(PlantViewModel())
        .environmentObject(JournalViewModel())
}

