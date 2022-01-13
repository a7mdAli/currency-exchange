//
//  DateValue.swift
//  currency-exchange
//
//  Created by Ahmed Basha on 2022/01/13.
//

import Foundation

// Reference: https://github.com/marksands/BetterCodable

/// A protocol for providing a custom strategy for encoding and decoding dates.
///
/// `DateValueCodableStrategy` provides a generic strategy type that the `DateValue` property wrapper can use to inject
///  custom strategies for encoding and decoding date values.
protocol DateValueCodableStrategy {
	associatedtype RawValue: Codable
	static func decode(_ value: RawValue) throws -> Date
	static func encode(_ date: Date) -> RawValue
}

/// Decodes and encodes dates using a strategy type.
///
/// `@DateValue` decodes dates using a `DateValueCodableStrategy` which provides custom decoding and encoding functionality.
@propertyWrapper
struct DateValue<Formatter: DateValueCodableStrategy>: Codable, Equatable {
	private(set) var value: Formatter.RawValue
	var wrappedValue: Date {
		didSet {
			value = Formatter.encode(wrappedValue)
		}
	}

	init(wrappedValue: Date) {
		self.wrappedValue = wrappedValue
		self.value = Formatter.encode(wrappedValue)
	}

	init(from decoder: Decoder) throws {
		self.value = try Formatter.RawValue(from: decoder)
		self.wrappedValue = try Formatter.decode(value)
	}

	func encode(to encoder: Encoder) throws {
		try value.encode(to: encoder)
	}

	static func == (lhs: DateValue<Formatter>, rhs: DateValue<Formatter>) -> Bool {
		lhs.wrappedValue == rhs.wrappedValue
	}
}

/// Decodes & Encodes `Date` values from and to timestamp values.
///
/// * Decodes a `UNIXTimestamp`  value (e.g. 1430401802) into a Date.
/// * Encodes a `Date` into a `UNIXTimestamp`.
struct UNIXTimestampCodingStrategy: DateValueCodableStrategy {
	typealias UNIXTimestamp = Int
	static func decode(_ value: UNIXTimestamp) throws -> Date {
		return Date(timeIntervalSince1970: Double(value))
	}

	static func encode(_ date: Date) -> UNIXTimestamp {
		return Int(date.timeIntervalSince1970)
	}
}
