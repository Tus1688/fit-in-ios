//
//  DistanceView.swift
//  fit-in
//
//  Created by MacBook Pro on 27/11/23.
//

import SwiftUI
import HealthKit
import Charts

struct DistanceView: View {
    @Environment(\.managedObjectContext)  private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \UserData.id, ascending: true)],
        animation: .default)
    private var users: FetchedResults<UserData>
    
    @State private var steps = 0.0
    
    var body: some View {
        if let user = users.first {
            VStack {
                HStack {
                    Text("Distance")
                        .font(.headline)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.leading)
                    Spacer()
                }
                ZStack {
                    Chart {
                        SectorMark(angle: .value(Text("Stepped"), user.gender ? steps * 0.762 : steps * 0.67), innerRadius: .ratio(0.95))
                            .foregroundStyle(.green)
                        SectorMark(angle: .value (Text("Left"), max(user.gender ? (Double(user.stepsTarget) * 0.762 - steps * 0.762) : (Double(user.stepsTarget) * 0.67 - steps * 0.67), 0)), innerRadius: .ratio(0.95))
                            .foregroundStyle(.clear)
                    }
                    VStack {
                        Text("\(Int(user.gender ? (Double(user.stepsTarget) * 0.762 - steps * 0.762) : (Double(user.stepsTarget) * 0.67 - steps * 0.67)))")
                            .font(.headline)
                            .fontWeight(.black)
                        Text("meters left")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                }
                .padding(.vertical)
                HStack {
                    Text("Meters")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .italic()
                    Spacer()
                    Text(String(user.gender ? steps * 0.762 : steps * 0.67))
                        .font(.caption)
                        .fontWeight(.semibold)
                        .italic()
                }
            }
            .padding()
            .background(.ultraThickMaterial)
            .cornerRadius(10)
            .onAppear {
                checkHealthKitAuthorization()
            }
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
        
        let startOfToday = Calendar.current.startOfDay(for: Date())
        let endOfToday = Calendar.current.date(byAdding: .day, value: 1, to: startOfToday)!
        
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
    DistanceView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
