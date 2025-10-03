//
//  ContentView.swift
//  MAP_AS02
//
//  Created by Kanwaljot Singh on 2025-10-01.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            Part1View()
                .tabItem {
                    Image(systemName: "1.circle.fill")
                    Text("Part 1")
                }

            Part2View()
                .tabItem {
                    Image(systemName: "2.circle.fill")
                    Text("Part 2")
                }
        }
        .accentColor(.red)
    }
}

#Preview {
    ContentView()
}
