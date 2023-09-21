//
//  Publisher.swift
//  Loki
//
//  Created by Amandeep Kaile on 12/4/2023.
//

import Foundation

public struct Publisher: Codable {
	public let userID: String?
	public let lastKnownLocation: LastKnownLocation?
	
	enum CodingKeys: String, CodingKey {
		case userID = "userId"
		case lastKnownLocation = "lastKnownLocation"
	}
	
	public init(userID: String?, lastKnownLocation: LastKnownLocation?) {
		self.userID = userID
		self.lastKnownLocation = lastKnownLocation
	}
}
