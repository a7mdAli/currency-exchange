//
//  ConvertRateStore.swift
//  currency-exchange-iOS
//
//  Created by Ahmed Basha on 2022/01/15.
//

import Foundation
import ComposableArchitecture

struct Rate: Equatable, Identifiable {
	var id: String { currency }
	let currency: String
	let rate: Double
}

struct ConvertRateState: Equatable {
	var amountToConvert: Double = 0
	var rates: [Rate] = []

	var source: Rate? { rates.first }
	var ratesToConvert: [Rate] { Array(rates.dropFirst()) }

	func convertedAmount(for destination: Rate) -> Double {
		guard !rates.isEmpty else { fatalError("Ensure rates are appropriately set first.") }
		// amount * destinationRate
		// ------------------------
		//       sourceRate
		// ↑ This equation will ensure we always get the correct
		//   conversion for a any two currencies given a single
		//   shared source currency between the two.
		//
		// For example, if the initial state is
		// source = USD -> 1
		// rates = [
		//    JPY -> 115,
		//    EGP -> 16.5
		// ]
		//
		// to convert from USD to JPY we simply apply the equation (assuming amount = 1USD)
		// convertedAmount = (1 * 115) / 1 = 115
		// to convert from USD to EGP we would do the same ending up with 16.5
		//
		// If we later change the source to be EGP, and now we want to convert to JPY
		// we simply apply the same equation again and it should work as intended
		// ※ Given they have the same shared original source USD
		// convertedAmount = (1 * 115) / 16.5 = 6.69
		return (amountToConvert * destination.rate) / source!.rate
	}
}

enum ConvertRateAction: Equatable {
	case updateWithConversionRates(ConversionRates)
	case changeSource(to: Rate)
	case setAmount(String)
	case move(fromOffsets: IndexSet, toOffset: Int)
}

struct ConvertRateEnvironment {}

let convertRateReducer = Reducer<ConvertRateState, ConvertRateAction, ConvertRateEnvironment>.combine(
	Reducer { state, action, _ in
		switch action {
		case let .updateWithConversionRates(rates):
			var mappedRates: [Rate] = []
			mappedRates.reserveCapacity(rates.quotes.count + 1) // +1 for the original source (e.g. USD)
			mappedRates.append(Rate(currency: rates.source, rate: 1.0))
			mappedRates.append(
				contentsOf: rates.quotes
					.map { currency, rate -> Rate in
					guard currency.hasPrefix(rates.source) else {
						return Rate(currency: currency, rate: rate)
					}

					return Rate(
						// remove source string (USDJPY -> JPY)
						currency: String(currency[currency.index(currency.startIndex, offsetBy: rates.source.count)...]),
						rate: rate
					)
				}
				.sorted(by: { $0.currency <= $1.currency })
			)

			state.rates  = mappedRates
			return .none

		case let .changeSource(newSource):
			guard state.source != newSource else { return .none }
			if let currentIndexForNewSource = state.rates.firstIndex(of: newSource) {
				state.rates.move(fromOffsets: [currentIndexForNewSource], toOffset: 0)
			}
			return .none

		case let .setAmount(amount):
			if amount.isEmpty {
				state.amountToConvert = 0
			} else if let doubleValue = Double(amount) {
				state.amountToConvert = doubleValue
			} else {
				// TODO: show error message
			}
			return .none

		case let .move(fromOffsets, toOffset):
			state.rates.move(fromOffsets: fromOffsets, toOffset: toOffset)
			return .none
		}
	}
)
