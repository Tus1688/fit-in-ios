//
//  fit_inApp.swift
//  fit-in
//
//  Created by MacBook Pro on 24/11/23.
//

import SwiftUI

@main
struct fit_inApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
