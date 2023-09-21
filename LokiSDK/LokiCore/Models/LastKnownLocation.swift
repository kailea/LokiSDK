//
//  LastKnownLocation.swift
//  Loki
//
//  Created by Amandeep Kaile on 12/4/2023.
//

import Foundation
import CoreLocation

public struct LastKnownLocation: Codable {
	public let id: String?
	public let userID: String
	public let locationID: String?
	public let coordinates: Coordinates?
	public let recordedAtUTC: Date?
	public let altitude: Double?
	public let verticalAccuracy: Double?
	public let horizontalAccuracy: Double?
	public let sdkVersion: String?
	public let speed: Double?
	public let battery: Battery?
	public let heading: Double?
	public let activity: String?
	public let createdDateUTC: Date?
	public let isSimulated: Bool
	public let appMode: AppMode
	
	enum CodingKeys: String, CodingKey {
		case id = "id"
		case userID = "userId"
		case locationID = "locationId"
		case coordinates = "coordinates"
		case recordedAtUTC = "recordedAtUtc"
		case altitude = "altitude"
		case verticalAccuracy = "verticalAccuracy"
		case horizontalAccuracy = "horizontalAccuracy"
		case sdkVersion = "sdkVersion"
		case speed = "speedInMetersPerSecond"
		case battery = "battery"
		case heading = "headingDirection"
		case activity = "activity"
		case createdDateUTC = "createdDateUtc"
		case isSimulated = "isSimulated"
		case appMode = "appMode"
	}
	
	public init(id: String?, userID: String, locationID: String?, coordinates: Coordinates?, recordedAtUTC: Date?, altitude: Double?, verticalAccuracy: Double?, horizontalAccuracy: Double?, sdkVersion: String?, speed: Double?, battery: Battery?, heading: Double?, activity: String?, createdDateUTC: Date?, isSimulated: Bool, appMode: AppMode) {
		self.id = id
		self.userID = userID
		self.locationID = locationID
		self.coordinates = coordinates
		self.recordedAtUTC = recordedAtUTC
		self.altitude = altitude
		self.verticalAccuracy = verticalAccuracy
		self.horizontalAccuracy = horizontalAccuracy
		self.sdkVersion = sdkVersion
		self.speed = speed
		self.battery = battery
		self.heading = heading
		self.activity = activity
		self.createdDateUTC = createdDateUTC
		self.isSimulated = isSimulated
		self.appMode = appMode
	}
	
	public func location() -> LokiLocation {
		if let coord = self.coordinates, let lat = coord.latitude, let lon = coord.longitude {
			let location = CLLocation(coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon), altitude: altitude ?? 0, horizontalAccuracy: horizontalAccuracy ?? 0, verticalAccuracy: verticalAccuracy ?? 0, course: heading ?? 0, speed: speed ?? 0, timestamp: recordedAtUTC ?? Date.now)
			return LokiLocation(lokiId: userID, location: location, isSimulated: isSimulated, appMode: appMode)
		} else {
			return LokiLocation(lokiId: userID, location: CLLocation(latitude: kCLLocationCoordinate2DInvalid.latitude, longitude: kCLLocationCoordinate2DInvalid.longitude), isSimulated: isSimulated, appMode: appMode)
		}
	}
}
