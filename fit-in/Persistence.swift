//
//  Persistence.swift
//  fit-in
//
//  Created by MacBook Pro on 24/11/23.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        
        let newUserData = UserData(context: viewContext)
        newUserData.id = 1
        newUserData.firstName = "John"
        newUserData.lastName = "Doe"
        newUserData.age = 21
        newUserData.weight = 70
        newUserData.height = 170
        newUserData.calorieTarget = 2000
        newUserData.bmr = 2000
        newUserData.gender = true
        newUserData.waterIntakeTarget = 8
        newUserData.stepsTarget = 1500
        
        let newWaterIntake = WaterIntake(context: viewContext)
        newWaterIntake.date = Calendar.current.startOfDay(for: Date())
        newWaterIntake.amount = 5
        
        let randomCalories = [100.5, 200.2, 300.1, 400.7, 500.5]
        let randomFood = ["food A", "food B", "food C", "food D"]
        let today = Calendar.current.startOfDay(for: Date())
        
        for i in 0..<4 {
            let newCalorieIntake = EatingLog(context: viewContext)
            
            newCalorieIntake.id = UUID()
            newCalorieIntake.timestamp = today
            newCalorieIntake.calorie = randomCalories.randomElement()!
            newCalorieIntake.foodName = randomFood.randomElement()
        }
        
        for i in 1..<7 {
            let newCalorieIntake = EatingLog(context: viewContext)
            
            newCalorieIntake.id = UUID()
            newCalorieIntake.timestamp = Calendar.current.date(byAdding: .day, value: -1 * i, to: Date())
            newCalorieIntake.calorie = randomCalories.randomElement()!
            newCalorieIntake.foodName = randomFood.randomElement()
        }
        
        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "fit_in")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
