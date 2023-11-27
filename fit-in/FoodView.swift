//
//  FoodView.swift
//  fit-in
//
//  Created by MacBook Pro on 25/11/23.
//

import SwiftUI
import CoreData

struct FoodEntry: Codable {
    let FoodCategory: String
    let FoodItem: String
    let per100grams: String
    let Cals_per100grams: String
    let KJ_per100grams: String
}

struct FoodView: View {
    @Environment(\.managedObjectContext) private var viewContext
        
    var body: some View {
        NavigationStack {
            VStack {
                Text("Food Data")
                SearchBar()
                ScrollView{
                    CategoryList()
                }
            }
            .padding()
            
            Spacer()
        }
        .onAppear {
            if let path = Bundle.main.path(forResource: "FoodData", ofType: "json") {
                do {
                    let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                    let decoder = JSONDecoder()
                    let foodEntries = try decoder.decode([FoodEntry].self, from: data)

                    for entry in foodEntries {
                        saveFoodData(
                            foodName: entry.FoodItem,
                            foodCategory: entry.FoodCategory,
                            foodCalory: entry.Cals_per100grams
                        )
                    }
                } catch {
                    print("Error loading data from FoodData.json: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func saveFoodData(foodName: String, foodCategory: String, foodCalory: String) {
        do {
            let newFoodData = FoodData(context: viewContext)
            newFoodData.foodName = foodName
            newFoodData.foodCategory = foodCategory

            if let caloryValueString = foodCalory.components(separatedBy: " ").first,
               let caloryValue = Int16(caloryValueString) {
                newFoodData.foodCalory = caloryValue
            } else {
                print("Error parsing foodCalory string.")
            }

            try viewContext.save()
        } catch {
            print("Error saving food data: \(error.localizedDescription)")
        }
    }
}

struct SearchBar: View {
    @State private var searchText: String = ""

    var body: some View {
        GeometryReader { geometry in
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                TextField("Search", text: $searchText)
            }
            .padding(8)
            .background(Color(.systemGray6))
            .cornerRadius(8)
            .frame(width: geometry.size.width)
        }
        .frame(height: 45)
    }
}

struct CategoryList: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        entity: FoodData.entity(),
        sortDescriptors: [],
        predicate: NSPredicate(value: true),
        animation: .default
    )
    
    var foodData: FetchedResults<FoodData>
    
    var categories: [String] {
        Array(Set(foodData.compactMap { $0.foodCategory }))
    }

    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(), count: 3), spacing: 12) {
            ForEach(categories, id: \.self) { category in
                NavigationLink(destination: FoodDetail(category: category)) {
                    CategoryFrame(category: category)
                }
            }
        }
    }
}

struct CategoryFrame: View {
    let category: String
    
    var body: some View {
        VStack {
            Spacer()
            Text(category)
                .font(.caption)
                .multilineTextAlignment(.center)
                .foregroundColor(.black)
        }
        .padding()
        .frame(width: 110, height: 140)
        .background(Color.white)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.gray, lineWidth: 0.1)
        )
        .shadow(
            color: Color.gray.opacity(0.5),
            radius: 3,
            x: 0,
            y: 2
        )
    }
}

struct FoodDetail: View {
    let category: String

    var body: some View {
        VStack {
            Text("Food Detail for \(category)")
                .font(.title)
                .padding()
        }
        .navigationTitle("Food Detail")
    }
}

struct FoodView_Previews: PreviewProvider {
    static var previews: some View {
        FoodView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
