//
//  BandwidthControl.swift
//  currency-exchange-iOS
//
//  Created by Ahmed Basha on 2022/01/15.
//

import Foundation
import OSLog

private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "CurrencyLayerBandwidthControl")

protocol BandwidthControl {
	var timeIntervalToRestrainInSeconds: TimeInterval { get }
	var isRestricted: Bool { get }
	func didUseBandwidth()
}

final class CurrencyLayerBandwidthControl: BandwidthControl {
	private let identifier: String

	private var key: String {
		"currency_layer_bandwidth_control_" + identifier
	}

	let timeIntervalToRestrainInSeconds: TimeInterval

	var isRestricted: Bool {
		guard let date = UserDefaults.standard.value(forKey: key) as? Date else { return false }
		return Date() < date
	}

	init(identifier: String, timeIntervalToRestrainInSeconds: TimeInterval =  30 * 60) {
		self.identifier = identifier
		self.timeIntervalToRestrainInSeconds = timeIntervalToRestrainInSeconds
	}

	func didUseBandwidth() {
		// TODO: Consider something other than UserDefaults. As UserDefaults are relatively easy to modify.
		let dateToLiftRestriction = Date().addingTimeInterval(timeIntervalToRestrainInSeconds)
		UserDefaults.standard.set(dateToLiftRestriction, forKey: key)
		logger.info("\(self.key) did use bandwidth. Will lift restriction on \(dateToLiftRestriction)")
	}
}
