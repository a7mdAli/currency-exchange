//
//  ConversionRatesStore.swift
//  currency-exchange (iOS)
//
//  Created by Ahmed Basha on 2022/01/14.
//

import Foundation
import ComposableArchitecture
import CoreData
import OSLog

private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "ConversionRatesReducer")

struct ConversionRatesState: Equatable {
	var rates: ConversionRates?
	var convertRateState: ConvertRateState = .init()
	var alert: AlertState<ConversionRatesAction>?
}

enum ConversionRatesAction: Equatable {
	case fetchConversionRates
	case conversionRatesResponse(Result<ConversionRates, APIError>)
	case dismissAlert
	case dataPersistenceAction(DataPersistenceAction)
	case convertRateAction(ConvertRateAction)
}

struct ConversionRatesEnvironment {
	private(set) var mainQueue: AnyScheduler = DispatchQueue.main.eraseToAnyScheduler()
	private(set) var conversionRatesService: ConversionRatesService = ConversionRatesClient()
	private(set) var bandwidthControl: BandwidthControl = CurrencyLayerBandwidthControl(identifier: "conversion_rates")
	private(set) var persistenceController: PersistenceController = .shared
}

let conversionRatesReducer = Reducer<ConversionRatesState, ConversionRatesAction, ConversionRatesEnvironment>.combine(
	convertRateReducer.pullback(
		state: \.convertRateState,
		action: /ConversionRatesAction.convertRateAction,
		environment: { _ in ConvertRateEnvironment() }
	),
	persistDataReducer.pullback(
		state: \.rates,
		action: /ConversionRatesAction.dataPersistenceAction,
		environment: { DataPersistenceEnvironment(persistenceController: $0.persistenceController) }
	),
	Reducer { state, action, environment in
		switch action {
		case .fetchConversionRates:
			guard !environment.bandwidthControl.isRestricted else {
				logger.debug("Bandwidth is restricted!")
				return .none
			}
			environment.bandwidthControl.didUseBandwidth()
			return environment.conversionRatesService
				.fetchConversionRates()
				.catchToEffect(ConversionRatesAction.conversionRatesResponse)
				.receive(on: environment.mainQueue)
				.eraseToEffect()
		case let .conversionRatesResponse(.success(conversionRates)):
			state.rates = conversionRates
			return Effect.concatenate(
				Effect(value: .convertRateAction(.updateWithConversionRates(conversionRates))),
				Effect(value: .dataPersistenceAction(.persistData(conversionRates)))
			)
		case let .conversionRatesResponse(.failure(error)):
			logger.error("Failed to fetch conversionRates (error: \(error))")
			state.alert = AlertState(
				title: .init(R.string.localizable.alertTitle()),
				message: TextState("\(error.info)"),
				dismissButton: .default(TextState(R.string.localizable.alertOKButtonTitle()), action: .send(.dismissAlert))
			)
			return .none
		case .dismissAlert:
			state.alert = nil
			return .none
		case .dataPersistenceAction(.setFromPersistedDataIfNil):
			guard let rates = state.rates else {
				return .none
			}
			return Effect(value: .convertRateAction(.updateWithConversionRates(rates)))
		case .dataPersistenceAction(_):
			return .none
		case .convertRateAction(_):
			return .none
		}
	}
)

// MARK: - Data Persistence

enum DataPersistenceAction: Equatable {
	case setFromPersistedDataIfNil
	case persistData(ConversionRates)
}

private struct DataPersistenceEnvironment {
	private(set) var persistenceController: PersistenceController
}

private let persistDataReducer = Reducer<ConversionRates?, DataPersistenceAction, DataPersistenceEnvironment>.combine(
	Reducer { state, action, environment in
		switch action {
		case .setFromPersistedDataIfNil:
			guard state == nil else { return .none }
			
			do {
				let result = try environment.persistenceController.container.viewContext.fetch(ConversionRatesSnapshot.fetchRequest())
				if !result.isEmpty {
					state = ConversionRates(snapshot: result[0])
				}
			} catch let error as NSError {
				logger.error("Retrieving user failed. \(error): \(error.userInfo)")
			}

			return .none
		case let .persistData(rates):
			var snapshot = ConversionRatesSnapshot(context: environment.persistenceController.container.viewContext)
			snapshot.timestamp = rates.timestamp
			snapshot.source = rates.source
			snapshot.quotes = rates.quotes as NSDictionary

			do {
				// remove previously persisted data
				let deleteOldDataRequest = NSBatchDeleteRequest(fetchRequest: ConversionRatesSnapshot.fetchRequest())
				try environment.persistenceController.container.viewContext.execute(deleteOldDataRequest)
				// save context
				try environment.persistenceController.container.viewContext.save()
			} catch {
				logger.error("Unable to save snapshot. \(error.localizedDescription)")
			}
			return .none
		}
	}
)

private extension ConversionRates {
	init(snapshot: ConversionRatesSnapshot) {
		self.init(timestamp: snapshot.timestamp!, source: snapshot.source!, quotes: snapshot.quotes as! [String: Double])
	}
}
