//
//  CurrencyExchangeListView.swift
//  currency-exchange-iOS
//
//  Created by Ahmed Basha on 2022/01/16.
//

import SwiftUI
import ComposableArchitecture

struct CurrencyExchangeListView: View {
	private typealias LocalViewStore = ViewStore<ConvertRateState, ConvertRateAction>

	private enum Field: Hashable {
		case search
		case amountToConvert
	}

	let convertRateStore: Store<ConvertRateState, ConvertRateAction>

	@State private var amount = ""
	@State private var searchText = ""
	@FocusState private var focusedField: Field?
	@State private var specifier = 2

	var body: some View {
		WithViewStore(convertRateStore) { convertRateViewStore in
			ZStack {
				VStack(alignment: .leading, spacing: 0) {
					VStack {
						inputTextField(convertRateViewStore)
						if !convertRateViewStore.inputErrorMessage.isEmpty {
							Text(convertRateViewStore.inputErrorMessage)
								.font(.caption)
								.frame(maxWidth: .infinity, alignment: .leading)
								.foregroundColor(.red)
						}
					}
					.padding()
					Divider()
					exchangeRateListView(convertRateViewStore)
				}
				// using opacity instead of conditional views, because
				// we can't change focus between input fields otherwise.
				.opacity(focusedField == .search ? 0 : 1)
				searchView(convertRateViewStore)
					.opacity(focusedField == .search ? 1 : 0)
			}
			.animation(.default, value: convertRateViewStore.inputErrorMessage)
			.animation(.default, value: focusedField)
			.toolbar {
				ToolbarItem(placement: .navigationBarTrailing) {
					if focusedField != .search {
						Button {
							focusedField = .search
						} label: {
							Image(systemName: "magnifyingglass")
								.frame(minWidth: 44, minHeight: 44)
						}
					}
				}
			}
			.modifier(DismissKeyboardToolbar(isFocused: $focusedField))
		}
	}

	// MARK: Input TextField

	private func inputTextField(_ convertRateViewStore: LocalViewStore) -> some View {
		HStack {
			VStack(spacing: 4) {
				CurrencyImage(currency: convertRateViewStore.source?.currency ?? "")
				Text(convertRateViewStore.source?.currency ?? R.string.localizable.notApplicable())
			}
			.offset(y: 4) // offset to visually center it with TextField

			textField(
				"0.0",
				text: Binding(
					get: {
						amount
					}, set: {
						amount = $0
						convertRateViewStore.send(.setAmount($0))
					})
			)
			.keyboardType(.decimalPad)
			.focused($focusedField, equals: .amountToConvert)
			.simultaneousGesture(
				TapGesture().onEnded {
					focusedField = .amountToConvert
				}
			)
		}
	}

	// MARK: Exchange Rate ListView

	private func exchangeRateListView(_ convertRateViewStore: LocalViewStore) -> some View {
		List {
			ForEach(convertRateViewStore.ratesToConvert.indices, id: \.self) { index in
				let rate = convertRateViewStore.ratesToConvert[index]
				Button {
					didTap(rate: rate, convertRateViewStore: convertRateViewStore)
				} label: {
					CurrencyExchangeCell(
						currency: rate.currency,
						convertedAmount: convertRateViewStore.state.convertedAmount(for: rate),
						specifier: specifier
					)
					.contextMenu {
						Button {
							UIPasteboard.general.string = "\(convertRateViewStore.state.convertedAmount(for: rate))"
						} label: {
							Text(R.string.localizable.copyExchangeAmount())
						}
					}
				}
			}
			.listRowInsets(EdgeInsets(top: 2, leading: 0, bottom: 0, trailing: 0))
			.listRowSeparator(.hidden)
		}
		.listStyle(.plain)
		// Change decimal point precision gesture
		.gesture(DragGesture().onEnded({ dragGesture in
			if abs(dragGesture.translation.width) > abs(dragGesture.translation.height) {
				let shouldIncreaseSpecifier = dragGesture.translation.width < 0
				if shouldIncreaseSpecifier {
					specifier += 1
				} else if specifier > 0 {
					specifier -= 1
				}
			}
		}))
	}

	private func didTap(rate: Rate, convertRateViewStore: LocalViewStore) {
		convertRateViewStore.send(.changeSource(to: rate))
		focusedField = .amountToConvert
		amount = ""
	}

	// MARK: Search Suggestions View

	private func searchView(_ convertRateViewStore: LocalViewStore) -> some View {
		VStack {
			HStack(spacing: 8) {
				textField("JPY", text: $searchText)
					.keyboardType(.alphabet)
					.textInputAutocapitalization(.characters)
					.disableAutocorrection(true)
					.focused($focusedField, equals: .search)
				Button {
					focusedField = nil
					searchText = ""
				} label: {
					Text(R.string.localizable.cancel())
				}
			}
			.padding()
			Divider()
			ScrollView {
				searchSuggestions(convertRateViewStore)
			}
			Spacer(minLength: 0)
		}
	}

	@ViewBuilder
	private func searchSuggestions(_ convertRateViewStore: LocalViewStore) -> some View {
		let gridItem = GridItem(.flexible(minimum: 45, maximum: .infinity), spacing: 8, alignment: .center)
		LazyVGrid(columns: [gridItem, gridItem, gridItem]) {
			ForEach(convertRateViewStore.ratesToConvert.filter { $0.currency.contains(searchText.uppercased()) }) { rate in
				VStack(spacing: 4) {
					CurrencyImage(currency: rate.currency)
					Text(rate.currency)
						.fontWeight(.bold)
						.onTapGesture {
							didTap(rate: rate, convertRateViewStore: convertRateViewStore)
							searchText = ""
						}
				}
				.padding(.horizontal, 16)
				.padding(.vertical, 24)
			}
		}
	}

	// MARK: Reusable Views

	private func textField(_ title: String, text: Binding<String>) -> some View {
		TextField(title, text: text)
			.padding(.horizontal, 8)
			.frame(height: 44)
			// SwiftUI.TextField's tappable area doesn't change according to custom frames
			// so we need to add our own custom tap handling logic to workaround that.
			.contentShape(Rectangle())
			.background(Color(R.color.backgroundSecondary.name))
			.clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
	}

}

struct CurrencyExchangeListView_Previews: PreviewProvider {
	static let conversionRatesStore = Store(
		initialState: ConversionRatesState(),
		reducer: conversionRatesReducer,
		environment: ConversionRatesEnvironment(persistenceController: .preview)
	)
	static var previews: some View {
		RootView(conversionRatesStore: conversionRatesStore)
	}
}
