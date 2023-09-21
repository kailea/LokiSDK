//
//  CLLocationCoordinate2D+RegionCenters.swift
//  LokiSampleApp
//
//  Created by Amandeep Kaile on 23/4/2023.
//

import CoreLocation

extension CLLocationCoordinate2D {
	
	func regionCenters(desiredRadius: Double, individualRadius: Double, totalRegions: Int) -> [CLLocationCoordinate2D] {
		var centers: [CLLocationCoordinate2D] = []
		
		for curRegion in 0..<(totalRegions * 2) {
			let angle = 2 * Double.pi / Double(totalRegions * 2) * Double(curRegion)
			let newCoordinate = self.location(for: angle, and: desiredRadius + individualRadius)
			centers.append(newCoordinate)
		}
		return centers
	}
}

