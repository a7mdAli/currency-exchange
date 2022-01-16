//
//  RootView.swift
//  Shared
//
//  Created by Ahmed Basha on 2022/01/12.
//

import SwiftUI
import ComposableArchitecture

struct RootView: View {

	let conversionRatesStore: Store<ConversionRatesState, ConversionRatesAction>

	var body: some View {
		NavigationView {
			WithViewStore(conversionRatesStore) { conversionRatesViewStore in
				Group {
					if conversionRatesViewStore.rates != nil {
						CurrencyExchangeListView(convertRateStore: conversionRatesStore.convertRateStore)
							.refreshable {
								conversionRatesViewStore.send(.fetchConversionRates)
							}
							.overlay {
								if conversionRatesViewStore.isFetching {
									ProgressView(R.string.localizable.loadingConversionRates())
										.padding()
										.frame(minWidth: 150, minHeight: 150)
										.background(.thinMaterial)
										.clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
								}
							}
					} else if conversionRatesViewStore.isFetching {
						ProgressView(R.string.localizable.loadingConversionRates())
					} else {
						VStack(spacing: 16) {
							Text(R.string.localizable.rootViewErrorTitle())
								.font(.headline)
							Text(R.string.localizable.rootViewErrorMessage())
								.font(.caption)

							Button {
								conversionRatesViewStore.send(.fetchConversionRates)
							} label: {
								Image(systemName: "arrow.clockwise")
									.frame(minWidth: 44, minHeight: 44)
									.contentShape(Rectangle())
							}
						}
						.multilineTextAlignment(.center)
						.padding(.horizontal, 24)
					}
				}
				.task {
					// check persisted data
					conversionRatesViewStore.send(.dataPersistenceAction(.setFromPersistedDataIfNil))
					// initiate a fetch request
					conversionRatesViewStore.send(.fetchConversionRates)
				}
				.alert(conversionRatesStore.scope(state: \.alert), dismiss: ConversionRatesAction.dismissAlert)
			}
			.navigationBarTitle(R.string.localizable.rootViewNavigationTitle())
			.navigationBarTitleDisplayMode(.inline)
		}
	}
}

struct RootView_Previews: PreviewProvider {
	static var previews: some View {
		RootView(
			conversionRatesStore: Store(
				initialState: ConversionRatesState(),
				reducer: conversionRatesReducer,
				environment: ConversionRatesEnvironment(persistenceController: .preview)
			)
		)
	}
}
