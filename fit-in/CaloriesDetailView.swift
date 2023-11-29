//
//  CaloriesDetailView.swift
//  fit-in
//
//  Created by MacBook Pro on 29/11/23.
//

import SwiftUI
import CoreData

struct CaloriesDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var isShowingSettings = false
    @State private var todayEaten: [EatingLog]?
    
    var body: some View {
        @Environment(\.horizontalSizeClass) var sizeCategory
        
        NavigationStack {
            VStack(spacing: 16){
                if let todayEaten = todayEaten {
                    List {
                        ForEach(todayEaten) { log in
                            VStack(alignment: .leading) {
                                Text(log.foodName!)
                                    .font(.headline)
                                    .fontWeight(.heavy)
                                Text("\(log.timestamp!, formatter: dateFormatter)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Text(String(format: "%.2f Kcal", log.calorie))
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                            }
                        }
                        .onDelete(perform: deleteEatingLog)
                    }
                } else {
                    Text("No food eaten today")
                        .font(.title3)
                        .fontWeight(.medium)
                }
            }
            .navigationTitle("Breakdown")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        isShowingSettings = true
                    }) {
                        Text("Settings")
                    }
                    .sheet(isPresented: $isShowingSettings) {
                        NavigationStack {
                            CalorieSettingView()
                                .navigationTitle("Settings")
                                .navigationBarItems(trailing: Button("Done") {
                                    isShowingSettings = false
                                })
                        }
                    }
                }
            }
            .onAppear {
                fetchTodayEatingLog()
            }
        }
    }
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()
    
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
                todayEaten = data
            }
        } catch {
            print("Error fetching data: \(error.localizedDescription)")
        }
    }
    
    private func deleteEatingLog(offsets: IndexSet) {
        withAnimation {
            offsets.map { todayEaten![$0] }.forEach(viewContext.delete)
            
            do {
                try viewContext.save()
            } catch {
                print("Error deleting data: \(error.localizedDescription)")
            }
        }
    }
}

#Preview {
    CaloriesDetailView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
