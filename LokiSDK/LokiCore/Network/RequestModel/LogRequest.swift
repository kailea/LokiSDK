//
//  LogRequest.swift
//  LokiSampleApp
//
//  Created by Amandeep Kaile on 26/4/2023.
//

import Foundation

public enum LogType : Int16, Codable {
	case info = 0
	case warning = 1
	case error = 2
}

public struct LogRequest : Codable{
	public let userId: String
	public let deviceId: String
	public let message: String
	public let logType: LogType
	public let battery: Battery?
	public let sdkVersion: String?
	
	enum CodingKeys: String, CodingKey {
		case userId = "userId"
		case deviceId = "deviceId"
		case message = "message"
		case logType = "logType"
		case battery = "battery"
		case sdkVersion = "sdkVersion"
	}
	
	public init(userId: String, deviceId: String, message: String, logType: LogType, battery: Battery?, sdkVersion: String?) {
		self.userId = userId
		self.deviceId = deviceId
		self.message = message
		self.logType = logType
		self.battery = battery
		self.sdkVersion = sdkVersion
	}
}
