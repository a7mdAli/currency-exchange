//
//  currency_exchangeApp.swift
//  Shared
//
//  Created by Ahmed Basha on 2022/01/12.
//

import SwiftUI

@main
struct currency_exchangeApp: App {
	let persistenceController = PersistenceController.shared
	
	var body: some Scene {
		WindowGroup {
			ContentView()
				.environment(\.managedObjectContext, persistenceController.container.viewContext)
		}
	}
}
