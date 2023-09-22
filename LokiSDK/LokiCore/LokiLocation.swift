//
//  LokiLocation.swift
//  Loki
//
//  Created by Amandeep Kaile on 12/4/2023.
//

import CoreLocation

public struct LokiLocation {
	public let lokiId: String
	public let location: CLLocation
	public let isSimulated: Bool
	public let appMode: AppMode
}
