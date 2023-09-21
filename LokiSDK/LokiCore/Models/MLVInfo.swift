//
//  MLVInfo.swift
//  Lifestream
//
//  Created by Amandeep Kaile on 18/9/2023.
//  Copyright © 2023 Guardian Pty Ltd. All rights reserved.
//

import Foundation

public struct MlvInfo: Codable, Sendable {
	public let isOn: Bool
	public let sendLocationImmediately: Bool
	public let correlationID: String?
	public let timeStamp: Date
	
	enum CodingKeys: String, CodingKey {
		case isOn = "isOn"
		case sendLocationImmediately = "sendLocationImmediately"
		case correlationID = "correlationId"
		case timeStamp = "timeStamp"
	}
	
	public init(isOn: Bool, sendLocationImmediately: Bool, correlationID: String?, timeStamp: Date) {
		self.isOn = isOn
		self.sendLocationImmediately = sendLocationImmediately
		self.correlationID = correlationID
		self.timeStamp = timeStamp
	}
}
