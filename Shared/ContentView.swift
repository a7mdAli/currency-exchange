//
//  ContentView.swift
//  Shared
//
//  Created by Ahmed Basha on 2022/01/12.
//

import SwiftUI
import ComposableArchitecture

struct ContentView: View {

	let conversionRatesStore: Store<ConversionRatesState, ConversionRatesAction>

	var body: some View {
		Text("Hello, world!")
	}
}

struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		ContentView(
			conversionRatesStore: Store(
				initialState: ConversionRatesState(),
				reducer: conversionRatesReducer,
				environment: ConversionRatesEnvironment(persistenceController: .preview)
			)
		)
	}
}
