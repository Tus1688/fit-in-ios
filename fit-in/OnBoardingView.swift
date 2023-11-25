//
//  OnBoardingView.swift
//  fit-in
//
//  Created by MacBook Pro on 25/11/23.
//

import SwiftUI
import CoreData

struct OnBoardingView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var age = ""
    @State private var weight = ""
    @State private var height = ""
    @State private var isMale = true // Assuming true for male, false for female
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("My name")) {
                    TextField("First Name", text: $firstName)
                    TextField("Last Name", text: $lastName)
                }
                Section(header: Text("Personal Information")) {
                    TextField("Age", text: $age)
                        .keyboardType(.numberPad)
                    TextField("Weight", text: $weight)
                        .keyboardType(.numberPad)
                    TextField("Height", text: $height)
                        .keyboardType(.numberPad)
                    
                    Picker("Gender", selection: $isMale) {
                        Text("Male").tag(true)
                        Text("Female").tag(false)
                    }
                    .pickerStyle(PalettePickerStyle())
                }
                
                Section {
                    Button("Save") {
                        saveUserData()
                    }
                }
            }
            .navigationTitle("Fit In")
            .onAppear {
                fetchUserData()
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
                // Populate fields with fetched data
                firstName = user.firstName ?? ""
                lastName = user.lastName ?? ""
                age = "\(user.age)" 
                weight = "\(user.weight)" 
                height = "\(user.height)" 
                isMale = user.gender
            }
        } catch {
            print("Error fetching data: \(error.localizedDescription)")
        }
    }
    
    private func saveUserData() {
        guard let age = Int16(age),
              let weight = Int16(weight),
              let height = Int16(height) else {
            // TODO: Handle invalid input
            
            return
        }

        let request: NSFetchRequest<UserData> = UserData.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", NSNumber(value: 1))

        do {
            let userData = try viewContext.fetch(request)
            if let user = userData.first {
                user.firstName = firstName
                user.lastName = lastName
                user.age = age
                user.weight = weight
                user.height = height
                user.gender = isMale

                try viewContext.save()
            }
        } catch {
            // TODO: Handle the Core Data save error
            print("Error saving data: \(error.localizedDescription)")
        }
    }
}


#Preview {
    OnBoardingView()
}
