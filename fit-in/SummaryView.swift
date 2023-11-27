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
                        HStack {
                            Text("Hello, \(user.firstName!)")
                                .font(.largeTitle.bold())
                            Spacer()
                            NavigationLink(destination: ProfileView()) {
                                Image(systemName: "person.crop.circle.fill")
                                    .font(.largeTitle.bold())
                                    .symbolRenderingMode(.multicolor)
                                    .foregroundStyle(.gray)
                            }
                        }
                        .padding(.top)
                        HStack(spacing: 24) {
                            CaloriesView()
                            WaterIntakeView()
                        }
                        HStack(spacing: 24) {
                            StepsView()
                            DistanceView()
                        }
                    }
                    .padding()
                    .background(
                        LinearGradient(gradient: Gradient(colors: [Color.orange, Color.clear, Color.clear, Color.clear]), startPoint: .top, endPoint: .bottom)
                            .edgesIgnoringSafeArea(.top) // Extend gradient to the top edge
                    )
                    .navigationBarTitleDisplayMode(.inline)
                }
            }
        }
    }
}

#Preview {
    SummaryView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
