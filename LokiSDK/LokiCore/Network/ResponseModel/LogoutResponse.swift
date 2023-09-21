//
//  LogoutResponse.swift
//  LokiSampleApp
//
//  Created by Amandeep Kaile on 20/4/2023.
//

import Foundation

public struct LogoutResponse: Codable {
	public let result: Bool
	
	enum CodingKeys: String, CodingKey {
		case result = "result"
	}
	
	public init(result: Bool) {
		self.result = result
	}
}
