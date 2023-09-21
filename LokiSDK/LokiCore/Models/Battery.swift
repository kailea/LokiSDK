//
//  Battery.swift
//  Loki
//
//  Created by Amandeep Kaile on 12/4/2023.
//

import Foundation

public struct Battery: Codable {
	public let isCharging: Bool?
	public let remainingCharge: Int?
	
	enum CodingKeys: String, CodingKey {
		case isCharging = "isCharging"
		case remainingCharge = "remainingCharge"
	}
	
	public init(isCharging: Bool?, remainingCharge: Int?) {
		self.isCharging = isCharging
		self.remainingCharge = remainingCharge
	}
}
