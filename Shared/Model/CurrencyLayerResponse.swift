//
//  CurrencyLayerResponse.swift
//  currency-exchange
//
//  Created by Ahmed Basha on 2022/01/13.
//

import Foundation

struct APIError: Equatable, Error, Decodable {
	let code: Int
	let info: String
}

struct CurrencyLayerAPIResponse: Decodable {
	enum APIResponseKeys: String, CodingKey {
		case success, error, timestamp, source, quotes
	}

	enum ConversionRatesKeys: String, CodingKey {
		case timestamp, source, quotes
	}

	let success: Bool
	let error: APIError?
	let conversionRates: ConversionRates?

	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: APIResponseKeys.self)
		self.success = try container.decode(Bool.self, forKey: .success)
		self.error = try? container.decode(APIError.self, forKey: .error)
		self.conversionRates = try? ConversionRates(from: decoder)
	}
}

struct ConversionRates: Equatable, Decodable {
	@DateValue<UNIXTimestampCodingStrategy>
	var timestamp: Date
	let source: String
	// TODO: Consider changing the string to a type later?
	let quotes: [String: Double]
}
