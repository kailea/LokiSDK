//
//  LokiLocation.swift
//  Loki
//
//  Created by Amandeep Kaile on 12/4/2023.
//

import CoreLocation

public struct LokiLocation {
	let lokiId: String
	let location: CLLocation
	let isSimulated: Bool
	let appMode: AppMode
}
