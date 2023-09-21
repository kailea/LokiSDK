//
//  LokiDevice.swift
//  Loki
//
//  Created by Amandeep Kaile on 12/4/2023.
//

import Foundation

public struct LokiDevice: Codable {
	public let id: String
	public var symmetricKey: String
	
	enum CodingKeys: String, CodingKey {
		case id = "id"
		case symmetricKey = "symmetricKey"
	}
	
	public init(id: String, symmetricKey: String) {
		self.id = id
		self.symmetricKey = symmetricKey
	}
}
