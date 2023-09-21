//
//  Formatter+ISO8601.swift
//  LokiSampleApp
//
//  Created by Amandeep Kaile on 14/4/2023.
//

import Foundation

extension Formatter {
	static let iso8601withFractionalSeconds: ISO8601DateFormatter = {
		let formatter = ISO8601DateFormatter()
		formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
		return formatter
	}()
	static let iso8601: ISO8601DateFormatter = {
		let formatter = ISO8601DateFormatter()
		formatter.formatOptions = [.withInternetDateTime]
		return formatter
	}()
}
