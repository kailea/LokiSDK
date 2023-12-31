//
//  RegionLocationCacheable.swift
//  LokiSampleApp
//
//  Created by Amandeep Kaile on 17/4/2023.
//

import Foundation

import CoreLocation

protocol RegionLocationCacheable {
	func saveRegionsCoordinates(regions:[CLCircularRegion])
	func clearRegionCoordinates(regions:[CLCircularRegion])
	func coordinates(for region: CLRegion) -> CLLocationCoordinate2D
}


struct RegionLocationCache: RegionLocationCacheable {
	
	private let defaults: UserDefaults
	
	init(defaults: UserDefaults) {
		self.defaults = defaults
	}
	
	func saveRegionsCoordinates(regions:[CLCircularRegion]) {
		regions.forEach { region in
			defaults.set(region.center.latitude, forKey: String(format: CacheFormat.latFormat, region.identifier))
			defaults.set(region.center.longitude, forKey: String(format: CacheFormat.longFormat, region.identifier))
			defaults.set(region.radius, forKey: String(format: CacheFormat.radiusFormat, region.identifier))
			defaults.synchronize()
		}
	}
	
	func clearRegionCoordinates(regions:[CLCircularRegion]) {
		regions.forEach { region in
			defaults.removeObject(forKey: String(format: CacheFormat.latFormat, region.identifier))
			defaults.removeObject(forKey: String(format: CacheFormat.longFormat, region.identifier))
			defaults.removeObject(forKey: String(format: CacheFormat.radiusFormat, region.identifier))
			defaults.synchronize()
		}
	}
	
	func coordinates(for region: CLRegion) -> CLLocationCoordinate2D {
		let lat  = defaults.float(forKey: String(format: CacheFormat.latFormat, region.identifier))
		let long = defaults.float(forKey: String(format: CacheFormat.longFormat, region.identifier))
		return CLLocationCoordinate2D(latitude: CLLocationDegrees(lat), longitude: CLLocationDegrees(long))
	}
	
	private struct CacheFormat {
		static let latFormat = "loki.region.coordinates.%@.lat"
		static let longFormat = "loki.region.coordinates.%@.long"
		static let radiusFormat = "loki.region.%@.radius"
	}
}
