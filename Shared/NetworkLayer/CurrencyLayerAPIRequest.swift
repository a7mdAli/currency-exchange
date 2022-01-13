//
//  CurrencyLayerAPIRequest.swift
//  currency-exchange
//
//  Created by Ahmed Basha on 2022/01/13.
//

import Foundation


let accessKey: String = {
	guard let filePath = Bundle.main.path(forResource: "CurrencyLayerAPIKey.generated", ofType: "plist") else {
		// Note: Trying to access this value from the test bundle would err.
		//       as the bundle is different, and we've only added the plist
		//       into the main app bundle.
		fatalError("Couldn't find file. Make sure the file 'CurrencyLayerAPIKey.generated.plist' is setup correctly.")
	}

	let plist = NSDictionary(contentsOfFile: filePath)

	guard let value = plist?.object(forKey: "access_key") as? String else {
		fatalError("Make sure a string value for the key 'access_key' is in 'CurrencyLayerAPIKey.generated.plist'.")
	}

	return value
}()

struct CurrencyLayerAPIRequest: APIRequestProtocol {
	let baseURL: String = "http://api.currencylayer.com/"
	let relativePath: String
	let method: HTTPMethod
	let parameters: Encodable?
	let headers: Headers

	init(
		relativePath: String,
		method: HTTPMethod = .get,
		headers: Headers = [:]
	) {
		self.relativePath = relativePath
		self.method = method
		// TODO: Allow user to pass custom parameters (with the current implementation it's unnecessary)
		self.parameters = ["access_key": accessKey]
		self.headers = headers
	}
}
