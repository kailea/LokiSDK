//
//  LokiLocationManager.swift
//  Loki
//
//  Created by Amandeep Kaile on 12/4/2023.
//

import Foundation
import CoreLocation
import UIKit
import OSLog

public class LokiLocationManager : NSObject, LokiLocationManagerInterface {
	public var currentLocation: CLLocation
	private let locationManager: CLLocationManager
	public var foregroundLocationUpdateDistanceInMeters: Int = 0
	public var backgroundLocationUpdateDistanceInMeters: Int = 25
	private let geofenceCount: Int = 5
	public var isUpdatingLocation = false
	
	fileprivate var geofenceRadius: Double {
		let theta = Double.pi / Double(self.geofenceCount)
		let r = Double(backgroundLocationUpdateDistanceInMeters) * sin(theta) / (1 - sin(theta))
		return r
	}
	fileprivate var appMode: AppMode = .terminated
	fileprivate var regionCache: RegionLocationCacheable
	private let geofenceIdentifierPrefix: String = String("loki_geofence_\(Bundle.main.appName)")
	private var dc = LocationDataController(dbName: "LocationData")
	
	public override init() {
		currentLocation = CLLocation(latitude: kCLLocationCoordinate2DInvalid.latitude, longitude: kCLLocationCoordinate2DInvalid.longitude)
		regionCache = RegionLocationCache(defaults: UserDefaults.standard)
		locationManager = CLLocationManager()
		super.init()
		locationManager.allowsBackgroundLocationUpdates = true
		let state = UIApplication.shared.applicationState
		if state == .active {
			locationManager.desiredAccuracy = kCLLocationAccuracyBest
		} else {
			locationManager.distanceFilter = CLLocationDistance(self.backgroundLocationUpdateDistanceInMeters)
			locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
		}
		locationManager.pausesLocationUpdatesAutomatically = false
		locationManager.delegate = self
	}
	
	public func startTracking() {
		NotificationCenter.default.addObserver(self, selector: #selector(willResignActive), name: UIScene.willDeactivateNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(willBecomeActive), name: UIScene.didActivateNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(willResignActive), name: UIApplication.willTerminateNotification, object: nil)
		if locationManager.authorizationStatus != .authorizedAlways {
			locationManager.requestAlwaysAuthorization()
		}
		if CLLocationManager.headingAvailable() {
			locationManager.startUpdatingHeading()
		}
		DispatchQueue.main.async {
			let state = UIApplication.shared.applicationState
			if state == .active {
				self.locationManager.startUpdatingLocation()
			}
		}
		if CLLocationManager.significantLocationChangeMonitoringAvailable() {
			locationManager.startMonitoringSignificantLocationChanges()
		}
	}
	
	public func stopTracking() {
		NotificationCenter.default.removeObserver(self)
		currentLocation = CLLocation(latitude: kCLLocationCoordinate2DInvalid.latitude, longitude: kCLLocationCoordinate2DInvalid.longitude)
		locationManager.stopUpdatingLocation()
		locationManager.stopMonitoringSignificantLocationChanges()
		if let regions = Array(locationManager.monitoredRegions) as? [CLCircularRegion] {
			regionCache.clearRegionCoordinates(regions: regions)
		}
		clearRegions()
	}
	
	public func updateTrackingConfig(foregroundLocationUpdateDistanceInMeters: Int, backgroundLocationUpdateDistanceInMeters: Int) {
		self.foregroundLocationUpdateDistanceInMeters = foregroundLocationUpdateDistanceInMeters
		self.backgroundLocationUpdateDistanceInMeters = backgroundLocationUpdateDistanceInMeters
		DispatchQueue.main.async {
			let state = UIApplication.shared.applicationState
			if state == .active {
				self.locationManager.distanceFilter = foregroundLocationUpdateDistanceInMeters == 0 ? kCLDistanceFilterNone : CLLocationDistance(foregroundLocationUpdateDistanceInMeters)
			} else {
				self.locationManager.distanceFilter = CLLocationDistance(backgroundLocationUpdateDistanceInMeters)
			}
		}
	}
	
	deinit {
		NotificationCenter.default.removeObserver(self)
	}
	
	@objc func willResignActive(_ notification: Notification) {
		if isUpdatingLocation {
			isUpdatingLocation = false
			let currentLocationCoord = currentLocation.coordinate
			self.startMonitoring(for: currentLocationCoord)
			locationManager.distanceFilter = CLLocationDistance(self.backgroundLocationUpdateDistanceInMeters)
			locationManager.stopUpdatingLocation()
			appMode = .background
		}
	}
	
	@objc func willBecomeActive(_ notification: Notification) {
		isUpdatingLocation = true
		locationManager.distanceFilter = foregroundLocationUpdateDistanceInMeters == 0 ? kCLDistanceFilterNone : CLLocationDistance(foregroundLocationUpdateDistanceInMeters)
		self.clearRegions()
		locationManager.startUpdatingLocation()
		appMode = .foreground
	}
	
	fileprivate func startMonitoring(for coordinate: CLLocationCoordinate2D) {
		clearRegions()
		Task {
			await Loki.log(message: String("Creating geofence at : \(coordinate.latitude), \(coordinate.longitude)"), logType: .info)
		}
		print("Coordinate: \(coordinate)")
		let regionRadius = self.geofenceRadius
		let regionCenters = coordinate.regionCenters(desiredRadius: Double(self.backgroundLocationUpdateDistanceInMeters), individualRadius: regionRadius, totalRegions: self.geofenceCount)
		var regions:[CLCircularRegion] = []
		for (index, center) in regionCenters.enumerated() {
			let identifier = "\(geofenceIdentifierPrefix)_\(index)"
			let region = CLCircularRegion(center: center, radius: regionRadius + 2, identifier: identifier)
			region.notifyOnEntry = true
			region.notifyOnExit = false
			locationManager.startMonitoring(for: region)
			regions.append(region)
		}
		let identifier = "\(geofenceIdentifierPrefix)_main"
		let region = CLCircularRegion(center: coordinate, radius: CLLocationDistance(backgroundLocationUpdateDistanceInMeters), identifier: identifier)
		region.notifyOnExit = true
		region.notifyOnEntry = false
		locationManager.startMonitoring(for: region)
		regions.append(region)
		regionCache.saveRegionsCoordinates(regions: regions)
	}
	
	
	fileprivate func clearRegions() {
		locationManager.monitoredRegions.forEach { region in
			locationManager.stopMonitoring(for: region)
		}
	}
}

extension LokiLocationManager: CLLocationManagerDelegate {
	public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		guard let location = locations.last, location.isValid else {
			return
		}
		currentLocation = location
		let locationInfo = LocationInfo(location: location, appMode: appMode)
		dc.addLocation(locationInfo: locationInfo)
		NotificationCenter.default.post(name: .locationUpdate, object: locationInfo)
		self.startMonitoring(for: currentLocation.coordinate)
	}
	
	public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
		// Handle failure to get a user’s location
	}
	
	public func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
		Task {
			await Loki.log(message: String("Entering geofence"), logType: .info)
		}
		if appMode != .foreground {
			manager.requestLocation()
		}
	}
	
	public func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
		Task {
			await Loki.log(message: String("Exiting geofence"), logType: .info)
		}
		if appMode != .foreground {
			manager.requestLocation()
		}
	}
	
	public func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
		os_log("Loki: Monotoring failed for region \(region?.identifier ?? "") - \(error.localizedDescription)")
	}
}
