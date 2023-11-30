//
//  CaloriesDetailView.swift
//  fit-in
//
//  Created by MacBook Pro on 29/11/23.
//

import SwiftUI
import CoreData
import Charts

struct CaloriesDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var isShowingSettings = false
    @State private var todayEaten: [EatingLog]?
    
    var body: some View {
        NavigationStack {
            VStack{
                if let todayEaten = todayEaten {
                    WeeklyCaloriesView()
                    List {
                        ForEach(todayEaten, id: \.self) { log in
                            HStack(alignment: .bottom) {
                                VStack(alignment: .leading) {
                                    Text(log.foodName!)
                                        .font(.headline)
                                        .fontWeight(.heavy)
                                    Text(String(format: "%.2f Kcal", log.calorie))
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                }
                                Spacer()
                                Text("\(log.timestamp!, formatter: dateFormatter)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
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

struct weeklyCaloriesData {
    var date: String
    var total: Double
}

struct WeeklyCaloriesView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var weeklyCalories: [weeklyCaloriesData] = []
    
    var body: some View {
        VStack {
            Chart(weeklyCalories, id: \.date) { item in
                BarMark(
                    x: .value("Date", item.date),
                    y: .value("Total", item.total)
                )
                .cornerRadius(4)
                .foregroundStyle(.green)
            }
            .chartYAxis {
                AxisMarks(position: .trailing) { _ in
                     AxisGridLine().foregroundStyle(.clear)
                     AxisTick().foregroundStyle(.clear)
                    AxisValueLabel()
                }
            }
            .chartXAxis {
                AxisMarks(position: .bottom) { _ in
                     AxisGridLine().foregroundStyle(.clear)
                     AxisTick().foregroundStyle(.clear)
                    AxisValueLabel()
                }
            }
            .padding()
            .frame(height: 200)
        }
        .onAppear {
            fetchWeeklyCalories()
        }
    }
    
    private func fetchWeeklyCalories() {
        let request: NSFetchRequest<EatingLog> = EatingLog.fetchRequest()
        
        // Get the current calendar with local time zone
        var calendar = Calendar.current
        calendar.timeZone = NSTimeZone.local
        
        // Get today's beginning & end
        let today = Date()
        
        // Calculate the date 7 days ago from today
        guard let sevenDaysAgo = calendar.date(byAdding: .day, value: -7, to: today) else {
            return
        }
        
        // Set predicate for the past 7 days
        let fromPredicate = NSPredicate(format: "timestamp >= %@", sevenDaysAgo as NSDate)
        let toPredicate = NSPredicate(format: "timestamp <= %@", today as NSDate)
        let datePredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [fromPredicate, toPredicate])
        request.predicate = datePredicate
        
        do {
            let logs = try viewContext.fetch(request)
            
            // Group EatingLog objects by date and sum calories for each date
            let groupedLogs = Dictionary(grouping: logs) { log -> Date in
                return calendar.startOfDay(for: log.timestamp ?? Date())
            }
            
            // Calculate total calories for each grouped date
            for (date, logs) in groupedLogs {
                let totalCalories = logs.reduce(0) { $0 + ($1.calorie ) }
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "d MMM"
                let dateString = dateFormatter.string(from: date)
                
                let weeklyData = weeklyCaloriesData(date: dateString, total: totalCalories)
                weeklyCalories.append(weeklyData)
            }
            
            // Sort the weeklyCalories array by date in ascending order
            weeklyCalories.sort { first, second in
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "d MMM"
                
                guard let date1 = dateFormatter.date(from: first.date),
                      let date2 = dateFormatter.date(from: second.date) else {
                    return false
                }
                return date1 < date2
            }
        } catch {
            print("Error fetching data: \(error.localizedDescription)")
        }
    }
}

#Preview {
    CaloriesDetailView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
