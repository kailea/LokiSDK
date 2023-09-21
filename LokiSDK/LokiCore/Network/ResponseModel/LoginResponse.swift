//
//  LoginResponse.swift
//  Loki
//
//  Created by Amandeep Kaile on 12/4/2023.
//

import Foundation

public struct LoginResponse: Codable {
	public let userID: String
	public let device: LokiDevice
	public let lokiConfiguration: LokiConfiguration
	
	enum CodingKeys: String, CodingKey {
		case userID = "userId"
		case device = "device"
		case lokiConfiguration = "sdkConfigurations"
	}
	
	public init(userID: String, device: LokiDevice, lokiConfiguration: LokiConfiguration) {
		self.userID = userID
		self.device = device
		self.lokiConfiguration = lokiConfiguration
	}
}
