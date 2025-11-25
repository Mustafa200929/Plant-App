//
//  Story.swift
//  Challenge 3
//
//  Created by Mustafa Topiwala on 20/11/25.
//

//
//  Story.swift
//  Challenge 3
//
//  Created by Han on 19/11/2025.
//


import SwiftUI

struct TypewriterText: View {
    let fullText: String
    var speed: Double = 0.02
    @State private var shownText: String = ""

    var body: some View {
        Text(shownText)
            .onAppear {
                shownText = ""
                var charIndex = 0.0
                for letter in fullText {
                    DispatchQueue.main.asyncAfter(deadline: .now() + charIndex * speed) {
                        shownText.append(letter)
                    }
                    charIndex += 1
                }
            }
    }
}

@ViewBuilder
func speechBox<Content: View>(@ViewBuilder content: () -> Content) -> some View {
    VStack(alignment: .leading, spacing: 0) {
        content()
            .frame(maxWidth: .infinity, alignment: .leading)
            .font(.title2)
            .fontWeight(.bold)
            .foregroundColor(.white)
            .padding()
    }
    .frame(width: 300, height: 200)
    .background(Color.black.opacity(0.4))
    .cornerRadius(20)
    .shadow(radius: 10)
}


struct StoryFlow: View {
    @State private var pageIndex: Int = 0
    @AppStorage("hasFinishedStory") var hasFinishedStory = false
    @State private var navigateHome = false

    var body: some View {
        ZStack {
            if navigateHome {
                        HomeView()
            } else {
                switch pageIndex {
                case 0:
                    StoryPage(
                        background: "ST1",
                        text: "Welcome to Gardens! You are an adventurer, travelling amongst the seas...",
                        showNavigation: true,
                        onNext: { pageIndex = 1 }
                    )
                    
                case 1:
                    StoryPage(
                        background: "STII",
                        text: "A... SHARK, it's heading to you! You look around to see what you can do...",
                        showNavigation: true,
                        onBack: { pageIndex = 0 },
                        onNext: { pageIndex = 2 }
                    )
                    
                case 2:
                    StoryFinalPage(navigateHome: $navigateHome, onBack: { pageIndex = 1 })
                default:
                    EmptyView()
                }
            }
        }
    }
}


struct StoryPage: View {
    var background: String
    var text: String
    var showNavigation: Bool = true
    var onBack: (() -> Void)? = nil
    var onNext: (() -> Void)? = nil

    var body: some View {
        ZStack {
            Image(background)
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            VStack {
                Spacer()

                speechBox {
                    TypewriterText(fullText: text)
                }
                .padding(.bottom, 40)

                if showNavigation {
                    HStack(spacing: 30) {
                        if let onBack = onBack {
                            Button(action: onBack) {
                                navButton(label: "Back", systemImage: "chevron.left")
                            }
                        }
                        if let onNext = onNext {
                            Button(action: onNext) {
                                navButton(label: "Next", systemImage: "chevron.right")
                            }
                        }
                    }
                    .padding(.bottom, 50)
                }
            }
        }
    }

    
    func navButton(label: String, systemImage: String) -> some View {
        HStack {
            Image(systemName: systemImage)
            Text(label)
                .fontWeight(.semibold)
        }
        .padding(.horizontal, 28)
        .padding(.vertical, 14)
        .foregroundColor(.white)
        .background(
            RoundedRectangle(cornerRadius: 40)
                .fill(Color.white.opacity(0.12))
                .shadow(color: Color.white.opacity(0.6), radius: 12)
                .shadow(color: Color.blue.opacity(0.4), radius: 18)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 40)
                .stroke(Color.white.opacity(0.35), lineWidth: 1)
        )
    }

    }


struct StoryFinalPage: View {
    @Binding var navigateHome: Bool
    @State private var fadeToBlack = false
    @AppStorage("hasFinishedStory") var hasFinishedStory = false
    
    var onBack: () -> Void = {}

    var body: some View {
        ZStack {
            Image("STIII")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            VStack {
                Spacer()

                speechBox {
                    TypewriterText(fullText:
"""
You jump to the side just in time — the shark glides past with a splash... an ISLAND!
"""
                    )
                }

                
                Button(action: startPlanting) {
                    HStack {
                        Image(systemName: "leaf.fill")
                        Text("Start Planting")
                            .fontWeight(.bold)
                    }
                    .padding(.horizontal, 36)
                    .padding(.vertical, 16)
                    .foregroundColor(.white)
                    .background(
                        RoundedRectangle(cornerRadius: 40)
                            .fill(Color.white.opacity(0.12))
                            .shadow(color: Color.green.opacity(0.6), radius: 12)
                            .shadow(color: Color.green.opacity(0.4), radius: 18)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 40)
                            .stroke(Color.white.opacity(0.35), lineWidth: 1)
                    )
                }
                .padding(.top, 10)

            
                Button(action: onBack) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Back")
                            .fontWeight(.semibold)
                    }
                    .padding(.horizontal, 26)
                    .padding(.vertical, 14)
                    .foregroundColor(.white)
                    .background(
                        RoundedRectangle(cornerRadius: 40)
                            .fill(Color.white.opacity(0.10))
                            .shadow(color: Color.white.opacity(0.3), radius: 10)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 40)
                            .stroke(Color.white.opacity(0.25), lineWidth: 1)
                    )
                }
                .padding(.bottom, 60)
            }

          
            Color.black
                .ignoresSafeArea()
                .opacity(fadeToBlack ? 1 : 0)
                .animation(.easeInOut(duration: 2), value: fadeToBlack)
        }
    }

    func startPlanting() {
        fadeToBlack = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            hasFinishedStory = true
            navigateHome = true
        }
    }
}


#Preview {
    StoryFlow()
        .environmentObject(PlantViewModel())
        .environmentObject(JournalViewModel())
}

