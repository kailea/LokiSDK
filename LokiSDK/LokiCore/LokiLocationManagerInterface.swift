//
//  LokiLocationManagerInterface.swift
//  LokiSampleApp
//
//  Created by Amandeep Kaile on 18/4/2023.
//

import Foundation

protocol LokiLocationManagerInterface {
	func startTracking()
	func stopTracking()
	func updateTrackingConfig(foregroundLocationUpdateDistanceInMeters: Int, backgroundLocationUpdateDistanceInMeters: Int)
}
