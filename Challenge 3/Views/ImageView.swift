import SwiftUI
import PhotosUI

struct GradientButtonStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .foregroundColor(.white) // <-- White text
            .frame(width: 150)        // <-- Same width for both buttons
            .padding()
            .background(
                LinearGradient(
                    colors: [
                        Color.green.opacity(0.95),
                        Color.cyan.opacity(0.95)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.6),
                                Color.white.opacity(0.15)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.2
                    )
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: Color.green.opacity(0.35), radius: 14, x: 0, y: 6)
            .shadow(color: Color.cyan.opacity(0.25), radius: 22, x: 0, y: 12)
    }
}

extension View {
    func gradientButton() -> some View {
        self.modifier(GradientButtonStyle())
    }
}

struct ImageView: View {
    @State private var selectedImage: UIImage?
    @State private var selectedItem: PhotosPickerItem?
    @State private var cameraViewShown: Bool = false

    var body: some View {
        VStack {
            if let selectedImage {
                Image(uiImage: selectedImage)
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 40))
                    .padding()
            } else {
                Text("No image selected")
                    .foregroundStyle(.gray)
                    .padding()
            }

            // TAKE PHOTO BUTTON
            Button {
                cameraViewShown.toggle()
            } label: {
                Text("Take Photo")
                    .gradientButton()
            }
            .sheet(isPresented: $cameraViewShown) {
                CameraView(image: $selectedImage)
            }

            // PICK IMAGE BUTTON
            PhotosPicker(selection: $selectedItem, matching: .images) {
                Text("Pick Image")
                    .gradientButton()
            }
            .onChange(of: selectedItem) { item in
                if let item = item {
                    Task {
                        if let data = try? await item.loadTransferable(type: Data.self) {
                            selectedImage = UIImage(data: data)
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    ImageView()
}
