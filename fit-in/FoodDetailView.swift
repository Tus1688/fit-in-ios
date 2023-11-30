//
//  FoodDetailView.swift
//  fit-in
//
//  Created by MacBook Pro on 30/11/23.
//

import SwiftUI

struct FoodDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    var food: FoodItem
    @State private var amountGram = 0
    @State private var isShowingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationStack {
            VStack {
                VStack {
                    Text(food.FoodItem)
                        .font(.title)
                        .fontWeight(.bold)
                    Text(food.Cals_per100grams + " per 100 gram")
                        .font(.title3)
                }
                .padding()
                Spacer()
                
                VStack(spacing: 16) {
                    Text("fill amount you ate in grams")
                        .font(.caption)
                    HStack(spacing: 40) {
                        Button {
                            if amountGram >= 100 {
                                amountGram -= 100
                            }
                        } label: {
                            Text("-")
                                .fontWeight(.black)
                                .padding()
                                .background(.thinMaterial)
                                .foregroundColor(.primary)
                        }
                        .clipShape(Circle())
                        
                        TextField("Amount (grams)", value: $amountGram, formatter: NumberFormatter())
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .font(.title)
                            .fontWeight(.bold)
                            .keyboardType(.numberPad)
                            .frame(width: 120)
                            .multilineTextAlignment(.center)
                        
                        Button {
                            amountGram += 100
                        } label: {
                            Text("+")
                                .fontWeight(.black)
                                .padding()
                                .background(.thinMaterial)
                                .foregroundColor(.primary)
                        }
                        .clipShape(Circle())
                    }
                }
                .padding()
                
                Button(action: {
                    InsertEatingLog()
                }) {
                    Text("Submit")
                        .fontWeight(.bold)
                        .padding(4)
                }
                .buttonStyle(.borderedProminent)
                Spacer()
            }
        }
        .alert(isPresented: $isShowingAlert, content: {
            Alert(title: Text("Howdy.."),
                  message: Text(alertMessage),
                  dismissButton: .default(Text("Got it")))
        })
    }
    func extractCalories(_ caloryString: String) -> Int {
        if let firstWord = caloryString.split(separator: " ").first,
           let calories = Int(firstWord) {
            return calories
        }
        return 0
    }
    
    func InsertEatingLog() {
        if amountGram > 0{
            let caloriesPer100Grams = extractCalories(food.Cals_per100grams)
            let consumedCalories = (Double(amountGram) / 100.0) * Double(caloriesPer100Grams)
            
            let eatingLog = EatingLog(context: viewContext)
            eatingLog.calorie = consumedCalories
            eatingLog.foodName = food.FoodItem
            eatingLog.id = UUID()
            eatingLog.timestamp = Date()
            
            do {
                try viewContext.save()
            } catch {
                print("Error saving to Core Data: \(error.localizedDescription)")
            }
            isShowingAlert = true
            alertMessage = "\(food.FoodItem) has been inserted to log"
            amountGram = 0
            return
        }
        isShowingAlert = true
        alertMessage = "Amount you ate shouldn't below 1"
    }
}

#Preview {
    FoodDetailView(food: FoodItem(FoodItem: "food", Cals_per100grams: "100 cal"))
}
