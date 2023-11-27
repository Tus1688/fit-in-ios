//
//  SummaryView.swift
//  fit-in
//
//  Created by MacBook Pro on 25/11/23.
//

import SwiftUI
import CoreData

struct SummaryView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \UserData.id, ascending: true)],
        animation: .default)
    private var users: FetchedResults<UserData>
    
    var body: some View {
        if self.users.isEmpty{
            NavigationStack {
                VStack {
                    Text("Welcome to fit-in")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.bottom, 50)
                    Text("You have no data yet.")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .padding(.bottom, 20)
                    Text("Please add your data to get started.")
                        .font(.headline)
                        .fontWeight(.regular)
                        .padding(.bottom, 20)
                    NavigationLink(destination: ProfileView()) {
                        Text("Add your data")
                            .fontWeight(.semibold)
                            .padding(.horizontal, 30)
                            .padding(.vertical, 10)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .padding()
            }
        }
        else{
            if let user = users.first {
                NavigationStack {
                    VStack(spacing: 24) {
                        HStack(spacing: 24) {
                            CaloriesView()
                            WaterIntakeView()
                        }
                        HStack(spacing: 24) {
                            StepsView()
                            WaterIntakeView()
                        }
                    }
                    .padding()
                    .navigationTitle("Hello, \(user.firstName!)")
                }
            }
        }
    }
}

#Preview {
    SummaryView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
