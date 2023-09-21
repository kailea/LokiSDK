//
//  LokiApiManagerInterface.swift
//  LokiSampleApp
//
//  Created by Amandeep Kaile on 18/4/2023.
//

import Foundation

protocol LokiApiManagerInterface {
	var authKey : String? { get set }
	func login(loginDetails: LoginRequest) async throws -> LoginResponse
	func logout(deviceId: String) async throws -> Bool
	func getLastKnownLocation(userId: String) async throws -> LastKnownLocation
	func subscribe(subscribers: [String]) async throws -> SubscribeResponse
	func unSubscribe(subscribers: [String]) async throws -> Bool
	func sendLocation(location: SendLocationRequest) async throws -> Bool
	func log(logMessage: LogRequest) async throws -> Bool
}
