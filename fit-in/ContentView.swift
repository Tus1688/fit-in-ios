//
//  ContentView.swift
//  fit-in
//
//  Created by MacBook Pro on 24/11/23.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \UserData.age, ascending: true)],
        animation: .default)
    private var userData: FetchedResults<UserData>
    
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            SummaryView()
                .tabItem {
                    Text("Summary")
                    Image(systemName: "chart.bar.fill")
                }
                .tag(0)
            
            ProfileView()
                .tabItem {
                    Text("Profile")
                    Image(systemName: "person.fill")
                }
                .tag(2)
            
            FoodView()
                .tabItem {
                    Text("Food")
                    Image(systemName: "leaf.fill")
                }
                .tag(3)
        }
        .edgesIgnoringSafeArea(.top)
    }
}

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
