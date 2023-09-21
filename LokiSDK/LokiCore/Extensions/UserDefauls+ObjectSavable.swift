//
//  UserDefauls+ObjectSavable.swift
//  LokiSampleApp
//
//  Created by Amandeep Kaile on 18/4/2023.
//

import Foundation

enum ObjectSavableError: String, LocalizedError {
	case unableToEncode = "Unable to encode object into data"
	case noValue = "No data object found for the given key"
	case unableToDecode = "Unable to decode object into given type"
	
	var errorDescription: String? {
		rawValue
	}
}

extension UserDefaults: ObjectSavable {
	func setObject<Object>(_ object: Object, forKey: String) throws where Object: Encodable {
		let encoder = JSONEncoder()
		encoder.dateEncodingStrategy = .customISO8601
		do {
			let data = try encoder.encode(object)
			set(data, forKey: forKey)
		} catch {
			throw ObjectSavableError.unableToEncode
		}
	}
	
	func getObject<Object>(forKey: String, castTo type: Object.Type) throws -> Object where Object: Decodable {
		guard let data = data(forKey: forKey) else { throw ObjectSavableError.noValue }
		let decoder = JSONDecoder()
		decoder.dateDecodingStrategy = .customISO8601
		do {
			let object = try decoder.decode(type, from: data)
			return object
		} catch {
			throw ObjectSavableError.unableToDecode
		}
	}
}
