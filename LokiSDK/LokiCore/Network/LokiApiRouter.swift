//
//  LokiApiRouter.swift
//  Loki
//
//  Created by Amandeep Kaile on 12/4/2023.
//

import Foundation
import Alamofire
enum ContentTypes: String {
	case json = "application/json"
}

enum HTTPHeaderFields: String {
	case contentType = "Content-Type"
	case acceptType = "Accept"
	case acceptEncoding = "Accept-Encoding"
}

enum LokiAPIRouter : URLRequestConvertible {
	func asURLRequest() throws -> URLRequest {
		let baseURL = FrameworkConstants.trackingServiceUrl
		let url = try baseURL.asURL()
		let finalUrl = url.appendingPathComponent(path)
		var request = URLRequest(url: finalUrl)
		request.httpMethod = method.rawValue
		request.headers.add(.accept(ContentTypes.json.rawValue))
		request.headers.add(.contentType(ContentTypes.json.rawValue))
		if let params = parameters {
			do {
				request.httpBody = try JSONSerialization.data(withJSONObject: params, options: [])
			} catch {
				throw AFError.parameterEncodingFailed(reason: .jsonEncodingFailed(error: error))
			}
		}
		return request
	}
	
	
	case login(rerquestData: LoginRequest)
	case logout(deviceId: String)
	case getLastKnownLocation(userId: String)
	case subscribe(subscribers: [String])
	case unsubscribe(subscribers: [String])
	case sendLocation(location: SendLocationRequest)
	case log(logMessage: LogRequest)
	
	private var method: HTTPMethod {
		switch self {
			case .login:
				return .post
			case .logout:
				return  .post
			case .getLastKnownLocation:
				return .get
			case .subscribe:
				return .post
			case .unsubscribe:
				return .post
			case .sendLocation:
				return .post
			case .log:
				return .post
		}
	}
	
	private var path: String {
		switch self {
			case .login:
				return "/login"
			case .logout(deviceId: let deviceId):
				return "/\(deviceId)/logout"
			case .getLastKnownLocation(userId: let userId):
				return "/lastknownlocation/\(userId)"
			case .subscribe:
				return "/subscribe"
			case .unsubscribe:
				return "/unsubscribe"
			case .sendLocation:
				return "/location"
			case .log:
				return "/clientdiagnostic/log"
		}
	}
	
	private var parameters: Any? {
		switch self {
			case .login(let rerquestData):
				return try! rerquestData.toDictionary()
			case .logout:
				return nil
			case .getLastKnownLocation:
				return nil
			case .subscribe(let subscribers):
				return try! SubscribeUnsubscribeRequest(publishers: subscribers).toDictionary()
			case .unsubscribe(let subscribers):
				return try! SubscribeUnsubscribeRequest(publishers: subscribers).toDictionary()
			case .sendLocation(let location):
				return try! location.toDictionary()
			case .log(let logMessage):
				return try! [logMessage.toDictionary()]
		}
	}
}
