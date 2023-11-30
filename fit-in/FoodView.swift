//
//  FoodView.swift
//  fit-in
//
//  Created by MacBook Pro on 25/11/23.
//

import SwiftUI
import CoreData

struct FoodItem: Codable,Hashable {
    let FoodItem: String
    let Cals_per100grams: String
}

struct FoodView: View {
    @State private var searchText: String = ""
    @State private var foodItems: [FoodItem] = []
    @State private var filteredFoodItems: [FoodItem] = []
    
    var body: some View {
        NavigationStack {
            VStack {
                List {
                    ForEach(filteredFoodItems, id: \.self) { item in
                        NavigationLink(destination: FoodDetailView(food: item)) {
                            HStack(spacing: 16) {
                                Image(systemName: "fork.knife")
                                VStack(alignment: .leading) {
                                    Text(item.FoodItem)
                                        .font(.headline)
                                    Text("\(item.Cals_per100grams) calories per 100 grams")
                                        .font(.subheadline)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Food List")
            .searchable(text: $searchText)
        }
        .onChange(of: searchText) {
            filterFoodItems()
        }
        .onAppear {
            loadFoodItems()
        }
    }
    
    func loadFoodItems() {
        DispatchQueue.global().async {
            if let fileURL = Bundle.main.url(forResource: "FoodData", withExtension: "json") {
                do {
                    let data = try Data(contentsOf: fileURL)
                    let decoder = JSONDecoder()
                    
                    let tempFoodItems = try decoder.decode([FoodItem].self, from: data)
                    
                    DispatchQueue.main.async {
                        foodItems = tempFoodItems
                        filteredFoodItems = tempFoodItems
                    }
                } catch {
                    print("Error loading or parsing JSON file: \(error.localizedDescription)")
                }
            }
        }
    }
    func filterFoodItems() {
        if searchText.isEmpty {
            filteredFoodItems = foodItems
        } else {
            filteredFoodItems = foodItems.filter { $0.FoodItem.localizedCaseInsensitiveContains(searchText) }
        }
    }
}

#Preview {
    FoodView()
}
