//
//  LokiNetworkLogger.swift
//  Loki
//
//  Created by Amandeep Kaile on 12/4/2023.
//

import Alamofire
import Foundation

class LokiNetworkLogger: LokiNetwokEventMonitor {
	func requestDidFinish(_ request: Request) {
		print(request.description)
		print(request.allMetrics)
	}
	
	func request(_ request: DataRequest, didParseResponse response: DataResponse<Data?, AFError>) {
		if request.isFinished == false {
			return
		}
		guard let requestData = request.request?.httpBody else {
			return
		}
		if let requestJson = try? JSONSerialization.jsonObject(with: requestData, options: .mutableContainers) {
			print(requestJson)
		}
		
		guard let responseData = response.data else {
			return
		}
		
		if let reponseJson = try? JSONSerialization.jsonObject(with: responseData, options: .mutableContainers) {
			print(request.allMetrics)
			print(reponseJson)
		}
	}
}
