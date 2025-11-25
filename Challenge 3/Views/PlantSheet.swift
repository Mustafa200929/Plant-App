//
//  PlantSheet.swift
//  Challenge 3
//

import SwiftUI
import PhotosUI
import SwiftData

struct PlantSheet: View {
    @Binding var selectedDetent: PresentationDetent
    @Bindable var plant: Plant
    @EnvironmentObject var plantVM: PlantViewModel
    @EnvironmentObject var journalVM: JournalViewModel
    @State private var isExpanded = false
    @State private var note = ""
    @State private var showDialog = false
    @State private var selectedImage: UIImage?
    @State private var selectedItem: PhotosPickerItem?
    @State private var cameraViewShown = false
    @State private var showPhotoPicker = false
    @State private var showDeleteDialog = false
    @Environment(\.dismiss) private var dismiss
    @Namespace private var plantNamespace
    @Environment(\.modelContext) var modelContext
    @State private var journal: Journal?
    private let smooth = Animation.spring(response: 0.35, dampingFraction: 0.85, blendDuration: 0.2)

    var canSave: Bool {
        !note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || selectedImage != nil
    }

    func TipPreview(i: Int, info: PlantInfo, tips: [String]) -> some View {
        HStack {
            Image(systemName: iconForTip(tips[i]))
                .foregroundStyle(.primary)
                .font(.system(size: 20))
                .padding()
                .glassEffect(.regular)
            Text(tips.indices.contains(i) ? tips[i] : "")
                .font(.system(size: 16, weight: .regular))
                .multilineTextAlignment(.leading)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.primary.opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .padding(.horizontal)
    }

    func JournalPreview(entry: JournalEntry) -> some View {
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

                if let photo = journalVM.convertDataToSwiftUIimage(data: entry.photoData){
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
        .animation(smooth, value: entry.id)
    }

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
            .animation(smooth, value: selectedDetent)
            .ignoresSafeArea()

            ScrollView {
                VStack{

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

                        let age = plantVM.plantAge(plant: plant)
                        Text(age == 0 ? "Just born!" :
                                age == 1 ? "1 day old" :
                                "\(age) days old")
                        .fontWeight(.semibold)
                    }
                    .padding()
                    .animation(smooth, value: plant.plantIsGerminated)

                    if selectedDetent == .fraction(0.7) || selectedDetent == .large {

                        if plant.plantIsGerminated {
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
                                    let created = plant.plantDateGerminated
                                    Text("\(created, style: .date)")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundStyle(.secondary)
                                }

                                Spacer()

                                Image(systemName: "checkmark.seal.fill")
                                    .symbolRenderingMode(.palette)
                                    .foregroundStyle(.primary, .green)
                                    .padding(8)
                                    .background(RoundedRectangle(cornerRadius: 12).fill(Color.green.opacity(0.2)))
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 24)
                                    .fill(Color.green.opacity(0.12))
                                    .shadow(color: .primary.opacity(0.08), radius: 8, y: 4)
                            )
                            .padding(.horizontal)
                        } else {

                            Group {
                                VStack{
                                    if let info = plantVM.findPlantData(plantType: plant.plantType) {
                                        let remaining = info.germinationMaxDays - plantVM.plantAge(plant: plant)
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
                                .background(.primary.opacity(0.12))
                                .clipShape(RoundedRectangle(cornerRadius: 24))
                                .padding(.horizontal)

                                SwipeToConfirm(
                                    title: "Germinated",
                                    backgroundTint: Color(hex: "DFFFE9"),
                                    onConfirm: {
                                        withAnimation(smooth) {
                                            plantVM.plantIsGerminated(plant: plant)
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
                                TipsView(plant: plant)
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

                    if selectedDetent == .large || (selectedDetent == .fraction(0.7) && plant.plantIsGerminated){

                        VStack {

                            Text("Journal")
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                                .padding(.leading)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.top)

                            HStack {
                                NavigationLink {
                                    JournalView(plant: plant)
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
                            .padding(.horizontal)
                            .animation(smooth, value: isExpanded)

                            if let journal {
                                let sorted = journal.entries.sorted { $0.date > $1.date }
                                let preview = Array(sorted.prefix(2))

                                if preview.isEmpty {
                                    Text("No journal entries yet.")
                                        .font(.system(size: 18, weight: .semibold))
                                        .padding()
                                } else {
                                    ForEach(preview, id: \.id) { entry in
                                        JournalPreview(entry: entry)
                                    }
                                }
                            }
                            Button(role: .destructive) {
                                showDeleteDialog = true
                            } label: {
                                Label("Delete Plant", systemImage: "trash.fill")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.red)
                                    .padding()
                            }
                            .confirmationDialog("Are you sure?", isPresented: $showDeleteDialog, titleVisibility: .visible) {
                                Button("Delete Plant", role: .destructive) {
                                    withAnimation {
                                        plantVM.removePlant(plant: plant, context: modelContext)
                                        journalVM.deleteJournal(for: plant.id)
                                        selectedDetent = .fraction(0.1)
                                        dismiss()
                                    }
                                }
                                Button("Cancel", role: .cancel) {}
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
        .onAppear {
            journal = journalVM.fetchJournal(context: modelContext, id: plant.id)
        }
        .task {
            if let info = plantVM.findPlantData(plantType: plant.plantType) {
                await plantVM.loadTips(for: info)
            }
        }
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

#Preview {
    struct PlantSheetPreviewHost: View {
        @State private var detent: PresentationDetent = .large
        @State private var samplePlant: Plant = {
            // Construct a sample Plant with placeholder values
            var p = Plant(
                id: UUID(),
                plantName: "Basil",
                plantType: "Herb",
                plantIconName: "basil", plantDateCreated: Date(),
                plantDateGerminated: Date(), plantIsGerminated: true
            )
            return p
        }()

        var body: some View {
            PlantSheet(
                selectedDetent: $detent,
                plant: samplePlant
            )
            .environmentObject(PlantViewModel())
            .environmentObject(JournalViewModel())
        }
    }

    return PlantSheetPreviewHost()
}
