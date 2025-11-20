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
    @State private var navigateHome = false
    @AppStorage("hasFinishedStory") var hasFinishedStory = false

    var body: some View {
        NavigationStack {
            Story(navigateHome: $navigateHome)
                .navigationDestination(isPresented: $navigateHome) {
                    HomeView()
                }
        }
    }
}

struct Story: View {
    @Binding var navigateHome: Bool
    
    var body: some View {
        ZStack {
            Image("ST1")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                NavigationLink(destination: STIIView(navigateHome: $navigateHome)) {
                    speechBox {
                        TypewriterText(fullText:
"""
Welcome to Gardens! You are an adventurer, travelling amongst the seas...
"""
                        )
                    }
                }
                .buttonStyle(.plain)
                .padding(.bottom, 40)
            }
        }
    }
}


struct STIIView: View {
    @Binding var navigateHome: Bool
    
    var body: some View {
        ZStack {
            Image("STII")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                NavigationLink(destination: STIIIView(navigateHome: $navigateHome)) {
                    speechBox {
                        TypewriterText(fullText:
"""
A... SHARK, it's heading to you! You look around to see what you can do...
"""
                        )
                    }
                }
                .buttonStyle(.plain)
                .padding(.bottom, 40)
            }
        }
    }
}


struct STIIIView: View {
    @Binding var navigateHome: Bool
    @State private var fadeToBlack = false
    @AppStorage("hasFinishedStory") var hasFinishedStory = false
    
    var body: some View {
        ZStack {
            Image("STIII")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .navigationBarBackButtonHidden(true)
            
            VStack {
                Spacer()
                
                speechBox {
                    TypewriterText(fullText:
"""
You jump to the side just in time — the shark glides past with a splash... an ISLAND!
"""
                    )
                }
                .padding(.bottom, 40)
            }
            
            Color.black
                .ignoresSafeArea()
                .opacity(fadeToBlack ? 1 : 0)
                .animation(.easeInOut(duration: 2), value: fadeToBlack)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                fadeToBlack = true
                    
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    hasFinishedStory = true
                    navigateHome = true
                }
            }
        }
    }
}


#Preview {
    StoryFlow()
        .environmentObject(PlantViewModel())
        .environmentObject(JournalViewModel())
}

