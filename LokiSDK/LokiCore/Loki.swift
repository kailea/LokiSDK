//
//  Loki.swift
//  Loki
//
//  Created by Amandeep Kaile on 12/4/2023.
//

import Foundation
import CoreLocation
import DeviceKit
import UIKit
import AzureIoTHubClient
import OSLog
import Swinject

public protocol LokiDelegate : AnyObject{
	func didUpdateLocation(location: LokiLocation)
	func didUpdateUserLocation(location: LokiLocation)
}

extension LokiDelegate {
	func didUpdateLocation(location: LokiLocation) {}
	func didUpdateUserLocation(location: LokiLocation) {}
}

public class Loki: NSObject {
	private static let sharedInstance = Loki()
	private weak var delegate: LokiDelegate?
	private var currentLocationInfo: LocationInfo?
	private var locationManager: LokiLocationManagerInterface
	private let publishableKeyStorageKey = "publisableKey"
	private let lokiIdKey = "lokiIdKey"
	private let locationSendTimeKey = "locationSendTimeKey"
	private let lokiConfigurationKey = "lokiConfigurationKey"
	private let lokiDeviceKey = "lokiDeviceKey"
	private let currentLocationKey = "currentLocationKey"
	private var locationSendTime: Date? {
		didSet {
			let defaults = UserDefaults.standard
			defaults.set(locationSendTime, forKey: locationSendTimeKey)
		}
	}
	
	private var publishableKey: String?
	private var lokiId: String?
	private var appId: String
	private var lokiDevice: LokiDevice
	private var lokiConfiguration: LokiConfiguration? = nil {
		didSet {
			guard let configuration = lokiConfiguration else {
				return
			}
			locationManager.updateTrackingConfig(foregroundLocationUpdateDistanceInMeters: configuration.foregroundLocationUpdateDistanceInMeters, backgroundLocationUpdateDistanceInMeters: configuration.backgroundLocationUpdateDistanceInMeters)
		}
	}
	private var apiManager: LokiApiManagerInterface! = Assembler.shared.resolver.resolve(LokiApiManagerInterface.self)
	private var jsonDecoder: LokiDataDecoder! = Assembler.shared.resolver.resolve(LokiDataDecoder.self)
	
	private let iotProtocol: IOTHUB_CLIENT_TRANSPORT_PROVIDER = MQTT_WebSocket_Protocol
	private var iotHubClientHandle: IOTHUB_CLIENT_LL_HANDLE!
	private var isConnected: Bool = false
	private var dc = LocationDataController(dbName: "LocationData")
	
	private let connectionStatus: IOTHUB_CLIENT_CONNECTION_STATUS_CALLBACK = { status, reason , userContext in
		print(status)
		var mySelf: Loki = Unmanaged<Loki>.fromOpaque(userContext!).takeUnretainedValue()
		if status == IOTHUB_CLIENT_CONNECTION_AUTHENTICATED {
			mySelf.isConnected = true
			guard let currentLocationInfo = mySelf.currentLocationInfo, currentLocationInfo.location.isValid == true, let sendStatus = mySelf.dc.getSendStatus(locationId: currentLocationInfo.locationId) else {
				return
			}
			if sendStatus.canSendLocationOnConnect() {
				mySelf.sendCurrentLocation()
			}
		} else {
			mySelf.isConnected = false
			/*if mySelf.isConnected {
				Task {
					await sharedInstance.connect(symmetricKey: sharedInstance.lokiDevice.symmetricKey)
				}
			}*/
		}
	}
	
	let deviceMethodCallBack: IOTHUB_CLIENT_DEVICE_METHOD_CALLBACK_ASYNC = { methodName, payload, payloadSize, response, responseSize, userContext  in
		guard let methodName = methodName else {
			return 400
		}
		let internalMethodName = String(cString: UnsafePointer<CChar>(methodName))
		let data = Data(Data(bytes: payload!, count: payloadSize))
		var mySelf: Loki = Unmanaged<Loki>.fromOpaque(userContext!).takeUnretainedValue()
		if internalMethodName == "setLocationBeingViewed" {
			mySelf.updateMLV(mlvData: data)
		} else {
			mySelf.updateUserLocation(locationData: data)
		}
		var end: String? = nil
		var newInterval = 0
		guard let responseString = "{ \"Response\": \"All Good.\" }".toUnsafeMutablePointer() else {
			return 400
		}
		response?.pointee = responseString.0
		var value = responseString.1
		responseSize?.pointee = value
		return 200
	}
	
	let mySendConfirmationCallback: IOTHUB_CLIENT_EVENT_CONFIRMATION_CALLBACK = { result, userContext in
		
		
		if (result == IOTHUB_CLIENT_CONFIRMATION_OK) {
			os_log("Loki: Message send")
		}
		else {
			os_log("Loki: Message unable to send")
		}
	}
	
	private override init() {
		locationManager = Assembler.shared.resolver.resolve(LokiLocationManagerInterface.self)!
		let defaults = UserDefaults.standard
		if let lokiDevice = try? defaults.getObject(forKey: lokiDeviceKey, castTo: LokiDevice.self) {
			self.lokiDevice = lokiDevice
		} else {
			if let deviceId = UIDevice.current.identifierForVendor?.uuidString {
				self.lokiDevice = LokiDevice(id: "DVC-\(deviceId)", symmetricKey: "")
			} else {
				self.lokiDevice = LokiDevice(id: "DVC-\(UUID().uuidString)", symmetricKey: "")
			}
			try? defaults.setObject(self.lokiDevice, forKey: lokiDeviceKey)
		}
		appId = Bundle.main.bundleIdentifier!
		dc.removeOldData()
		super.init()
		NotificationCenter.default.addObserver(self, selector: #selector(locationUpdated), name: .locationUpdate, object: nil)
	}
	
	deinit {
		NotificationCenter.default.removeObserver(self)
	}
	
	public static func getDeviceId() -> String {
		return sharedInstance.lokiDevice.id
	}
	
	public static func getLokiId() -> String? {
		return sharedInstance.lokiId
	}
	
	public static func getCurrentLocation() -> CLLocation? {
		if let curLocation = sharedInstance.currentLocationInfo?.location, curLocation.isValid {
			return curLocation
		} else if let curLocation = try? UserDefaults.standard.getObject(forKey: sharedInstance.currentLocationKey, castTo: LocationInfo.self), curLocation.location.isValid {
			return curLocation.location
		}
		return nil
	}
	
	public static func initialize(_ publishableKey: String) {
		sharedInstance.publishableKey = publishableKey
		let defaults = UserDefaults.standard
		if defaults.string(forKey: sharedInstance.publishableKeyStorageKey) == nil {
			defaults.set(publishableKey, forKey: sharedInstance.publishableKeyStorageKey)
		}
		
		if let lokiId = defaults.string(forKey: sharedInstance.lokiIdKey), let device = try? defaults.getObject(forKey: sharedInstance.lokiDeviceKey, castTo: LokiDevice.self), device.symmetricKey.count > 0, let sdkConfiguration = try? defaults.getObject(forKey: sharedInstance.lokiConfigurationKey, castTo: LokiConfiguration.self) {
			sharedInstance.lokiId = lokiId
			sharedInstance.lokiDevice = device
			sharedInstance.lokiConfiguration = sdkConfiguration
			sharedInstance.apiManager.authKey = sharedInstance.getAuthKey()
			if let locationSendTime = defaults.object(forKey: sharedInstance.locationSendTimeKey) as? Date {
				sharedInstance.locationSendTime = locationSendTime
			}
			sharedInstance.locationManager.startTracking()
			Task {
				await sharedInstance.connect(symmetricKey:sharedInstance.lokiDevice.symmetricKey)
			}
		}
	}
	
	public static func setDelegate(_ delegate: LokiDelegate?) {
		sharedInstance.delegate = delegate
		if let lokiId = sharedInstance.lokiId, let locationInfo = sharedInstance.currentLocationInfo {
			delegate?.didUpdateLocation(location: LokiLocation(lokiId: lokiId, location: locationInfo.location, isSimulated: locationInfo.location.sourceInformation?.isSimulatedBySoftware == true, appMode: locationInfo.appMode))
		}
	}
	
	public static func login(locationId: String) async -> Bool{
		guard let _ = sharedInstance.publishableKey else {
			os_log("Loki: Unable to login - No PublishableKey")
			return false
		}
		
		if locationId.trimming(spaces: .leadingAndTrailing).length == 0 {
			os_log("Loki: Unable to login - Invalid location Id")
			return false
		}
		let defaults = UserDefaults.standard
		var loginRequired = true
		if let lokiId = defaults.string(forKey: sharedInstance.lokiIdKey), lokiId == locationId {
			loginRequired = false
			sharedInstance.apiManager.authKey = sharedInstance.getAuthKey()
		} else {
			sharedInstance.apiManager.authKey = sharedInstance.getAuthKey(locationId)
		}
		if let device = try? defaults.getObject(forKey: sharedInstance.lokiDeviceKey, castTo: LokiDevice.self), device.symmetricKey.count > 0 && !loginRequired{
			sharedInstance.locationSendTime = nil
			sharedInstance.locationManager.startTracking()
			return await sharedInstance.connect(symmetricKey: device.symmetricKey)
		} else {
			sharedInstance.lokiId = locationId
			if let symmetricKey = await sharedInstance.loginWithApi(locationId: locationId) {
				sharedInstance.locationSendTime = nil
				sharedInstance.locationManager.startTracking()
				return await sharedInstance.connect(symmetricKey: symmetricKey)
			} else {
				sharedInstance.lokiId = locationId
			}
		}
		return false
	}
	
	public static func logout() async -> Bool {
		NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(showTimerAlert), object: nil)
		sharedInstance.clearLoki()
		if await sharedInstance.logoutFromApi() {
			sharedInstance.apiManager.authKey = nil
			return true
		}
		sharedInstance.apiManager.authKey = nil
		return false
	}
	
	public static func getLastKnownLocation(locationId: String) async -> LokiLocation? {
		do {
			let response = try await sharedInstance.apiManager.getLastKnownLocation(userId: locationId)
			sharedInstance.delegate?.didUpdateUserLocation(location: response.location())
			return response.location()
		} catch {
			return nil
		}
	}
	
	public static func subscribe(subsriberIds: [String]) async -> [LokiLocation]? {
		let subsriberIds = subsriberIds.map{$0.trimmingCharacters(in: .whitespaces)}
		if subsriberIds.count > 0 {
			do {
				let response = try await sharedInstance.apiManager.subscribe(subscribers: subsriberIds)
				if let publishers = response.publishers, publishers.count > 0 {
					var locations = [LokiLocation]()
					for publisher in publishers {
						if let location = publisher.lastKnownLocation {
							let userLocation = location.location()
							locations.append(userLocation)
							sharedInstance.delegate?.didUpdateUserLocation(location: userLocation)
						}
					}
					return locations
				}
				return nil
			} catch {
				return nil
			}
		} else {
			return nil
		}
	}
	
	public static func unSubscribe(subsriberIds: [String]) async -> Bool {
		let subsriberIds = subsriberIds.map{$0.trimmingCharacters(in: .whitespaces)}
		do {
			let response = try await sharedInstance.apiManager.unSubscribe(subscribers: subsriberIds)
			return response
		} catch {
			return false
		}
	}
	
	public static func sendLocation(locationInfo: LocationInfo? = nil) async -> Bool {
		if let currentLocationInfo = locationInfo {
			return await sharedInstance.sendLocation(locationInfo: currentLocationInfo, isRetry: true)
		} else {
			guard let currentLocationInfo = sharedInstance.currentLocationInfo, currentLocationInfo.location.isValid == true else {
				return false
			}
			return await sharedInstance.sendLocation(locationInfo: currentLocationInfo, isRetry: false)
		}
	}
	
	private func sendLocation(locationInfo: LocationInfo, isRetry: Bool) async -> Bool {
		let locationId = locationInfo.locationId
		let currentLocation = locationInfo.location
		let device = DeviceKit.Device.current
		let isCharging = device.batteryState == .charging(100)
		let requestData = SendLocationRequest(
			userId: self.lokiId ?? "",
			deviceId: self.lokiDevice.id,
			coordinates: Coordinates(
				latitude: currentLocation.coordinate.latitude,
				longitude: currentLocation.coordinate.longitude
			),
			recordedAtUTC: currentLocation.timestamp,
			altitude: currentLocation.altitude,
			verticalAccuracy: currentLocation.verticalAccuracy,
			horizontalAccuracy: currentLocation.horizontalAccuracy,
			sdkVersion: "1.0",
			speed: currentLocation.speed,
			battery: Battery(
				isCharging: isCharging,
				remainingCharge: device.batteryLevel
			),
			headingDirection: currentLocation.course,
			activity: "",
			isSimulated: currentLocation.sourceInformation?.isSimulatedBySoftware ?? false,
			appMode: locationInfo.appMode
		)
		do {
			if isRetry {
				self.dc.updateResendTime(locationId: locationId)
			} else {
				self.dc.updateSendTime(locationId: locationId)
			}
			let response = try await self.apiManager.sendLocation(location: requestData)
			self.dc.updateSendStatus(locationId: locationId, status: isRetry ? .httpSendEx : .httpSend)
			return response
		} catch {
			self.dc.updateSendStatus(locationId: locationId, status: isRetry ? .httpFailedEx : .httpFailed, error: error.localizedDescription)
			return false
		}
	}
	
	public static func log(message: String, logType: LogType) async-> Bool {
		let device = DeviceKit.Device.current
		let isCharging = device.batteryState == .charging(100)
		let requestData = LogRequest(userId: sharedInstance.lokiId ?? "",
									 deviceId: sharedInstance.lokiDevice.id,
									 message: message,
									 logType: logType,
									 battery: Battery(
										isCharging: isCharging,
										remainingCharge: device.batteryLevel
									 ),
									 sdkVersion: "1.0")
		do {
			let response = try await sharedInstance.apiManager.log(logMessage: requestData)
			return response
		} catch {
			return false
		}
	}
	
	private func getAuthKey(_ lokiId: String? = nil) -> String? {
		guard let publishableKey = self.publishableKey else {
			return nil
		}
		if let lokiId = lokiId {
			return "publishableKey=\(publishableKey),applicationId=\(appId),lokiId=\(lokiId)".encodeBase64()
		} else {
			if let lokiId = self.lokiId {
				return "publishableKey=\(publishableKey),applicationId=\(appId),lokiId=\(lokiId)".encodeBase64()
			}
		}
		return nil
	}
	
	
	private func loginWithApi(locationId: String) async -> String?{
		do {
			let response = try await apiManager.login(loginDetails: LoginRequest(deviceId: lokiDevice.id))
			lokiDevice = response.device
			lokiConfiguration = response.lokiConfiguration
			lokiId = locationId
			let defaults = UserDefaults.standard
			defaults.set(lokiId, forKey: lokiIdKey)
			try defaults.setObject(lokiDevice, forKey: lokiDeviceKey)
			try defaults.setObject(lokiConfiguration, forKey: lokiConfigurationKey)
			return lokiDevice.symmetricKey
		} catch {
			return nil
		}
	}
	
	private func logoutFromApi() async -> Bool {
		do {
			let resoponse = try await apiManager.logout(deviceId: lokiDevice.id)
			return resoponse
		} catch {
			return false
		}
	}
	
	private func updateUserLocation(locationData: Data) {
		do {
			os_log("Location Receieved: \(String(describing: locationData.prettyJson))")
			let location = try jsonDecoder.decode(LastKnownLocation.self, from: locationData)
			let lokiLocation = location.location()
 			delegate?.didUpdateUserLocation(location: lokiLocation)
		} catch {
			os_log("Loki: \(error.localizedDescription)")
		}
	}
	
	private func updateMLV(mlvData: Data) {
		do {
			os_log("MLV Data: \(String(describing: mlvData.prettyJson))")
			let mlvInfo = try jsonDecoder.decode(MlvInfo.self, from: mlvData)
			print("MLV: \(mlvInfo)")
		} catch {
			os_log("Loki: \(error.localizedDescription)")
		}
	}
	
	private func connect(symmetricKey: String) async -> Bool{
		self.showTimerAlert()
		IoTHub_Init()
		let connectionString = "HostName=\(lokiConfiguration!.iotHubHost);DeviceId=\(lokiDevice.id);SharedAccessKey=\(symmetricKey)"
		iotHubClientHandle = IoTHubDeviceClient_CreateFromConnectionString(connectionString, iotProtocol)
		if iotHubClientHandle == nil {
			return false
		}

		var delay = 100
		IoTHubDeviceClient_SetOption(self.iotHubClientHandle, OPTION_DO_WORK_FREQUENCY_IN_MS, &delay)
		
		// Mangle my self pointer in order to pass it as an UnsafeMutableRawPointer
		let that = UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())
		
		// Set up the message callback
		let _ = IoTHubDeviceClient_SetConnectionStatusCallback(iotHubClientHandle, connectionStatus, that)
		let result = IoTHubDeviceClient_SetDeviceMethodCallback(iotHubClientHandle, deviceMethodCallBack, that)
		
		if (IOTHUB_CLIENT_OK != (result)) {
			os_log("Loki: Failed to establish received message callback")
			return false
		}
		return true
	}
	
	private func clearLoki() {
		self.locationManager.stopTracking()
		let defaults = UserDefaults.standard
		defaults.removeObject(forKey: self.lokiIdKey)
		self.lokiId = nil
		self.locationSendTime = nil
		self.lokiDevice.symmetricKey = ""
		try? defaults.setObject(self.lokiDevice, forKey: self.lokiDeviceKey)
		defaults.removeObject(forKey: self.locationSendTimeKey)
		self.isConnected = false
		// Mangle my self pointer in order to pass it as an UnsafeMutableRawPointer
		let that = UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())
		
		// Set up the message callback
		let _ = IoTHubDeviceClient_SetConnectionStatusCallback(iotHubClientHandle, nil, that)
		let result = IoTHubDeviceClient_SetDeviceMethodCallback(iotHubClientHandle, nil, that)
		IoTHub_Deinit()
	}
		
	private func sendLocationOverMQTT() -> Bool?{
		guard let currentLocationInfo = currentLocationInfo, currentLocationInfo.location.isValid == true else {
			return nil
		}
		let locationId = currentLocationInfo.locationId
		dc.updateSendTime(locationId: locationId)
		let currentLocation = currentLocationInfo.location
		let device = DeviceKit.Device.current
		let isCharging = device.batteryState == .charging(100)
		let locationData = SendLocationRequest(
			userId: lokiId ?? "",
			deviceId: lokiDevice.id,
			coordinates: Coordinates(
				latitude: currentLocation.coordinate.latitude,
				longitude: currentLocation.coordinate.longitude
			),
			recordedAtUTC: currentLocation.timestamp,
			altitude: currentLocation.altitude,
			verticalAccuracy: currentLocation.verticalAccuracy,
			horizontalAccuracy: currentLocation.horizontalAccuracy,
			sdkVersion: "1.0",
			speed: currentLocation.speed,
			battery: Battery(
				isCharging: isCharging,
				remainingCharge: device.batteryLevel
			),
			headingDirection: currentLocation.course,
			activity: "",
			isSimulated: currentLocation.sourceInformation?.isSimulatedBySoftware ?? false,
			appMode: currentLocationInfo.appMode
		)
		var success = false
		do {
			let jsonString = try locationData.toJSON()
			let messageHandle: IOTHUB_MESSAGE_HANDLE = IoTHubMessage_CreateFromByteArray(jsonString, jsonString.utf8.count)
			if messageHandle != OpaquePointer.init(bitPattern: 0) {
				let that = UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())
				let result = IoTHubDeviceClient_SendEventAsync(iotHubClientHandle, messageHandle, mySendConfirmationCallback, that)
				var responseString: String? = nil
				if let resultStr = IOTHUB_CLIENT_RESULTStrings(result) {
					responseString = String(cString: UnsafePointer<CChar>(resultStr))
				}
				if IOTHUB_CLIENT_OK == result {
					dc.updateSendStatus(locationId: locationId, status: .mqttSend)
					os_log("Loki: location updates send using device to cloud")
					success = true
				} else {
					dc.updateSendStatus(locationId: locationId, status: .mqttFailed, error: responseString)
					os_log("Loki: unable to send location updates using device to cloud")
				}
			}
		} catch {
			dc.updateSendStatus(locationId: locationId, status: .mqttFailed, error: error.localizedDescription)
			os_log("Loki: unable to send location updates using device to cloud")
		}
		return success
	}
	
	@objc private func showTimerAlert() {
		NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(showTimerAlert), object: nil)
		os_log("Loki: Show Notification")
		let center = UNUserNotificationCenter.current()
		
		// Request permission to display alerts and play sounds.
		center.requestAuthorization(options: [.alert, .sound]) { (granted, error) in
			// Enable or disable features based on authorization.
		}
		
		// Create the notification content
		let content = UNMutableNotificationContent()
		//content.title = "Location Update"
		//content.body = "Location has been updated"
		
		// Set the notification trigger for a specific date and time.
		let date = Date().addingTimeInterval(10) // 1 minute from now
		let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
		let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
		
		// Create the request for the notification.
		let uuidString = UUID().uuidString
		let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: trigger)
		
		center.removeAllPendingNotificationRequests()
		// Schedule the notification.
		center.add(request) { (error : Error?) in
			if let error = error {
				os_log("Loki: Notification Error: \(error)")
			}
		}
		perform(#selector(showTimerAlert), with:nil, afterDelay: 8, inModes: [.common])
	}
	
	private func sendCurrentLocation(_ forceUpdate:Bool = false) {
		var canSendLocation = true
		if let locationUpdateTime: Date = self.locationSendTime {
			if Date.now.timeIntervalSince(locationUpdateTime) <= 10{
				canSendLocation = false
			}
		}
		if canSendLocation || forceUpdate {
			self.locationSendTime = Date.now
			if isConnected {
				if let success = sendLocationOverMQTT(), success == false {
					Task {
						await Loki.sendLocation()
					}
				}
			} else {
				Task {
					await Loki.sendLocation()
				}
			}
		} else {
			os_log("Loki: location updates too soon")
		}
	}
	
	@objc func locationUpdated(notification: NSNotification) {
		guard let locationInfo = notification.object as? LocationInfo, locationInfo.location.isValid else {
			return
		}
		if let currentLocationInfo = self.currentLocationInfo, currentLocationInfo.location.timestamp > locationInfo.location.timestamp {
			return
		} else if let currentLocationInfo = try? UserDefaults.standard.getObject(forKey: self.currentLocationKey, castTo: LocationInfo.self), currentLocationInfo.location.isValid, currentLocationInfo.location.timestamp > locationInfo.location.timestamp {
			return
		}
		//showNotification()
		os_log("Loki: locationUpdate")
		var forceSend = currentLocationInfo == nil || (currentLocationInfo?.appMode != .foreground && locationInfo.appMode == .foreground)
		if !forceSend {
			if let currentLocationInfo = self.currentLocationInfo {
				forceSend = currentLocationInfo.location.horizontalAccuracy < locationInfo.location.horizontalAccuracy
			}
		}
		if let lokiId = self.lokiId {
			delegate?.didUpdateLocation(location: LokiLocation(lokiId: lokiId, location: locationInfo.location, isSimulated: locationInfo.location.sourceInformation?.isSimulatedBySoftware == true, appMode: locationInfo.appMode))
		}
		try? UserDefaults.standard.setObject(locationInfo, forKey: currentLocationKey)
		currentLocationInfo = locationInfo
		sendCurrentLocation(forceSend)
	}
}
