//
//  PlantSheet.swift
//  Challenge 3
//
//  Created by Mustafa Topiwala on 17/11/25.
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
    
    // removed unused TipGenerator + state, since tips now come from PlantViewModel
    
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
    
    // MARK: - Body
    var body: some View {
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
            
            ScrollView{
                VStack{
                    // Header
                    HStack{
                        Image(systemName: plantVM.plants[index].plantIconName)
                            .padding()
                            .glassEffect(.regular.tint(.teal.opacity(0.3)))
                        
                        VStack(alignment: .leading){
                            Text(plantVM.plants[index].plantName)
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                            Text(plantVM.plants[index].plantType)
                        }
                        .frame(alignment: .topLeading)
                        .padding()
                        
                        Spacer()
                        
                        let age = plantVM.plantAge(index: index)
                        if age == 0 {
                            Text("Just born!")
                                .fontWeight(.semibold)
                        } else if age == 1 {
                            Text("\(age) day old")
                                .fontWeight(.semibold)
                        } else {
                            Text("\(age) days old")
                                .fontWeight(.semibold)
                        }
                    }
                    .padding()
                    
                    // Medium / Large detent content
                    if selectedDetent == .fraction(0.7) || selectedDetent == .large {
                        VStack{
                            // Germination summary card
                            VStack(){
                                if let info = plantVM.findPlantData(plantType: plantVM.plants[index].plantType) {
                                    let remaining = info.germinationMaxDays - plantVM.plantAge(index: index)
                                    Text("Should germinate in \(max(remaining, 0)) days")
                                        .padding(.horizontal)
                                        .padding(.top)
                                        .fontWeight(.medium)
                                } else {
                                    Text("Germination info unavailable")
                                        .padding(.horizontal)
                                        .padding(.top)
                                        .fontWeight(.medium)
                                }
                                Text("Look out for sprouts")
                                    .padding(.bottom)
                            }
                            .frame(maxWidth:.infinity)
                            .background(.black.opacity(0.12))
                            .clipShape(RoundedRectangle(cornerRadius: 24))
                            .padding(.horizontal)
                            
                            // Germinated button
                            Text("Germinated")
                                .padding()
                                .glassEffect(.regular.tint(Color(hex:"DFFFE9")).interactive(),in: Capsule())
                                .frame(maxWidth: .infinity, alignment: .topLeading)
                                .padding()
                                .onTapGesture {
                                    // Next page / state change here
                                }
                            
                            // Tips navigation
                            NavigationLink{
                                TipsView(index: $index)
                            }label:{
                                HStack{
                                    Text("Tips")
                                        .font(.system(size: 24, weight: .bold, design: .rounded))
                                        .padding(.bottom)
                                        .padding(.leading)
                                    Image(systemName: "chevron.right")
                                        .padding(.bottom)
                                }
                                .foregroundStyle(.black)
                                .frame(maxWidth:.infinity, alignment: .leading)
                            }
                            
                            // Tips preview (SAFE NOW)
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
                                        ForEach(0..<min(tips.count, 2), id: \.self) { i in
                                            TipPreview(i: i, info: info, tips: tips)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    // Large detent extra content
                    if selectedDetent == .large {
                        VStack{
                            // Journal header
                            HStack{
                                NavigationLink{
                                    JournalView(index:$index)
                                }label:{
                                    Text("Journal")
                                        .font(.system(size: 24, weight: .bold, design: .rounded))
                                        .padding(.bottom)
                                        .padding(.leading)
                                    Image(systemName: "chevron.right")
                                        .padding(.bottom)
                                }
                                .foregroundStyle(.black)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.top)
                            }
                            
                            // Add journal entry row
                            HStack(){
                                Image(systemName: isExpanded ? "checkmark" : "plus")
                                    .padding()
                                    .foregroundStyle(canSave ? .green : .secondary)
                                    .opacity(canSave ? 1 : 0.5)
                                    .glassEffect(.regular.interactive())
                                    .contentTransition(.symbolEffect(.replace))
                                    .onTapGesture {
                                        withAnimation{
                                            if canSave{
                                                journalVM.addJournalEntry(
                                                    plantID: plantVM.plants[index].id,
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
                                
                                if isExpanded{
                                    Group{
                                        Image(systemName: selectedImage == nil ? "photo.badge.plus" : "photo.badge.checkmark")
                                            .foregroundStyle((selectedImage != nil) ? .green : .secondary)
                                            .onTapGesture{
                                                showDialog.toggle()
                                            }
                                            .confirmationDialog("Add Photo", isPresented: $showDialog, titleVisibility: .hidden){
                                                Button{
                                                    cameraViewShown.toggle()
                                                }label:{
                                                    Text("Take Photo")
                                                }
                                                Button{
                                                    showPhotoPicker.toggle()
                                                }label:{
                                                    Text("Choose Photo")
                                                }
                                                Button(role: .destructive){
                                                    selectedImage = nil
                                                }label:{
                                                    Text("Discard photo")
                                                }
                                            }
                                        
                                        TextField("Add a note...", text: $note)
                                    }
                                    .padding()
                                    .glassEffect(.regular.interactive())
                                }
                            }
                            .padding()
                            
                            // Journal preview
                            let journal = journalVM.returnJournal(for: plantVM.plants[index].id)
                            if journal.entries.count > 0{
                                let values = journal.entries.prefix(2)
                                ForEach(0..<values.count, id: \.self){ i in
                                    JournalPreview(i: i)
                                }
                            }
                            else{
                                Text("No journal entries yet.")
                                    .font(.system(size: 18, weight: .semibold))
                            }
                        }
                    }
                }
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
        // load FM tips when sheet appears (uses caching in PlantViewModel)
        .task {
            if let info = plantVM.findPlantData(plantType: plantVM.plants[index].plantType) {
                await plantVM.loadTips(for: info)
            }
        }
    }
}

#Preview{
    PlantSheet(selectedDetent: .constant(.large), index: .constant(0))
        .environmentObject(PlantViewModel())
        .environmentObject(JournalViewModel())
}

