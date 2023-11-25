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
    
    
    var body: some View {
        NavigationView {
            if userData.isEmpty {
                OnBoardingView()
            } else {
                VStack {
                    Text("Hello blabla")
                        .navigationTitle("Welcome \(userData[0].firstName ?? "Unknown")")
                    
                    Spacer()
                    
                    NavigationLink(destination: OnBoardingView()) {
                        Text("Go to Onboarding")
                            .padding()
                    }
                }
                .navigationTitle("Welcome \(userData[0].firstName ?? "Unknown")")
            }
        }
    }
}

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
