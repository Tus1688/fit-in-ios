

import SwiftUI
import HealthKit

struct ContentView: View {
    @State private var lastInteractionTime = Date()
    @State private var sleepDuration: TimeInterval = 0
    @State private var authorizationRequested = false
    let healthKitManager = HealthKitManager()

    var body: some View {
        NavigationView {
            VStack {
                Text("You've been sleeping for \(formattedSleepDuration)")
                    .padding()

                Button("Simulate Sleep") {
                    if !authorizationRequested {
                        // Request HealthKit authorization when the button is pressed for the first time
                        healthKitManager.requestAuthorization { success in
                            if success {
                                startSleepTracking()
                            } else {
                                print("Failed to authorize HealthKit.")
                            }
                        }
                        authorizationRequested = true
                    } else {
                        simulateSleep()
                    }
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            .padding()
            .navigationTitle("Sleep Tracker")
        }
    }

    private func startSleepTracking() {
        Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { timer in
            if UIApplication.shared.applicationState == .active {
                // User touched the phone
                lastInteractionTime = Date()
            } else {
                // Phone is not being actively used
                let timeSinceLastInteraction = Date().timeIntervalSince(lastInteractionTime)
                
                // If timeSinceLastInteraction is greater than one minute, add to sleep duration
                if timeSinceLastInteraction > 60 {
                    sleepDuration += timeSinceLastInteraction
                    
                    // Save sleep data to HealthKit
                    saveSleepDataToHealthKit(duration: timeSinceLastInteraction)
                }
            }
        }
    }

    private func simulateSleep() {
        // Simulate sleep by setting a fixed sleep duration
        lastInteractionTime = Date()
        sleepDuration = 0
    }

    private func saveSleepDataToHealthKit(duration: TimeInterval) {
        // Create a sleep type identifier
        let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!
        
        // Create a sample for sleep
        let sleepSample = HKCategorySample(
            type: sleepType,
            value: HKCategoryValueSleepAnalysis.inBed.rawValue,
            start: Date(),
            end: Date(timeIntervalSinceNow: duration)
        )

        // Save the sleep sample to HealthKit
        healthKitManager.healthStore.save(sleepSample) { (success, error) in
            if success {
                print("Sleep data saved to HealthKit.")
            } else {
                print("Failed to save sleep data to HealthKit. \(error?.localizedDescription ?? "")")
            }
        }
    }

    private var formattedSleepDuration: String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute]
        formatter.unitsStyle = .abbreviated
        return formatter.string(from: sleepDuration) ?? ""
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct HealthKitManager {
    let healthStore = HKHealthStore()

    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(false)
            return
        }

        let typesToRead: Set<HKObjectType> = [
            HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!
        ]

        healthStore.requestAuthorization(toShare: nil, read: typesToRead) { (success, error) in
            completion(success)
        }
    }
}


