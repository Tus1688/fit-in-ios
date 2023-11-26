//
//  CaloriesView.swift
//  fit-in
//
//  Created by MacBook Pro on 25/11/23.
//

import SwiftUI
import Charts

struct CaloriesView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \UserData.id, ascending: true)],
        animation: .default)
    private var users: FetchedResults<UserData>
    
    // TODO: retrieve daily calories intake
    let eaten = 1400.0
    
    var body: some View {
        NavigationLink(destination: CalorieSettingView()) {
            if let user = users.first {
                GeometryReader { geometry in
                    VStack {
                        HStack {
                            Text("Calories")
                                .font(.headline)
                                .fontWeight(.bold)
                                .multilineTextAlignment(.leading)
                            Spacer()
                        }
                        ZStack {
                            Chart() {
                                SectorMark(angle: .value(
                                    Text("Eaten"), eaten), innerRadius: .ratio(0.95))
                                .foregroundStyle(.green)
                                SectorMark(angle: .value(
                                    Text("Left"), max(user.calorieTarget - eaten, 0)), innerRadius: .ratio(0.95))
                                .foregroundStyle(.clear)
                            }
                            VStack {
                                Text(String(format: "%.f", max(user.calorieTarget - eaten, 0)))
                                    .font(.headline)
                                    .fontWeight(.black)
                                Text("Kcal left")
                                    .font(.caption)
                                    .fontWeight(.medium)
                            }
                        }
                        .padding(.vertical)
                        HStack {
                            Text("Eaten")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .italic()
                            Spacer()
                            Text(String(format: "%.f kcal", eaten))
                                .font(.caption)
                                .fontWeight(.semibold)
                                .italic()
                        }
                    }
                    .padding()
                    .frame(height: geometry.size.height / 2.5)
                    .background(.ultraThickMaterial)
                    .cornerRadius(10)
                }
            } else {
                Text("No data")
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}


#Preview {
    CaloriesView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)

}
