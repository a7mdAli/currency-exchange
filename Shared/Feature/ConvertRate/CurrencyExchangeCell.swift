//
//  CurrencyExchangeCell.swift
//  currency-exchange-iOS
//
//  Created by Ahmed Basha on 2022/01/17.
//

import SwiftUI

struct CurrencyExchangeCell: View {
	let currency: String
	let convertedAmount: Double
	let specifier: Int

	var body: some View {
		HStack {
			CurrencyImage(currency: currency)

			Text(currency)
				.fontWeight(.bold)

			Spacer()

			Text("\(convertedAmount, specifier: "%0.\(specifier)f")")
				.fontWeight(.bold)
		}
		.padding(.horizontal, 16)
		.padding(.vertical, 24)
		.foregroundColor(.primary)
	}
}

struct CurrencyExchangeCell_Previews: PreviewProvider {
    static var previews: some View {
        CurrencyExchangeCell(
					currency: "USD",
					convertedAmount: 100,
					specifier: 2
				)
				.previewLayout(.sizeThatFits)
    }
}
