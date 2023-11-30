//
//  CalorieSettingView.swift
//  fit-in
//
//  Created by MacBook Pro on 26/11/23.
//

import SwiftUI
import CoreData

struct CalorieSettingView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var target = 0.0
    @State private var isShowingAlert = false
    @State private var alertMessage = ""
    @State private var bmr = 0.0
    
    var body: some View {
        NavigationStack{
            VStack(spacing: 16) {
                Text("Set a goal based on how much calories, or how much calories you'd like to be, each day (Your BMR is \(String(format: "%.f", bmr)) kcal/day)")
                Spacer()
                
                VStack {
                    HStack(spacing: 40) {
                        Button {
                            target -= 100
                            saveuserData()
                        } label: {
                            Text("-")
                                .fontWeight(.black)
                                .padding()
                                .background(.thinMaterial)
                                .foregroundColor(.primary)
                        }
                        .clipShape(Circle())
                        
                        Text("\(String(format: "%.f", target))")
                            .font(.title)
                            .fontWeight(.bold)
                            .keyboardType(.numberPad)
                            .frame(width: 120)
                            .multilineTextAlignment(.center)
                        
                        Button {
                            target += 100
                            saveuserData()
                        } label: {
                            Text("+")
                                .fontWeight(.black)
                                .padding()
                                .background(.thinMaterial)
                                .foregroundColor(.primary)
                        }
                        .clipShape(Circle())
                    }
                    Text("Kilocalories/Day")
                        .font(.title3)
                        .bold()
                }
                Spacer()
            }
            .navigationTitle("Your Daily Intake")
            .onAppear {
                fetchUserData()
            }
            .padding()
            .alert(isPresented: $isShowingAlert) {
                Alert(title: Text("Uh.. oh..."),
                      message: Text(alertMessage),
                      dismissButton: .default(Text("Got it"))
                )
            }
        }
    }
    private func fetchUserData() {
        // Fetch UserData with id = 1
        let request: NSFetchRequest<UserData> = UserData.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", NSNumber(value: 1))
        
        do {
            let userData = try viewContext.fetch(request)
            if let user = userData.first {
                target = user.calorieTarget
                bmr = user.bmr
            }
        } catch {
            isShowingAlert = true
            alertMessage = "Unable to fetch data"
        }
    }
    
    private func saveuserData() {
        // Fetch UserData with id = 1 and update calorieTarget
        let request: NSFetchRequest<UserData> = UserData.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", NSNumber(value: 1))
        
        do {
            let userData = try viewContext.fetch(request)
            
            if let user = userData.first {
                user.calorieTarget = target
                try viewContext.save()
            }
        } catch {
            isShowingAlert = true
            alertMessage = "Unable to save data"
        }
    }
}

#Preview {
    CalorieSettingView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
