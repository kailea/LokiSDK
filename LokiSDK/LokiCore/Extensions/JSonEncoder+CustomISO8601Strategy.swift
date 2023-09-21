//
//  JSonEncoder+CustomISO8601Strategy.swift
//  LokiSampleApp
//
//  Created by Amandeep Kaile on 14/4/2023.
//

import Foundation

extension JSONDecoder.DateDecodingStrategy {
	static let customISO8601 = custom {
		let container = try $0.singleValueContainer()
		let string = try container.decode(String.self)
		if let date = Formatter.iso8601withFractionalSeconds.date(from: string) ?? Formatter.iso8601.date(from: string) {
			return date
		}
		throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid date: \(string)")
	}
}

extension JSONEncoder.DateEncodingStrategy {
	static let customISO8601 = custom {
		var container = $1.singleValueContainer()
		try container.encode(Formatter.iso8601withFractionalSeconds.string(from: $0))
	}
}
