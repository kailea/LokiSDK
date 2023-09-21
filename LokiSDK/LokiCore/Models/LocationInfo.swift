//
//  LocationInfo.swift
//  LokiSampleApp
//
//  Created by Amandeep Kaile on 18/4/2023.
//

import CoreLocation

public enum SendStatus : Int16, Codable {
	case unknown = 0
	case mqttSend = 1
	case httpSend = 2
	case mqttFailed = 3
	case httpFailed = 4
	case httpSendEx = 5
	case httpFailedEx = 6
	case ignored = 7
	
	func description() -> String {
		switch self {
			case .mqttSend:
				return "MQTT Success"
			case .httpSend:
				return "HTTP Success"
			case .mqttFailed:
				return "MQTT Failed"
			case .httpFailed:
				return "HTTP Failed"
			case .httpSendEx:
				return "HTTP Success"
			case .httpFailedEx:
				return "HTTP Failed"
			case .unknown:
				return "Unknown"
			default:
				return "Local update"
		}
	}
	
	func canSendLocationOnConnect() -> Bool {
		switch self {
			case .mqttSend:
				return false
			case .httpSend:
				return false
			case .httpSendEx:
				return false
			default:
				return true
		}
	}
}

public struct LocationInfo: Codable {
	public let locationId: String
	public let location: CLLocation
	public let appMode: AppMode
	
	enum CodingKeys: String, CodingKey {
		case locationId = "locationId"
		case location = "location"
		case appMode = "appMode"
	}
	
	init(location: CLLocation, appMode: AppMode) {
		self.locationId = String("LOC-\(UUID())")
		self.location = location
		self.appMode = appMode
	}
	
	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.locationId = try container.decode(String.self, forKey: .locationId)
		self.location = try container.decode(LocationWrapper.self, forKey: .location).location
		self.appMode = try container.decode(AppMode.self, forKey: .appMode)
	}
}
