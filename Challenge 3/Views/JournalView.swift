//
//  JournalView.swift
//  Challenge 3
//
//  Created by Mustafa Topiwala on 18/11/25.
//
import SwiftUI
import PhotosUI
import SwiftData

struct JournalView: View {
    @Namespace private var plantNamespace
    private let smooth: Animation = .snappy(duration: 0.25, extraBounce: 0.1)
    @EnvironmentObject var journalVM: JournalViewModel
    @EnvironmentObject var plantVM: PlantViewModel
    @Environment(\.modelContext) var modelContext
    @Environment(\.colorScheme) var colourScheme
    @Bindable var plant: Plant
    @State private var isExpanded = false
    @State private var note = ""
    @State private var showDialog = false
    @State private var selectedImage: UIImage?
    @State private var selectedItem: PhotosPickerItem?
    @State private var cameraViewShown: Bool = false
    @State private var showPhotoPicker = false
    @State private var journal: Journal?
    var canSave: Bool { !note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || selectedImage != nil }

    var body: some View {
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

            ScrollView{
                HStack{
                    VStack(alignment: .leading){
                        Text("Journal")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        
                    Spacer()
                        Image(systemName: isExpanded ? "checkmark" : "plus")
                            .padding()
                            .foregroundStyle(canSave ? .green : .primary)
                            
                            .glassEffect(.regular
                                .tint(colourScheme == .dark
                                      ? Color.white.opacity(0.12)
                                      : Color.black.opacity(0.10))
                                .interactive())
                            .contentTransition(.symbolEffect(.replace))
                            .onTapGesture {
                                withAnimation(smooth) {
                                    if canSave {
                                        journalVM.addJournalEntry(
                                            plantID: plant.id,
                                            notes: note,
                                            photo: selectedImage,
                                            context: modelContext
                                        )
                                        journal = journalVM.fetchJournal(context: modelContext, id: plant.id)
                                        isExpanded.toggle()
                                        selectedImage = nil
                                        note = ""
                                    } else {
                                        isExpanded.toggle()
                                    }
                                }
                            }.matchedGeometryEffect(id: "new journal button", in: plantNamespace)
                }.padding(.top)
                    .padding(.horizontal)//
                HStack {
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
                        .glassEffect(.regular
                            .tint(colourScheme == .dark
                                  ? Color.white.opacity(0.12)
                                  : Color.black.opacity(0.10))
                            .interactive())
                        .transition(.opacity.combined(with: .move(edge: .trailing)))
                    }
                }
                .padding(.horizontal)
                .animation(smooth, value: isExpanded)

                if let journal {
                    let sorted = journal.entries.sorted{ $0.date > $1.date}
                    if sorted.isEmpty{
                        ContentUnavailableView("No entries yet",systemImage: "list.bullet")
                               .scaleEffect(0.65)
                    }else{
                        ForEach(sorted, id: \.self) { entry in
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
                                    Text(entry.date, style: .date)
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundStyle(.secondary)

                                    if let note = entry.notes {
                                        Text(note)
                                            .font(.system(size: 16, weight: .regular))
                                    }

                                    if let img = journalVM.convertDataToSwiftUIimage(data: entry.photoData) {
                                        img
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
        .onAppear {
            journal = journalVM.fetchJournal(context: modelContext, id: plant.id)
        }
    }
}

#Preview {
    struct JournalViewPreviewHost: View {
        @State private var samplePlant: Plant = {
            var p = Plant(
                id: UUID(),
                plantName: "Basil",
                plantType: "Herb",
                plantIconName: "basil",
                plantDateCreated: Date(),
                plantDateGerminated: Date(),
                plantIsGerminated: false,
                plantShouldHaveGerminated: false
            )
            return p
        }()

        var body: some View {
            JournalView(plant: samplePlant)
                .environmentObject(PlantViewModel())
                .environmentObject(JournalViewModel())
        }
    }

    return JournalViewPreviewHost()
        .modelContainer(for: Plant.self)
}

