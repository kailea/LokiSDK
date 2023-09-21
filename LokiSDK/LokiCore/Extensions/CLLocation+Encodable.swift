//
//  CLLocation+Encodable.swift
//  LokiSampleApp
//
//  Created by Amandeep Kaile on 18/4/2023.
//

import CoreLocation

extension CLLocation: Encodable {
	public enum CodingKeys: String, CodingKey {
		case latitude, longitude, altitude, horizontalAccuracy, verticalAccuracy, speed, course, timestamp, speedAccuracy, courseAccuracy, sourceInformation
	}
	
	public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(coordinate.latitude, forKey: .latitude)
		try container.encode(coordinate.longitude, forKey: .longitude)
		try container.encode(altitude, forKey: .altitude)
		try container.encode(horizontalAccuracy, forKey: .horizontalAccuracy)
		try container.encode(verticalAccuracy, forKey: .verticalAccuracy)
		try container.encode(speed, forKey: .speed)
		try container.encode(course, forKey: .course)
		try container.encode(timestamp, forKey: .timestamp)
		try container.encode(speedAccuracy, forKey: .speedAccuracy)
		try container.encode(courseAccuracy, forKey: .courseAccuracy)
		try container.encode(sourceInformation, forKey: .sourceInformation)
	}
}

public struct LocationWrapper: Decodable {
	var location: CLLocation
	
	init(location: CLLocation) {
		self.location = location
	}
	
	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CLLocation.CodingKeys.self)
		
		let latitude = try container.decode(CLLocationDegrees.self, forKey: .latitude)
		let longitude = try container.decode(CLLocationDegrees.self, forKey: .longitude)
		let altitude = try container.decode(CLLocationDistance.self, forKey: .altitude)
		let horizontalAccuracy = try container.decode(CLLocationAccuracy.self, forKey: .horizontalAccuracy)
		let verticalAccuracy = try container.decode(CLLocationAccuracy.self, forKey: .verticalAccuracy)
		let speed = try container.decode(CLLocationSpeed.self, forKey: .speed)
		let course = try container.decode(CLLocationDirection.self, forKey: .course)
		let timestamp = try container.decode(Date.self, forKey: .timestamp)
		let courseAccuracy = try container.decode(CLLocationDirectionAccuracy.self, forKey: .courseAccuracy)
		let speedAccuracy = try container.decode(CLLocationSpeedAccuracy.self, forKey: .speedAccuracy)
		let sourceInfoWrapper = try? container.decode(CLLocationSourceInformationWrapper.self, forKey: .sourceInformation)
			
		if let sourceInfoWrapper = sourceInfoWrapper {
			let location = CLLocation(coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
								  altitude: altitude,
								  horizontalAccuracy: horizontalAccuracy,
								  verticalAccuracy: verticalAccuracy,
								  course: course,
								  courseAccuracy: courseAccuracy,
								  speed: speed,
								  speedAccuracy: speedAccuracy,
								  timestamp: timestamp,
								  sourceInfo: sourceInfoWrapper.sourceInfo)
			self.init(location: location)
		} else {
			let location = CLLocation(coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
									  altitude: altitude,
									  horizontalAccuracy: horizontalAccuracy,
									  verticalAccuracy: verticalAccuracy,
									  course: course,
									  courseAccuracy: courseAccuracy,
									  speed: speed,
									  speedAccuracy: speedAccuracy,
									  timestamp: timestamp)
			self.init(location: location)
		}
	}
}

@available(iOS 15.0, *)
extension CLLocationSourceInformation: Encodable {
	
	enum CodingKeys: String, CodingKey {
		case isSimulatedBySoftware, isProducedByAccessory
	}
	
	public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(isSimulatedBySoftware, forKey: .isSimulatedBySoftware)
		try container.encode(isProducedByAccessory, forKey: .isProducedByAccessory)
	}
}

@available(iOS 15.0, *)
public struct CLLocationSourceInformationWrapper: Decodable {
	var sourceInfo: CLLocationSourceInformation
	
	init(sourceInfo: CLLocationSourceInformation) {
		self.sourceInfo = sourceInfo
	}
	
	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CLLocationSourceInformation.CodingKeys.self)
		
		let isSimulatedBySoftware = try container.decode(Bool.self, forKey: .isSimulatedBySoftware)
		let isProducedByAccessory = try container.decode(Bool.self, forKey: .isProducedByAccessory)
		
		let sourceInfo = CLLocationSourceInformation(softwareSimulationState: isSimulatedBySoftware, andExternalAccessoryState: isProducedByAccessory)
		
		self.init(sourceInfo: sourceInfo)
	}
}
