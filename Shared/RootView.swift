//
//  RootView.swift
//  Shared
//
//  Created by Ahmed Basha on 2022/01/12.
//

import SwiftUI
import ComposableArchitecture

struct RootView: View {

	let conversionRatesStore: Store<ConversionRatesState, ConversionRatesAction>

	var body: some View {
		Text("Hello, world!")
	}
}

struct RootView_Previews: PreviewProvider {
	static var previews: some View {
		RootView(
			conversionRatesStore: Store(
				initialState: ConversionRatesState(),
				reducer: conversionRatesReducer,
				environment: ConversionRatesEnvironment(persistenceController: .preview)
			)
		)
	}
}
