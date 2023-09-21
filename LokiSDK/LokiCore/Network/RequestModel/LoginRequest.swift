//
//  LoginRequest.swift
//  Loki
//
//  Created by Amandeep Kaile on 12/4/2023.
//

import Foundation

// MARK: - LoginRequest
public struct LoginRequest: Codable {
	public let device: DeviceInfo
	
	enum CodingKeys: String, CodingKey {
		case device = "device"
	}
	
	public init(deviceId: String) {
		self.device = DeviceInfo(id: deviceId)
	}
}
