//
//  FoodView.swift
//  fit-in
//
//  Created by MacBook Pro on 25/11/23.
//

import SwiftUI
import CoreData

struct FoodItem: Codable {
    let FoodCategory: String
    let FoodItem: String
    let per100grams: String
    let Cals_per100grams: String
    let KJ_per100grams: String
    var quantity: Int?
}

struct FoodView: View {
    @State private var searchText: String = ""
    @State private var totalCalory: Int = 0
    @State private var foodItems: [FoodItem] = []
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Food Data")
                SearchBar(searchText: $searchText)
                ScrollView {
                    ForEach(filteredFoodItems.indices, id: \.self) { index in
                        FoodFrame(
                            totalCalory: $totalCalory,
                            quantity: $foodItems[index].quantity,
                            foodName: foodItems[index].FoodItem,
                            calory: extractCalories(foodItems[index].Cals_per100grams)
                        )
                        .padding(.bottom, 60)
                    }
                }
                
                TotalCaloryView(totalCalory: $totalCalory, foodItems: $foodItems, searchText: $searchText)
                    .padding()
            }
            .padding()
        }
        .onAppear {
            if let path = Bundle.main.path(forResource: "FoodData", ofType: "json") {
                do {
                    let data = try Data(contentsOf: URL(fileURLWithPath: path))
                    let decoder = JSONDecoder()
                    let tempFoodItems = try decoder.decode([FoodItem].self, from: data)

                    for newItem in tempFoodItems {
                        if !foodItems.contains(where: { $0.FoodItem == newItem.FoodItem }) {
                            foodItems.append(newItem)
                        }
                    }
                } catch {
                    print("Error loading data from FoodData.json: \(error.localizedDescription)")
                }
            }
        }
        
        var filteredFoodItems: [FoodItem] {
            if searchText.isEmpty {
                return foodItems.sorted { $0.FoodItem < $1.FoodItem }
            } else {
                let startsWithSearchText = foodItems.filter { $0.FoodItem.lowercased().hasPrefix(searchText.lowercased()) }
                let containsSearchText = foodItems.filter { !$0.FoodItem.lowercased().hasPrefix(searchText.lowercased()) && $0.FoodItem.lowercased().contains(searchText.lowercased()) }

                let combinedItems = (startsWithSearchText + containsSearchText)
                return combinedItems.sorted { $0.FoodItem < $1.FoodItem }
            }
        }
    }
}

func extractCalories(_ caloryString: String) -> Int {
    if let firstWord = caloryString.split(separator: " ").first,
       let calories = Int(firstWord) {
        return calories
    }
    return 0
}

struct SearchBar: View {
    @Binding var searchText: String

    var body: some View {
        GeometryReader { geometry in
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                TextField("Search", text: $searchText)
                
                if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                            .imageScale(.medium)
                    }
                    .padding(.trailing, 4)
                }
            }
            .padding(8)
            .background(Color(.systemGray6))
            .cornerRadius(8)
            .frame(width: geometry.size.width)
        }
        .frame(height: 45)
    }
}

struct FoodFrame: View {
    @Binding var totalCalory: Int
    @Binding var quantity: Int?
    let foodName: String
    let calory: Int

    var body: some View {
        GeometryReader { geometry in
            HStack {
                Image(systemName: "fork.knife")
                    .resizable()
                    .padding(.trailing, 10)
                    .padding(.vertical, 5)
                    .frame(width: 40, height: 40)
                
                VStack(alignment: .leading) {
                    Text(foodName)
                        .font(.headline)
                    Text("\(calory) calories per 100 grams")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .italic()
                }
                
                Spacer()
                HStack {
                    Button("-") {
                        let currentQuantity = quantity ?? 0
                        if currentQuantity > 0 {
                            totalCalory -= calory
                            quantity = currentQuantity - 1
                        }
                    }
                    .padding(5)
                    
                    if let currentQuantity = quantity {
                        Text("\(currentQuantity)")
                    } else {
                        Text("0")
                    }

                    Button("+") {
                        let currentQuantity = quantity ?? 0
                        totalCalory += calory
                        quantity = currentQuantity + 1
                    }
                    .padding(5)
                }
                .background(Color(.systemGray6))
                .cornerRadius(4)
            }
            .padding()
        }
    }
}

struct TotalCaloryView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @Binding var totalCalory: Int
    @Binding var foodItems: [FoodItem]
    @Binding var searchText: String

    var body: some View {
        HStack {
            if totalCalory > 0 {
                Text("Total: \(totalCalory) calories")
            } else {
                Text("Total: \(totalCalory) calory")
            }
            
            Spacer()
            
            Button("Save") {
                for var foodItem in foodItems {
                    if let quantity = foodItem.quantity, quantity > 0 {
                        let eatingLog = EatingLog(context: viewContext)
                        eatingLog.calorie = Double(quantity * extractCalories(foodItem.Cals_per100grams))
                        eatingLog.foodName = foodItem.FoodItem
                        eatingLog.id = UUID()
                        eatingLog.timestamp = Date()
                        
                        do {
                            try viewContext.save()
                        } catch {
                            print("Error saving to Core Data: \(error.localizedDescription)")
                        }
                        
                        foodItem.quantity = nil
                        searchText = ""
                    }
                }
            }
        }
    }
}

struct FoodView_Previews: PreviewProvider {
    static var previews: some View {
        FoodView()
    }
}
