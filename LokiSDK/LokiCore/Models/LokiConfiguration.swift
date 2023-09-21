//
//  LokiConfiguration.swift
//  Loki
//
//  Created by Amandeep Kaile on 12/4/2023.
//

import Foundation

public struct LokiConfiguration: Codable {
	public let iotHubHost: String
	public let locationUpdateIntervalInSeconds: Int
	public let foregroundLocationUpdateDistanceInMeters: Int
	public let backgroundLocationUpdateDistanceInMeters: Int
	public let desiredHorizontalAccuracyInMeters: Int
	
	enum CodingKeys: String, CodingKey {
		case iotHubHost = "iotHubHost"
		case locationUpdateIntervalInSeconds = "locationCollectionIntervalInSeconds"
		case foregroundLocationUpdateDistanceInMeters = "foregroundLocationUpdateDistanceInMeters"
		case backgroundLocationUpdateDistanceInMeters = "backgroundLocationUpdateDistanceInMeters"
		case desiredHorizontalAccuracyInMeters = "desiredHorizontalAccuracyInMeters"
	}
	
	public init(
		iotHubHost: String,
		locationCollectionIntervalInSeconds: Int?,
		foregroundLocationUpdateDistanceInMeters: Int?,
		backgroundLocationUpdateDistanceInMeters: Int?,
		desiredHorizontalAccuracyInMeters: Int?) {
			
		self.iotHubHost = iotHubHost
		self.locationUpdateIntervalInSeconds = locationCollectionIntervalInSeconds ?? 30
		self.foregroundLocationUpdateDistanceInMeters = foregroundLocationUpdateDistanceInMeters ?? 25
		self.backgroundLocationUpdateDistanceInMeters = backgroundLocationUpdateDistanceInMeters ?? 50
		self.desiredHorizontalAccuracyInMeters = desiredHorizontalAccuracyInMeters ?? 10
	}
}
