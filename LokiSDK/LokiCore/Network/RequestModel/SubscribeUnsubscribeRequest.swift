//
//  SubscribeUnsubscribeRequest.swift
//  Loki
//
//  Created by Amandeep Kaile on 12/4/2023.
//

import Foundation

public struct SubscribeUnsubscribeRequest: Codable {
	public let publishers: [String]?
	
	enum CodingKeys: String, CodingKey {
		case publishers = "publishers"
	}
	
	public init(publishers: [String]?) {
		self.publishers = publishers
	}
}
