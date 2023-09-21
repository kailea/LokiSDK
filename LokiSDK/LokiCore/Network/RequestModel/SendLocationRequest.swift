//
//  SendLocationRequest.swift
//  Loki
//
//  Created by Amandeep Kaile on 12/4/2023.
//

import Foundation

public enum AppMode : Int16, Codable {
	case foreground = 0
	case background = 1
	case terminated = 2
}

public struct SendLocationRequest: Codable {
	public let userId: String
	public let deviceId: String
	public let coordinates: Coordinates?
	public let recordedAtUTC: Date?
	public let altitude: Double?
	public let verticalAccuracy: Double?
	public let horizontalAccuracy: Double?
	public let sdkVersion: String?
	public let speed: Double?
	public let battery: Battery?
	public let headingDirection: Double?
	public let activity: String?
	public let isSimulated: Bool
	public let appMode: AppMode
	
	enum CodingKeys: String, CodingKey {
		case userId = "userId"
		case deviceId = "deviceId"
		case coordinates = "coordinates"
		case recordedAtUTC = "recordedAtUtc"
		case altitude = "altitude"
		case verticalAccuracy = "verticalAccuracy"
		case horizontalAccuracy = "horizontalAccuracy"
		case sdkVersion = "sdkVersion"
		case speed = "speedInMetersPerSecond"
		case battery = "battery"
		case headingDirection = "headingDirection"
		case activity = "activity"
		case isSimulated = "isSimulated"
		case appMode = "appMode"
	}
	
	public init(userId: String, deviceId: String, coordinates: Coordinates?, recordedAtUTC: Date?, altitude: Double?, verticalAccuracy: Double?, horizontalAccuracy: Double?, sdkVersion: String?, speed: Double?, battery: Battery?, headingDirection: Double?, activity: String?, isSimulated: Bool, appMode: AppMode) {
		self.userId = userId
		self.deviceId = deviceId
		self.coordinates = coordinates
		self.recordedAtUTC = recordedAtUTC
		self.altitude = altitude
		self.verticalAccuracy = verticalAccuracy
		self.horizontalAccuracy = horizontalAccuracy
		self.sdkVersion = sdkVersion
		self.speed = speed
		self.battery = battery
		self.headingDirection = headingDirection
		self.activity = activity
		self.isSimulated = isSimulated
		self.appMode = appMode
	}
}
