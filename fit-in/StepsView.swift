//
//  StepsView.swift
//  fit-in
//
//  Created by MacBook Pro on 26/11/23.
//

import SwiftUI
import HealthKit
import Charts

struct StepsView: View {
    @Environment(\.managedObjectContext)  private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \UserData.id, ascending: true)],
        animation: .default)
    private var users: FetchedResults<UserData>
    
    @State private var steps = 0.0
    
    var body: some View {
        NavigationLink(destination: StepsDetailView()) {
            if let user = users.first {
                VStack {
                    HStack {
                        Text("Steps")
                            .font(.headline)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.leading)
                        Spacer()
                    }
                    ZStack {
                        Chart {
                            SectorMark(angle: .value(Text("Stepped"), steps), innerRadius: .ratio(0.95))
                                .foregroundStyle(.green)
                            SectorMark(angle: .value (Text("Left"), max(Int(user.stepsTarget) - Int(steps), 0)), innerRadius: .ratio(0.95))
                                .foregroundStyle(.clear)
                        }
                        VStack {
                            Text(String(format: "%d", max(Int(user.stepsTarget) - Int(steps), 0)))
                                .font(.headline)
                                .fontWeight(.black)
                            Text("steps left")
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                    }
                    .padding(.vertical)
                    HStack {
                        Text("Steps")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .italic()
                        Spacer()
                        Text(String(Int(steps)))
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
        .buttonStyle(PlainButtonStyle())
        .onAppear {
            checkHealthKitAuthorization()
        }
    }
    
    // checkHealthKitAuthorization check if the user has authorized access to HealthKit
    func checkHealthKitAuthorization() {
        guard HKHealthStore.isHealthDataAvailable() else {
            print("HealthKit is not available on this device.")
            return
        }
        
        let healthStore = HKHealthStore()
        
        let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        
        healthStore.requestAuthorization(toShare: [], read: [stepType]) { success, error in
            if let error = error {
                print("HealthKit authorization failed with error: \(error.localizedDescription)")
                return
            }
            if success {
                fetchStepsData()
            } else {
                print("HealthKit authorization denied.")
            }
        }
    }

    // Function to fetch total steps for today
    private func fetchStepsData() {
        let healthStore = HKHealthStore()
        
        guard let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
            print("Step count data type is unavailable.")
            return
        }
        
        var calendar = Calendar.current
        calendar.timeZone = NSTimeZone.local
        
        // Get today's beginning & end
        let startOfToday = calendar.startOfDay(for: Date()) // eg. 2016-10-10 00:00:00
        let endOfToday = calendar.date(byAdding: .day, value: 1, to: startOfToday)
        
        let predicate = HKQuery.predicateForSamples(withStart: startOfToday, end: endOfToday, options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: stepType, quantitySamplePredicate: predicate, options: .cumulativeSum) { query, result, error in
            guard let result = result, let sum = result.sumQuantity() else {
                if let error = error {
                    print("Failed to fetch step count data with error: \(error.localizedDescription)")
                }
                return
            }
            
            steps = sum.doubleValue(for: HKUnit.count())
        }
        
        healthStore.execute(query)
    }
}

#Preview {
    StepsView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
