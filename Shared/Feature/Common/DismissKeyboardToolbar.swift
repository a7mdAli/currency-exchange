//
//  DismissKeyboardToolbar.swift
//  currency-exchange-iOS
//
//  Created by Ahmed Basha on 2022/01/17.
//

import SwiftUI

struct DismissKeyboardToolbar<Field: Hashable>: ViewModifier {
	var isFocused: FocusState<Field?>.Binding

	func body(content: Content) -> some View {
		ZStack {
			content
			if isFocused.wrappedValue != nil {
				VStack {
					Spacer()
					HStack {
						Spacer()
						Button {
							isFocused.wrappedValue = nil
						} label: {
							Image(systemName: "keyboard.chevron.compact.down")
								.frame(minWidth: 44, minHeight: 44)
						}
					}
					.frame(height: 50)
					.padding(.horizontal)
					.background(Color(R.color.backgroundSecondary.name))
				}
			}
		}
	}
}
