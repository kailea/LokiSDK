//
//  Coordinates.swift
//  Loki
//
//  Created by Amandeep Kaile on 12/4/2023.
//

import Foundation

public struct Coordinates: Codable {
	public let latitude: Double?
	public let longitude: Double?
	
	enum CodingKeys: String, CodingKey {
		case latitude = "latitude"
		case longitude = "longitude"
	}
	
	public init(latitude: Double?, longitude: Double?) {
		self.latitude = latitude
		self.longitude = longitude
	}
}
