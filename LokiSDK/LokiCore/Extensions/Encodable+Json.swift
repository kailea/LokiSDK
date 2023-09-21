//
//  Encodable+Json.swift
//  LokiSampleApp
//
//  Created by Amandeep Kaile on 17/4/2023.
//

import Foundation

extension Data {
	var prettyJson: String? {
		guard let object = try? JSONSerialization.jsonObject(with: self, options: []),
			  let data = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted, .withoutEscapingSlashes, .sortedKeys]),
			  let jsonString = String(data: data, encoding: .utf8) else {
			return nil
		}
		return jsonString
	}
}
