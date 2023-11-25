//
//  CaloriesView.swift
//  fit-in
//
//  Created by MacBook Pro on 25/11/23.
//

import SwiftUI
import Charts

struct Product: Identifiable {
    let id = UUID()
    let title: String
    let revenue: Double
}

struct CaloriesView: View {
    @State private var products: [Product] = [
        .init(title: "Annual", revenue: 0.7),
        .init(title: "bla", revenue: 0.3),
    ]
    let chartColors: [Color] = [
        Color(.green),
        Color(.clear),
    ]

    var body: some View {
        GeometryReader { geometry in
            VStack {
                HStack {
                    Text("Calories")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.leading)
                    Spacer()
                }
                ZStack {
                    Chart(products) { product in
                        let index = products.firstIndex { $0.id == product.id } ?? 0
                        let color = index < chartColors.count ? chartColors[index] : .clear

                        SectorMark(
                            angle: .value(
                                Text(verbatim: product.title),
                                product.revenue
                            ),
                            innerRadius: .ratio(0.95)
                        )
                        .foregroundStyle(color)
                    }
                    .chartLegend(.hidden)
                    VStack {
                        Text("500")
                            .font(.headline)
                            .fontWeight(.black)
                        Text("Kcal left")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                }
            }
            .padding()
            .frame(height: geometry.size.height / 3)
            .background(.ultraThickMaterial)
            .cornerRadius(10)
            .padding()
        }
    }
}


#Preview {
    CaloriesView()
}
