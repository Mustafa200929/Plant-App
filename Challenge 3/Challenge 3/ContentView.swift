//
//  ContentView.swift
//  Challenge 3
//
//  Created by Mustafa Topiwala on 15/11/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
       HomeView()
    }
}

#Preview {
    ContentView()
        .environmentObject(PlantViewModel())
}
