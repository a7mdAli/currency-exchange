//
//  ConversionRatesStore.swift
//  currency-exchange (iOS)
//
//  Created by Ahmed Basha on 2022/01/14.
//

import Foundation
import ComposableArchitecture

struct ConversionRatesState: Equatable {
	// TODO: persist last fetch timestamp
	var rates: ConversionRates?
}

enum ConversionRatesAction: Equatable {
	case fetchConversionRates
	case conversionRatesResponse(Result<ConversionRates, APIError>)
}

struct ConversionRatesEnvironment {
	private(set) var mainQueue: AnyScheduler = DispatchQueue.main.eraseToAnyScheduler()
	private(set) var conversionRatesService: ConversionRatesService = ConversionRatesClient()
}

let conversionRatesReducer = Reducer<ConversionRatesState, ConversionRatesAction, ConversionRatesEnvironment>.combine(
	Reducer { state, action, environment in
		switch action {
		case .fetchConversionRates:
			return environment.conversionRatesService
				.fetchConversionRates()
				.catchToEffect(ConversionRatesAction.conversionRatesResponse)
				.receive(on: environment.mainQueue)
				.eraseToEffect()
		case let .conversionRatesResponse(.success(conversionRates)):
			state.rates = conversionRates
			return .none
		case let .conversionRatesResponse(.failure(error)):
			// TODO: Handle Errors
			return .none
		}
	}
)
