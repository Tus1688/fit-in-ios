//
//  WaterIntakeSettingView.swift
//  fit-in
//
//  Created by MacBook Pro on 26/11/23.
//

import SwiftUI
import CoreData

struct WaterIntakeDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var isBouncing = false
    @State private var drank = 1000
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Image(systemName: "waterbottle")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .padding()
                    .scaleEffect(isBouncing ? 1.2 : 1.0) // Scale effect for bounce
                    .onTapGesture {
                        withAnimation {
                            self.isBouncing.toggle()
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            withAnimation {
                                self.isBouncing = false
                            }
                        }
                        incrementDrank()
                    }
                    .gesture(
                        DragGesture()
                            .onEnded { value in
                                if value.translation.height > 50 {
                                    decrementDrank() // Decrement drank count
                                }
                            }
                    )
                VStack(spacing: 8) {
                    Text("You have drank \(drank) cups")
                        .font(.title3)
                        .fontWeight(.bold)
                    Text("Press the bottle to add 1 cup\nSwipe the bottle down to subtract 1 cup")
                        .multilineTextAlignment(.center)
                }
            }
            .navigationTitle("Water Intake")
        }
        .onAppear {
            fetchWaterIntake()
        }
    }
    
    private func fetchWaterIntake() {
        let request: NSFetchRequest<WaterIntake> = WaterIntake.fetchRequest()
        // Get the current calendar with local time zone
        var calendar = Calendar.current
        calendar.timeZone = NSTimeZone.local
        
        // Get today's beginning & end
        let dateFrom = calendar.startOfDay(for: Date()) // eg. 2016-10-10 00:00:00
        let dateTo = calendar.date(byAdding: .day, value: 1, to: dateFrom)
        // Note: Times are printed in UTC. Depending on where you live it won't print 00:00:00 but it will work with UTC times which can be converted to local time
        
        // Set predicate as date being today's date
        let fromPredicate = NSPredicate(format: "%@ >= %K", dateFrom as NSDate, #keyPath(WaterIntake.date))
        let toPredicate = NSPredicate(format: "%K < %@", #keyPath(WaterIntake.date), dateTo! as NSDate)
        let datePredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [fromPredicate, toPredicate])
        request.predicate = datePredicate
        
        do {
            let data = try viewContext.fetch(request)
            
            if data.isEmpty {
                //  If there is no data, create a new data with today's date
                let newWaterIntake = WaterIntake(context: viewContext)
                newWaterIntake.date = Calendar.current.startOfDay(for: Date())
                newWaterIntake.amount = 0
                drank = 0
                
                try viewContext.save()
                return
            }
            if let existingIntake = data.first {
                drank = Int(existingIntake.amount)
            }
        } catch {
            print("Error fetching data: \(error.localizedDescription)")
        }
    }
    
    private func saveWaterIntake() {
        let request: NSFetchRequest<WaterIntake> = WaterIntake.fetchRequest()
        // Get the current calendar with local time zone
        var calendar = Calendar.current
        calendar.timeZone = NSTimeZone.local
        
        // Get today's beginning & end
        let dateFrom = calendar.startOfDay(for: Date()) // eg. 2016-10-10 00:00:00
        let dateTo = calendar.date(byAdding: .day, value: 1, to: dateFrom)
        // Note: Times are printed in UTC. Depending on where you live it won't print 00:00:00 but it will work with UTC times which can be converted to local time
        
        // Set predicate as date being today's date
        let fromPredicate = NSPredicate(format: "%@ >= %K", dateFrom as NSDate, #keyPath(WaterIntake.date))
        let toPredicate = NSPredicate(format: "%K < %@", #keyPath(WaterIntake.date), dateTo! as NSDate)
        let datePredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [fromPredicate, toPredicate])
        request.predicate = datePredicate
        
        do {
            let results = try viewContext.fetch(request)
            
            if let existingIntake = results.first {
                existingIntake.amount = Int16(drank)
                try viewContext.save()
            }
        } catch {
            print("Error saving water intake: \(error.localizedDescription)")
        }
    }
    
    private func incrementDrank() {
        drank += 1
        saveWaterIntake()
    }
    
    private func decrementDrank() {
        if drank > 0 {
            drank -= 1
            saveWaterIntake()
        }
    }
}

#Preview {
    WaterIntakeDetailView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
