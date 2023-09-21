//
//  LokiAPIManager.swift
//  Loki
//
//  Created by Amandeep Kaile on 12/4/2023.
//

import Foundation
import Alamofire

enum APIError: Error {
	case unknown
}
class LokiAPIManager : LokiApiManagerInterface {
	//static let sharedInstance = LokiAPIManager()
	private var sessionManager: Session
	private var decoder: LokiDataDecoder
	var authKey: String? {
		didSet {
			let configuration = sessionManager.sessionConfiguration
			if let authKey = authKey {
				configuration.httpAdditionalHeaders = ["AUTHKEY" : authKey, "User-Agent" : "LokiSampleApp/1.0 (au.com.guardiancorp.lokisample; build:1; iOS 16.4.0) Alamofire/5.6.4", "Accept-Encoding" : "br;q=1.0, gzip;q=0.9, deflate;q=0.8"]
			} else {
				configuration.httpAdditionalHeaders?.removeValue(forKey: "AUTHKEY")
			}
			sessionManager = {
				let configuration = configuration
				let networkLogger = LokiNetworkLogger()
				
				return Session(configuration: configuration, eventMonitors: [networkLogger])
			}()
		}
	}
	init(networkLogger: LokiNetwokEventMonitor, decoder: LokiDataDecoder) {
		self.decoder = decoder
		sessionManager = {
			let configuration = URLSessionConfiguration.af.default
			let networkLogger = networkLogger
			
			return Session(configuration: configuration, eventMonitors: [networkLogger])
		}()
	}
	
	func login(loginDetails: LoginRequest) async throws -> LoginResponse {
		let response = try await sessionManager.request(LokiAPIRouter.login(rerquestData: loginDetails))
			.serializingDecodable(LoginResponse.self, decoder: decoder).value
		return response
	}
	
	func logout(deviceId: String) async throws -> Bool {
		let response = try await sessionManager.request(LokiAPIRouter.logout(deviceId: deviceId))
			.serializingDecodable(LogoutResponse.self, decoder: decoder).value.result
		return response
	}
	
	func getLastKnownLocation(userId: String) async throws -> LastKnownLocation {
		let response = try await sessionManager.request(LokiAPIRouter.getLastKnownLocation(userId: userId))
			.serializingDecodable(LastKnownLocation.self, decoder: decoder).value
		return response
	}
	
	func subscribe(subscribers: [String]) async throws -> SubscribeResponse {
		let response = try await sessionManager.request(LokiAPIRouter.subscribe(subscribers: subscribers))
			.serializingDecodable(SubscribeResponse.self, decoder: decoder).value
		return response
	}
	
	func unSubscribe(subscribers: [String]) async throws -> Bool {
		let response = try await sessionManager.request(LokiAPIRouter.unsubscribe(subscribers: subscribers))
			.serializingDecodable(Bool.self, decoder: decoder).value
		return response
	}
	
	func sendLocation(location: SendLocationRequest) async throws -> Bool {
		let response = try await sessionManager.request(LokiAPIRouter.sendLocation(location: location))
			.serializingDecodable(Bool.self, decoder: decoder).value
		return response
	}
	
	func log(logMessage: LogRequest) async throws -> Bool {
		let response = try await sessionManager.request(LokiAPIRouter.log(logMessage: logMessage))
			.serializingDecodable(Bool.self, decoder: decoder).value
		return response
	}
}
