//
//  ProfileView.swift
//  fit-in
//
//  Created by MacBook Pro on 25/11/23.
//

import SwiftUI
import CoreData

struct ProfileView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var age = ""
    @State private var weight = ""
    @State private var height = ""
    @State private var isMale = true // Assuming true for male, false for female
    @State private var isShowingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("My name"), footer: Text("This is how your name will be displayed in the app, we do not save nor make your name as identifiable data.")) {
                    TextField("First Name", text: $firstName)
                    TextField("Last Name", text: $lastName)
                }
                Section(header: Text("Personal Information"), footer: Text("Your data is stored locally on your device, we do not collect your data.")) {
                    HStack {
                        if !age.isEmpty {
                            Text("Age")
                        }
                        TextField("Age", text: $age)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(age.isEmpty ? .leading : .trailing)
                    }
                    HStack {
                        if !weight.isEmpty {
                            Text("Weight")
                        }
                        TextField("Weight", text: $weight)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(weight.isEmpty ? .leading : .trailing)
                    }
                    HStack {
                        if !height.isEmpty {
                            Text("Height")
                        }
                        TextField("Height", text: $height)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(height.isEmpty ? .leading : .trailing)
                    }
                    Picker("Gender", selection: $isMale) {
                        Text("Male").tag(true)
                        Text("Female").tag(false)
                    }
                    .pickerStyle(PalettePickerStyle())
                }
                HStack {
                    Spacer()
                    Button("Save") {
                        saveUserData()
                    }
                    Spacer()
                }
            }
            .navigationTitle("Profile")
            .onAppear {
                fetchUserData()
            }
            .alert(isPresented: $isShowingAlert) {
                Alert(title: Text("Howdy.."),
                      message: Text(alertMessage),
                      dismissButton: .default(Text("Got it")))
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
            isShowingAlert = true
            alertMessage = "Please enter valid data"
            
            return
        }
        
        let request: NSFetchRequest<UserData> = UserData.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", NSNumber(value: 1))
        
        do {
            let userData = try viewContext.fetch(request)
            if let user = userData.first {
                // Update existing record
                user.firstName = firstName
                user.lastName = lastName
                user.age = age
                user.weight = weight
                user.height = height
                user.gender = isMale
            } else {
                // Create new record if no data exists
                let newUser = UserData(context: viewContext)
                newUser.id = 1
                newUser.firstName = firstName
                newUser.lastName = lastName
                newUser.age = age
                newUser.weight = weight
                newUser.height = height
                newUser.gender = isMale
            }
            
            try viewContext.save()
            isShowingAlert = true
            alertMessage = "Data updated successfully"
        } catch {
            isShowingAlert = true
            alertMessage = "Error saving data"
            print("Error saving data: \(error.localizedDescription)")
        }
    }
}


#Preview {
    ProfileView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
