//
//  CurrencyImage.swift
//  currency-exchange-iOS
//
//  Created by Ahmed Basha on 2022/01/17.
//

import SwiftUI

struct CurrencyImage: View {
	let currency: String

	var body: some View {
		Image(currency.lowercased())
			.resizable()
			.scaledToFill()
			.frame(width: 27, height: 18)
			.background {
				Text("🤷‍♂️")
			}
			.clipped()
			.border(Color.primary)
	}
}

struct CurrencyImage_Previews: PreviewProvider {
	static var previews: some View {
		let gridItem = GridItem(.flexible(minimum: 45, maximum: .infinity), spacing: 8, alignment: .center)
		Group {
			LazyVGrid(columns: [gridItem, gridItem, gridItem]) {
				CurrencyImage(currency: "USD")
				CurrencyImage(currency: "JPY")
				CurrencyImage(currency: "EGP")
				CurrencyImage(currency: "BTC")
				CurrencyImage(currency: "HUH")
				CurrencyImage(currency: "WHA")
			}
			.padding()
			LazyVGrid(columns: [gridItem, gridItem, gridItem]) {
				CurrencyImage(currency: "USD")
				CurrencyImage(currency: "JPY")
				CurrencyImage(currency: "EGP")
				CurrencyImage(currency: "BTC")
				CurrencyImage(currency: "HUH")
				CurrencyImage(currency: "WHA")
			}
			.padding()
			.preferredColorScheme(.dark)
		}
		.previewLayout(.sizeThatFits)
	}
}
