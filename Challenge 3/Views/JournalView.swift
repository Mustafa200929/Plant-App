//
//  JournalView.swift
//  Challenge 3
//
//  Created by Mustafa Topiwala on 18/11/25.
//
import SwiftUI
import PhotosUI

struct JournalView: View {
    @EnvironmentObject var journalVM: JournalViewModel
    @EnvironmentObject var plantVM: PlantViewModel
    @Bindable var plant: Plant
    @State private var isExpanded = false
    @State private var note = ""
    @State private var showDialog = false
    @State private var selectedImage: UIImage?
    @State private var selectedItem: PhotosPickerItem?
    @State private var cameraViewShown: Bool = false
    @State private var showPhotoPicker = false
    @State private var refreshID: UUID = UUID()
    var canSave: Bool { !note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || selectedImage != nil }
    var body: some View {
        ZStack{
            LinearGradient(
                colors: [
                    Color(hex: "D7EEFF"),   // light sky blue
                    Color(hex: "B7D8FF"),   // soft marine
                    Color(hex: "97C1FF")    // gentle ocean blue
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            ScrollView{
                Text("Journal")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity, alignment: .leading)
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
                                    journalVM.addJournalEntry(plantID: plant.id, notes: note, photo: selectedImage)
                                    isExpanded.toggle()
                                    selectedImage = nil
                                    note = ""
                                    refreshID = UUID()
                                }else{
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
                ForEach(0..<journalVM.returnJournal(for: plant.id).entries.count){i in
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
                            Text(journalVM.returnJournal(for: plant.id).entries[i].date, style: .date)
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(.secondary)
                            
                            if let note = journalVM.returnJournal(for: plant.id).entries[i].notes{
                                Text(note)
                                    .font(.system(size: 16, weight: .regular))
                            }
                            if let photo = journalVM.returnJournal(for: plant.id).entries[i].photo{
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
            }
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
    }
}



