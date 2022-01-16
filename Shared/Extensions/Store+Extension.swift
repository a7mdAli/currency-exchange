//
//  Store+Extension.swift
//  currency-exchange-iOS
//
//  Created by Ahmed Basha on 2022/01/17.
//

import Foundation
import ComposableArchitecture

extension Store where State == ConversionRatesState, Action == ConversionRatesAction {
	var convertRateStore: Store<ConvertRateState, ConvertRateAction> {
		scope(state: \.convertRateState, action: ConversionRatesAction.convertRateAction)
	}
}
