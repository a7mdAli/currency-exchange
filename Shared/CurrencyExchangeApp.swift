//
//  CurrencyExchangeApp.swift
//  Shared
//
//  Created by Ahmed Basha on 2022/01/12.
//

import SwiftUI
import ComposableArchitecture

@main
struct CurrencyExchangeApp: App {
	let conversionRatesStore = Store(initialState: ConversionRatesState(), reducer: conversionRatesReducer, environment: ConversionRatesEnvironment())
	var body: some Scene {
		WindowGroup {
			RootView(conversionRatesStore: conversionRatesStore)
		}
	}
}
