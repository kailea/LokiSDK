//
//  CLLocation+Loki.swift
//  Loki
//
//  Created by Amandeep Kaile on 12/4/2023.
//

import CoreLocation

extension CLLocation {
	var isValid : Bool {
		let lat = coordinate.latitude
		let lon = coordinate.longitude
		
		let latitudeValid = lat != 0.0 && lat > -90.0 && lat < 90.0
		let longitudeValid = lon != 0.0 && lon > -180.0 && lon < 180.0
		let horizontalAccuracyValid = horizontalAccuracy > 0
		return latitudeValid && longitudeValid && horizontalAccuracyValid
	}
	
	func speedKmh() -> String? {
		if Date.now.timeIntervalSince(timestamp) <= 60 {
			let currentSpeed = Int(speed*3.6)
			return currentSpeed > 0 ? String("\(currentSpeed)kph") : nil
		} else {
			return nil
		}
	}
}
