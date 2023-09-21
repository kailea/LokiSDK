//
//  SubscribeResponse.swift
//  Loki
//
//  Created by Amandeep Kaile on 12/4/2023.
//

import Foundation

public struct SubscribeResponse: Codable {
	public let failedSubscriptions: [String]?
	public let publishers: [Publisher]?
	
	enum CodingKeys: String, CodingKey {
		case failedSubscriptions = "failedSubscriptions"
		case publishers = "publishers"
	}
	
	public init(failedSubscriptions: [String]?, publishers: [Publisher]?) {
		self.failedSubscriptions = failedSubscriptions
		self.publishers = publishers
	}
}
