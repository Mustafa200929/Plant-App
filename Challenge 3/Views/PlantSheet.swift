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
                .animation(.easeInOut(duration: 0.25), value: selectedDetent)
                .ignoresSafeArea()
                
                ScrollView {
                    VStack {
                        HStack {
                            Image(plant.plantIconName)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 54, height: 54)
                                .glassEffect(.regular.tint(.teal.opacity(0.3)))
                            
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
                        
                        if selectedDetent == .fraction(0.7) || selectedDetent == .large {
                            
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
                            
                          
                            Text("Germinated")
                                .padding()
                                .glassEffect(.regular.tint(Color(hex:"DFFFE9")).interactive(), in: Capsule())
                                .frame(maxWidth: .infinity, alignment: .topLeading)
                                .padding()
                            
                            
                            Text("Tips")
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                                .padding(.leading)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.top)
                            HStack {
                                NavigationLink {
                                    TipsView(index: $index)
                                } label: {
                                    Text("See more")
                                        .font(.system(size: 16, weight: .regular, design: .rounded))
                                        .foregroundStyle(Color(.secondaryLabel))
                                        .padding(.bottom)
                                        .padding(.leading)
                                    Image(systemName: "chevron.right")
                                        .padding(.bottom)
                                }
                                .foregroundStyle(.black)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            
                           
                            if let info = plantVM.findPlantData(plantType: plant.plantType) {
                                let tips = plantVM.tips(for: info)
                                if tips.isEmpty {
                                    Text("Generating tips…")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundStyle(.secondary)
                                        .padding(.horizontal)
                                } else {
                                    VStack {
                                        ForEach(0..<min(tips.count, 2), id: \.self) { i in
                                            TipPreview(i: i, info: info, tips: tips)
                                        }
                                    }
                                }
                            }
                        }
                        
                        // LARGE CONTENT (JOURNAL)
                        if selectedDetent == .large {
                            VStack {
                                Text("Journal")
                                    .font(.system(size: 24, weight: .bold, design: .rounded))
                                    .padding(.leading)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.top)
                                HStack {
                                    NavigationLink {
                                        JournalView(index: $index)
                                    } label: {
                                        Text("See more")
                                            .font(.system(size: 16, weight: .regular, design: .rounded))
                                            .foregroundStyle(Color(.secondaryLabel))
                                            .padding(.bottom)
                                            .padding(.leading)
                                        Image(systemName: "chevron.right")
                                            .padding(.bottom)
                                    }
                                    .foregroundStyle(.black)
                                    .frame(maxWidth: .infinity, alignment: .leading)
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
                                            withAnimation {
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
                                    }
                                }
                                .padding()
                                
                                // JOURNAL PREVIEW
                                let journal = journalVM.returnJournal(for: plant.id)
                                if journal.entries.count > 0 {
                                    let values = journal.entries.prefix(2)
                                    ForEach(0..<values.count, id: \.self) { i in
                                        JournalPreview(i: i)
                                    }
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
                                        plantVM.removePlant(at: index)
                                        selectedDetent = .fraction(0.1)
                                    }
                                    Button("Cancel", role: .cancel) {}
                                } message: {
                                    Text("Are you sure?")
                                }
                            }
                        }
                        
                        // ---------------------------
                        // DELETE PLANT BUTTON (NEW)
                        // ---------------------------
                    }
                    .frame(maxWidth: .infinity, alignment: .bottom)
                }
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
            plantDateCreated: Date()
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
