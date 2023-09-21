//
//  LokiEncodable+Dictionary.swift
//  Loki
//
//  Created by Amandeep Kaile on 12/4/2023.
//

import Foundation
extension Encodable {
	func toDictionary() throws -> [String: Any] {
		let encoder = JSONEncoder()
		encoder.dateEncodingStrategy = .iso8601
		let data = try encoder.encode(self)
		guard let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else { throw NSError() }
		return dictionary
	}
	
	func toJSON() throws -> String {
		let encoder = JSONEncoder()
		encoder.dateEncodingStrategy = .iso8601
		let data = try encoder.encode(self)
		let result = String(decoding: data, as: UTF8.self)
		return result
	}
}
