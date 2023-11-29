//
//  CaloriesView.swift
//  fit-in
//
//  Created by MacBook Pro on 25/11/23.
//

import SwiftUI
import Charts
import CoreData

struct CaloriesView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \UserData.id, ascending: true)],
        animation: .default)
    private var users: FetchedResults<UserData>
    
    @State private var eaten = 0.0
    
    var body: some View {
        NavigationLink(destination: CaloriesDetailView()) {
            if let user = users.first {
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
                .background(.ultraThickMaterial)
                .cornerRadius(10)
                .onAppear {
                    fetchTodayEatingLog()
                }
            } else {
                Text("No data")
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func fetchTodayEatingLog() {
        let request: NSFetchRequest<EatingLog> = EatingLog.fetchRequest()
        
        // Get the current calendar with local time zone
        var calendar = Calendar.current
        calendar.timeZone = NSTimeZone.local
        
        // Get today's beginning & end
        let dateFrom = calendar.startOfDay(for: Date()) // eg. 2016-10-10 00:00:00
        let dateTo = calendar.date(byAdding: .day, value: 1, to: dateFrom)
        // Note: Times are printed in UTC. Depending on where you live it won't print 00:00:00 but it will work with UTC times which can be converted to local time
        
        // Set predicate as date being today's date
        let fromPredicate = NSPredicate(format: "timestamp >= %@", dateFrom as NSDate)
        let toPredicate = NSPredicate(format: "timestamp < %@", dateTo! as NSDate)
        let datePredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [fromPredicate, toPredicate])
        request.predicate = datePredicate
        
        do {
            let data = try viewContext.fetch(request)
            
            if !data.isEmpty {
                var temp = 0.0
                for x in data {
                    temp += x.calorie
                }
                eaten = temp
            }
        } catch {
            print("Error fetching data: \(error.localizedDescription)")
        }
    }
}

#Preview {
    CaloriesView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
