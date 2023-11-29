//
//  WaterIntakeView.swift
//  fit-in
//
//  Created by MacBook Pro on 26/11/23.
//

import SwiftUI
import Charts
import CoreData

struct WaterIntakeView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \UserData.id, ascending: true)],
        animation: .default)
    private var users: FetchedResults<UserData>
    
    @State private var drank = 0
    
    var body: some View {
        NavigationLink(destination: WaterIntakeDetailView()) {
            if let user = users.first {
                VStack {
                    HStack {
                        Text("Water")
                            .font(.headline)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.leading)
                        Spacer()
                    }
                    ZStack {
                        Chart{
                            SectorMark(angle: .value(Text("Drank"), drank), innerRadius: .ratio(0.95))
                                .foregroundStyle(.green)
                            SectorMark(angle: .value (Text("Left"), max(Int(user.waterIntakeTarget) - drank, 0)), innerRadius: .ratio(0.95))
                                .foregroundStyle(.clear)
                        }
                        VStack {
                            Text(String(format: "%d", max(Int(user.waterIntakeTarget) - drank, 0)))
                                .font(.headline)
                                .fontWeight(.black)
                            Text("cups left")
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                    }
                    .padding(.vertical)
                    HStack {
                        Text("Drank")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .italic()
                        Spacer()
                        Text(String(format: "%d cups", drank))
                            .font(.caption)
                            .fontWeight(.semibold)
                            .italic()
                    }
                }
                .padding()
                .background(.ultraThickMaterial)
                .cornerRadius(10)
            }
        }
        .onAppear {
            fetchWaterIntake()
        }
        .buttonStyle(PlainButtonStyle())
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
        let fromPredicate = NSPredicate(format: "date >= %@", dateFrom as NSDate)
        let toPredicate = NSPredicate(format: "date < %@", dateTo! as NSDate)
        let datePredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [fromPredicate, toPredicate])
        request.predicate = datePredicate
        
        do {
            let data = try viewContext.fetch(request)
            
            if data.isEmpty {
                //  If there is no data, create a new data with today's date
                let newWaterIntake = WaterIntake(context: viewContext)
                newWaterIntake.id = UUID()
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
            print("Error fetching water intake: \(error.localizedDescription)")
        }
    }
}

#Preview {
    WaterIntakeView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
